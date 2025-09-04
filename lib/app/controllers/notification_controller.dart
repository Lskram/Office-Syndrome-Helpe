import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/notification_session.dart';
import '../data/models/user_settings.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/random_service.dart';

class NotificationController extends GetxController {
  // State Management
  final RxBool isEnabled = false.obs;
  final Rx<DateTime?> nextNotificationTime = Rx<DateTime?>(null);
  final RxString status = "ไม่ได้เปิดใช้งาน".obs;
  final Rx<NotificationSession?> currentSession = Rx<NotificationSession?>(null);
  final RxInt pendingNotificationsCount = 0.obs;

  Timer? _schedulerTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _schedulerTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeController() async {
    try {
      await refreshStatus();
      _startScheduler();
    } catch (e) {
      print('Error initializing NotificationController: $e');
    }
  }

  Future<void> refreshStatus() async {
    try {
      final settings = await DatabaseService.loadSettings();
      isEnabled.value = settings.notificationEnabled;
      
      if (isEnabled.value) {
        nextNotificationTime.value = calculateNextNotificationTime();
        _updateStatus();
      } else {
        status.value = "ไม่ได้เปิดใช้งาน";
        nextNotificationTime.value = null;
      }

      // Load current session if exists
      if (settings.currentSessionId != null) {
        currentSession.value = DatabaseService.getSession(settings.currentSessionId!);
      }

      // Count pending notifications
      final pending = await NotificationService.getPendingNotifications();
      pendingNotificationsCount.value = pending.length;

    } catch (e) {
      print('Error refreshing notification status: $e');
    }
  }

  // ⭐ Fixed Timing Logic
  DateTime calculateNextNotificationTime() {
    try {
      final settings = Get.find<SettingsController>().settings.value;
      final interval = Duration(minutes: settings.notificationInterval);
      
      if (settings.lastNotificationTime == null) {
        // ครั้งแรก - เริ่มจากตอนนี้
        final now = DateTime.now();
        return findNextValidTime(now.add(interval));
      } else {
        // ครั้งถัดไป - จาก lastNotificationTime + interval
        final nextTime = settings.lastNotificationTime!.add(interval);
        return findNextValidTime(nextTime);
      }
    } catch (e) {
      print('Error calculating next notification time: $e');
      return DateTime.now().add(const Duration(minutes: 60));
    }
  }

  DateTime findNextValidTime(DateTime candidate) {
    int attempts = 0;
    const maxAttempts = 60 * 24; // 24 hours in minutes
    
    while (!shouldNotifyAt(candidate) && attempts < maxAttempts) {
      candidate = candidate.add(const Duration(minutes: 1));
      attempts++;
    }
    
    return candidate;
  }

  bool shouldNotifyAt(DateTime time) {
    try {
      final settings = Get.find<SettingsController>().settings.value;
      
      // เช็ควันทำงาน
      if (!settings.workingDays.contains(time.weekday)) return false;
      
      // เช็คเวลาทำงาน
      final timeOfDay = TimeOfDay.fromDateTime(time);
      if (!_isTimeInRange(timeOfDay, settings.workStartTime, settings.workEndTime)) {
        return false;
      }
      
      // เช็คช่วงพัก
      for (final breakPeriod in settings.breakPeriods) {
        if (_isTimeInRange(timeOfDay, breakPeriod.startTime, breakPeriod.endTime)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error checking if should notify: $e');
      return false;
    }
  }

  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (startMinutes <= endMinutes) {
      // Same day range
      return timeMinutes >= startMinutes && timeMinutes < endMinutes;
    } else {
      // Overnight range
      return timeMinutes >= startMinutes || timeMinutes < endMinutes;
    }
  }

  // ⭐ Settings Communication
  void onSettingsChanged() {
    try {
      final settings = Get.find<SettingsController>().settings.value;
      isEnabled.value = settings.notificationEnabled;
      
      if (isEnabled.value) {
        // เมื่อ Settings เปลี่ยน ให้คำนวณเวลาถัดไปใหม่
        nextNotificationTime.value = calculateNextNotificationTime();
        _scheduleNextNotification();
      } else {
        _cancelAllNotifications();
        nextNotificationTime.value = null;
      }
      
      _updateStatus();
      update(); // แจ้ง UI ให้อัพเดท
      
      print('Notification controller updated after settings change');
    } catch (e) {
      print('Error handling settings change: $e');
    }
  }

  // ⭐ Session Management
  Future<void> createNotificationSession() async {
    try {
      final settings = Get.find<SettingsController>().settings.value;
      
      // สุ่มเลือกจุดที่ปวดและท่า
      final selectedPainPoint = RandomService.selectRandomPainPoint(
        settings.selectedPainPoints
      );
      final selectedTreatments = RandomService.selectRandomTreatments(
        selectedPainPoint, 2
      );
      
      // สร้าง session ใหม่
      final session = NotificationSession(
        id: const Uuid().v4(),
        scheduledTime: DateTime.now(),
        painPointId: selectedPainPoint,
        treatmentIds: selectedTreatments,
        status: SessionStatus.scheduled,
        snoozeCount: 0,
        treatmentCompleted: [false, false],
      );
      
      // เก็บใน database และ settings
      await DatabaseService.saveSession(session);
      settings.currentSessionId = session.id;
      await DatabaseService.saveSettings(settings);
      
      currentSession.value = session;
      
      // ส่งการแจ้งเตือน
      await NotificationService.showNotification(session);
      
      print('Created notification session: ${session.id}');
    } catch (e) {
      print('Error creating notification session: $e');
    }
  }

  Future<void> completeCurrentSession() async {
    try {
      final session = currentSession.value;
      if (session == null) return;

      // Update session status
      session.status = SessionStatus.completed;
      session.completedTime = DateTime.now();
      await DatabaseService.saveSession(session);

      // Update settings
      final settings = Get.find<SettingsController>().settings.value;
      settings.lastNotificationTime = DateTime.now();
      settings.currentSessionId = null;
      await DatabaseService.saveSettings(settings);

      // Clear current session
      currentSession.value = null;

      // Clear persistent notification
      await NotificationService.clearPersistentNotification();

      // Schedule next notification
      nextNotificationTime.value = calculateNextNotificationTime();
      await _scheduleNextNotification();

      print('Completed session: ${session.id}');
    } catch (e) {
      print('Error completing session: $e');
    }
  }

  Future<void> skipCurrentSession() async {
    try {
      final session = currentSession.value;
      if (session == null) return;

      // Update session status
      session.status = SessionStatus.skipped;
      await DatabaseService.saveSession(session);

      // Update settings - อัพเดท lastNotificationTime เป็น now
      final settings = Get.find<SettingsController>().settings.value;
      settings.lastNotificationTime = DateTime.now();
      settings.currentSessionId = null;
      await DatabaseService.saveSettings(settings);

      // Clear current session
      currentSession.value = null;

      // Clear persistent notification
      await NotificationService.clearPersistentNotification();

      // Schedule next notification
      nextNotificationTime.value = calculateNextNotificationTime();
      await _scheduleNextNotification();

      print('Skipped session: ${session.id}');
    } catch (e) {
      print('Error skipping session: $e');
    }
  }

  Future<void> snoozeCurrentSession(int minutes) async {
    try {
      final session = currentSession.value;
      if (session == null) return;

      final settings = Get.find<SettingsController>().settings.value;
      
      // Check snooze limit
      if (session.snoozeCount >= settings.maxSnoozeCount) {
        Get.snackbar(
          'ไม่สามารถเลื่อนได้', 
          'เลื่อนได้สูงสุด ${settings.maxSnoozeCount} ครั้งต่อรอบ',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        return;
      }

      // Update session
      session.status = SessionStatus.snoozed;
      session.snoozeCount++;
      await DatabaseService.saveSession(session);

      // Clear current notification
      await NotificationService.cancelAllNotifications();

      // Schedule snooze notification
      final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
      await NotificationService.scheduleNotification(
        sessionId: session.id,
        scheduledTime: snoozeTime,
        title: "⏰ เวลาเลื่อนหมดแล้ว",
        body: "มาออกกำลังกายกันเถอะ",
      );

      Get.snackbar(
        'เลื่อนเวลาแล้ว', 
        'จะแจ้งเตือนอีกครั้งในอีก $minutes นาที',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
      );

      print('Snoozed session: ${session.id} for $minutes minutes');
    } catch (e) {
      print('Error snoozing session: $e');
    }
  }

  // Enable/Disable notifications
  Future<void> enableNotifications() async {
    try {
      final settingsController = Get.find<SettingsController>();
      settingsController.settings.value.notificationEnabled = true;
      await settingsController.saveSettings();
      
      isEnabled.value = true;
      nextNotificationTime.value = calculateNextNotificationTime();
      await _scheduleNextNotification();
      _updateStatus();
      
      Get.snackbar(
        'เปิดการแจ้งเตือนแล้ว', 
        'การแจ้งเตือนได้รับการเปิดใช้งาน',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error enabling notifications: $e');
    }
  }

  Future<void> disableNotifications() async {
    try {
      final settingsController = Get.find<SettingsController>();
      settingsController.settings.value.notificationEnabled = false;
      await settingsController.saveSettings();
      
      isEnabled.value = false;
      await _cancelAllNotifications();
      nextNotificationTime.value = null;
      status.value = "ไม่ได้เปิดใช้งาน";
      
      Get.snackbar(
        'ปิดการแจ้งเตือนแล้ว', 
        'การแจ้งเตือนได้รับการปิดใช้งาน',
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade800,
      );
    } catch (e) {
      print('Error disabling notifications: $e');
    }
  }

  // Private methods
  Future<void> _scheduleNextNotification() async {
    if (!isEnabled.value || nextNotificationTime.value == null) return;

    try {
      // Cancel existing notifications
      await NotificationService.cancelAllNotifications();
      
      // Schedule new notification
      await NotificationService.scheduleNotification(
        sessionId: 'next_scheduled',
        scheduledTime: nextNotificationTime.value!,
        title: "⏰ ถึงเวลาออกกำลังกาย",
        body: "มาดูแลสุขภาพกันเถอะ",
      );

      print('Next notification scheduled for: ${nextNotificationTime.value}');
    } catch (e) {
      print('Error scheduling next notification: $e');
    }
  }

  Future<void> _cancelAllNotifications() async {
    try {
      await NotificationService.cancelAllNotifications();
      await NotificationService.clearPersistentNotification();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling notifications: $e');
    }
  }

  void _updateStatus() {
    if (!isEnabled.value) {
      status.value = "ไม่ได้เปิดใช้งาน";
      return;
    }

    final nextTime = nextNotificationTime.value;
    if (nextTime == null) {
      status.value = "กำลังประมวลผล...";
      return;
    }

    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.isNegative) {
      status.value = "ถึงเวลาแจ้งเตือนแล้ว";
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        status.value = "แจ้งเตือนถัดไปใน ${hours} ชั่วโมง ${minutes} นาที";
      } else {
        status.value = "แจ้งเตือนถัดไปใน ${minutes} นาที";
      }
    }
  }

  void _startScheduler() {
    // ตรวจสอบทุก 30 วินาที
    _schedulerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAndTriggerNotification();
    });
  }

  void _checkAndTriggerNotification() {
    if (!isEnabled.value || nextNotificationTime.value == null) return;

    final now = DateTime.now();
    final scheduledTime = nextNotificationTime.value!;

    // ตรวจสอบว่าถึงเวลาแจ้งเตือนแล้วหรือไม่ (ให้ tolerance 1 นาที)
    final difference = scheduledTime.difference(now);
    if (difference.inMilliseconds <= Duration(minutes: 1).inMilliseconds && 
        difference.inMilliseconds >= -Duration(minutes: 1).inMilliseconds) {
      
      // ถึงเวลาแจ้งเตือนแล้ว
      _triggerNotification();
    }

    // อัพเดทสถานะ
    _updateStatus();
  }

  Future<void> _triggerNotification() async {
    try {
      // สร้าง session ใหม่และแจ้งเตือน
      await createNotificationSession();
      
      // อัพเดทเวลาถัดไป
      nextNotificationTime.value = calculateNextNotificationTime();
      
      print('Notification triggered and next time scheduled');
    } catch (e) {
      print('Error triggering notification: $e');
    }
  }

  // Test methods
  Future<void> testNotification() async {
    try {
      await NotificationService.sendTestNotification();
      
      Get.snackbar(
        'ทดสอบเสร็จสิ้น', 
        'ตรวจสอบการแจ้งเตือนบนหน้าจอ',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
      );
    } catch (e) {
      print('Error sending test notification: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถส่งการแจ้งเตือนทดสอบได้');
    }
  }

  Future<void> forceNotificationNow() async {
    try {
      await createNotificationSession();
      
      Get.snackbar(
        'สร้างการแจ้งเตือนแล้ว', 
        'การแจ้งเตือนถูกสร้างขึ้นทันที',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error forcing notification: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถสร้างการแจ้งเตือนได้');
    }
  }

  // Getters for UI
  String get timeUntilNext {
    final nextTime = nextNotificationTime.value;
    if (nextTime == null) return "ไม่ทราบ";

    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.isNegative) {
      return "ถึงเวลาแล้ว";
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (hours > 0) {
      return "${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
  }

  double get progressValue {
    try {
      final settings = Get.find<SettingsController>().settings.value;
      final nextTime = nextNotificationTime.value;
      
      if (nextTime == null || settings.lastNotificationTime == null) {
        return 0.0;
      }

      final totalInterval = Duration(minutes: settings.notificationInterval);
      final elapsed = DateTime.now().difference(settings.lastNotificationTime!);
      final progress = elapsed.inMilliseconds / totalInterval.inMilliseconds;
      
      return progress.clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  int get progressPercentage {
    return (progressValue * 100).round();
  }

  bool get hasActiveSession {
    return currentSession.value != null;
  }

  // Statistics methods
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));

      final sessions = DatabaseService.getSessionsByDateRange(weekAgo, today);

      final todaySessions = sessions
          .where((s) => s.createdAt.isAfter(today))
          .toList();

      final completedToday = todaySessions
          .where((s) => s.status == SessionStatus.completed)
          .length;

      final skippedToday = todaySessions
          .where((s) => s.status == SessionStatus.skipped)
          .length;

      final snoozedToday = todaySessions
          .where((s) => s.status == SessionStatus.snoozed)
          .length;

      final totalToday = todaySessions.length;
      final successRateToday = totalToday > 0 ? (completedToday / totalToday * 100) : 0.0;

      return {
        'todayTotal': totalToday,
        'todayCompleted': completedToday,
        'todaySkipped': skippedToday,
        'todaySnoozed': snoozedToday,
        'todaySuccessRate': successRateToday,
        'weekTotal': sessions.length,
        'averageDuration': _calculateAverageDuration(sessions),
      };
    } catch (e) {
      print('Error getting notification stats: $e');
      return {};
    }
  }

  double _calculateAverageDuration(List<NotificationSession> sessions) {
    final completedSessions = sessions
        .where((s) => s.status == SessionStatus.completed && s.sessionDurationSeconds > 0)
        .toList();

    if (completedSessions.isEmpty) return 0.0;

    final totalSeconds = completedSessions
        .map((s) => s.sessionDurationSeconds)
        .reduce((a, b) => a + b);

    return totalSeconds / completedSessions.length;
  }

  // Manual refresh method
  Future<void> refresh() async {
    await refreshStatus();
  }

  // Cleanup old sessions
  Future<void> cleanupOldSessions() async {
    try {
      await DatabaseService.cleanupOldSessions();
      print('Old sessions cleaned up');
    } catch (e) {
      print('Error cleaning up old sessions: $e');
    }
  }
}