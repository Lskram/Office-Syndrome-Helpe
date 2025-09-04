import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../data/models/notification_session.dart';
import '../data/models/pain_point.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'notification_controller.dart';
import 'settings_controller.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<NotificationSession?> currentSession = Rx<NotificationSession?>(
    null,
  );
  final RxString statusText = "".obs;
  final RxDouble progressValue = 0.0.obs;
  final RxString timeRemaining = "".obs;

  // Statistics
  final RxInt todayTotal = 0.obs;
  final RxInt todayCompleted = 0.obs;
  final RxDouble todaySuccessRate = 0.0.obs;
  final RxString averageSessionTime = "0:00".obs;

  // Pain points display
  final RxList<PainPoint> selectedPainPoints = <PainPoint>[].obs;

  Timer? _realtimeTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
    startRealtimeUpdate();
  }

  @override
  void onClose() {
    _realtimeTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeController() async {
    await loadCurrentSession();
    await loadTodayStats();
    await loadSelectedPainPoints();
  }

  // ⭐ Real-time Updates
  void startRealtimeUpdate() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTimeRemaining();
      updateProgressValue();
      updateStatusText();
    });
  }

  void updateTimeRemaining() {
    try {
      if (!Get.isRegistered<NotificationController>()) {
        timeRemaining.value = "ไม่ได้เปิดใช้งาน";
        return;
      }

      final notificationController = Get.find<NotificationController>();
      timeRemaining.value = notificationController.timeUntilNext;
    } catch (e) {
      timeRemaining.value = "ไม่ทราบ";
    }
  }

  void updateProgressValue() {
    try {
      if (!Get.isRegistered<NotificationController>()) {
        progressValue.value = 0.0;
        return;
      }

      final notificationController = Get.find<NotificationController>();
      progressValue.value = notificationController.progressValue;
    } catch (e) {
      progressValue.value = 0.0;
    }
  }

  void updateStatusText() {
    try {
      if (!Get.isRegistered<NotificationController>()) {
        statusText.value = "ไม่ได้เปิดใช้งาน";
        return;
      }

      final notificationController = Get.find<NotificationController>();
      statusText.value = notificationController.status.value;
    } catch (e) {
      statusText.value = "ไม่ทราบสถานะ";
    }
  }

  // ⭐ Pull to Refresh
  Future<void> onRefresh() async {
    isLoading.value = true;

    try {
      await Future.wait([
        _refreshNotificationController(),
        _refreshSettingsController(),
        loadCurrentSession(),
        loadTodayStats(),
        loadSelectedPainPoints(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshNotificationController() async {
    if (Get.isRegistered<NotificationController>()) {
      await Get.find<NotificationController>().refresh();
    }
  }

  Future<void> _refreshSettingsController() async {
    if (Get.isRegistered<SettingsController>()) {
      await Get.find<SettingsController>().refresh();
    }
  }

  // ⭐ Test Notification
  Future<void> testNotification() async {
    try {
      // Show countdown
      for (int i = 3; i > 0; i--) {
        Get.snackbar(
          "ทดสอบการแจ้งเตือน",
          "จะแจ้งเตือนใน $i วินาที",
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade800,
        );
        await Future.delayed(const Duration(seconds: 1));
      }

      await NotificationService.sendTestNotification();

      Get.snackbar(
        "ทดสอบเสร็จสิ้น",
        "ตรวจสอบการแจ้งเตือนบนหน้าจอ",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error in test notification: $e');
      Get.snackbar(
        "ข้อผิดพลาด",
        "ไม่สามารถส่งการแจ้งเตือนทดสอบได้",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // Data loading methods
  Future<void> loadCurrentSession() async {
    try {
      final settings = await DatabaseService.loadSettings();
      if (settings.currentSessionId != null) {
        currentSession.value = DatabaseService.getSession(
          settings.currentSessionId!,
        );
      } else {
        currentSession.value = null;
      }
    } catch (e) {
      print('Error loading current session: $e');
      currentSession.value = null;
    }
  }

  Future<void> loadTodayStats() async {
    try {
      if (!Get.isRegistered<NotificationController>()) return;

      final notificationController = Get.find<NotificationController>();
      final stats = await notificationController.getNotificationStats();

      todayTotal.value = stats['todayTotal'] ?? 0;
      todayCompleted.value = stats['todayCompleted'] ?? 0;
      todaySuccessRate.value = (stats['todaySuccessRate'] ?? 0.0).toDouble();

      final avgDuration = (stats['averageDuration'] ?? 0.0).toDouble();
      final minutes = (avgDuration / 60).floor();
      final seconds = (avgDuration % 60).floor();
      averageSessionTime.value =
          "$minutes:${seconds.toString().padLeft(2, '0')}";
    } catch (e) {
      print('Error loading today stats: $e');
      // Set default values
      todayTotal.value = 0;
      todayCompleted.value = 0;
      todaySuccessRate.value = 0.0;
      averageSessionTime.value = "0:00";
    }
  }

  Future<void> loadSelectedPainPoints() async {
    try {
      if (!Get.isRegistered<SettingsController>()) return;

      final settingsController = Get.find<SettingsController>();
      selectedPainPoints.value = settingsController.selectedPainPointsData;
    } catch (e) {
      print('Error loading selected pain points: $e');
      selectedPainPoints.clear();
    }
  }

  // Navigation methods
  void goToTodo() {
    if (currentSession.value != null) {
      Get.toNamed('/todo', arguments: currentSession.value!.id);
    } else {
      Get.snackbar(
        "ไม่มีกิจกรรม",
        "ไม่มีกิจกรรมออกกำลังกายในขณะนี้",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
    }
  }

  void goToStatistics() {
    Get.toNamed('/statistics');
  }

  void goToSettings() {
    Get.toNamed('/settings');
  }

  // Quick actions
  Future<void> enableNotifications() async {
    try {
      if (!Get.isRegistered<NotificationController>()) return;

      final notificationController = Get.find<NotificationController>();
      await notificationController.enableNotifications();

      // Refresh UI
      await onRefresh();
    } catch (e) {
      print('Error enabling notifications: $e');
    }
  }

  Future<void> disableNotifications() async {
    try {
      if (!Get.isRegistered<NotificationController>()) return;

      final notificationController = Get.find<NotificationController>();
      await notificationController.disableNotifications();

      // Refresh UI
      await onRefresh();
    } catch (e) {
      print('Error disabling notifications: $e');
    }
  }

  Future<void> forceNotificationNow() async {
    try {
      if (!Get.isRegistered<NotificationController>()) return;

      final notificationController = Get.find<NotificationController>();
      await notificationController.forceNotificationNow();

      // Refresh current session
      await loadCurrentSession();
    } catch (e) {
      print('Error forcing notification: $e');
    }
  }

  // Settings change handler
  void onSettingsChanged() {
    // Reload data when settings change
    loadSelectedPainPoints();
  }

  // Getters for UI
  bool get hasActiveSession => currentSession.value != null;

  bool get isNotificationEnabled {
    try {
      if (!Get.isRegistered<NotificationController>()) return false;
      return Get.find<NotificationController>().isEnabled.value;
    } catch (e) {
      return false;
    }
  }

  String get notificationStatusIcon {
    if (isNotificationEnabled) {
      return "🟢";
    } else {
      return "🔴";
    }
  }

  String get notificationStatusText {
    if (isNotificationEnabled) {
      return "เปิดใช้งาน";
    } else {
      return "ปิดใช้งาน";
    }
  }

  Color get statusCardColor {
    if (isNotificationEnabled) {
      return Colors.green.shade50;
    } else {
      return Colors.grey.shade100;
    }
  }

  Color get statusTextColor {
    if (isNotificationEnabled) {
      return Colors.green.shade800;
    } else {
      return Colors.grey.shade600;
    }
  }

  String get selectedPainPointsText {
    if (selectedPainPoints.isEmpty) {
      return "ยังไม่ได้เลือกจุดที่ปวด";
    }

    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().settings.value
        : null;
    final languageCode = settings?.languageCode ?? 'th';

    return selectedPainPoints.map((pp) => pp.getName(languageCode)).join(', ');
  }

  int get progressPercentage => (progressValue.value * 100).round();

  // Quick statistics getters
  String get todayStatsText {
    if (todayTotal.value == 0) {
      return "วันนี้ยังไม่มีกิจกรรม";
    }
    return "แจ้งเตือน: ${todayTotal.value} ครั้ง | ทำเสร็จ: ${todayCompleted.value} ครั้ง";
  }

  String get successRateText {
    if (todayTotal.value == 0) {
      return "0%";
    }
    return "${todaySuccessRate.value.toInt()}%";
  }

  Color get successRateColor {
    if (todaySuccessRate.value >= 80) {
      return Colors.green;
    } else if (todaySuccessRate.value >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Action methods for quick access
  void showNotificationOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ตัวเลือกการแจ้งเตือน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildQuickActionTile(
              icon: Icons.notifications_active,
              title: isNotificationEnabled
                  ? 'ปิดการแจ้งเตือน'
                  : 'เปิดการแจ้งเตือน',
              onTap: () {
                Get.back();
                if (isNotificationEnabled) {
                  disableNotifications();
                } else {
                  enableNotifications();
                }
              },
            ),
            _buildQuickActionTile(
              icon: Icons.science,
              title: 'ทดสอบการแจ้งเตือน',
              onTap: () {
                Get.back();
                testNotification();
              },
            ),
            _buildQuickActionTile(
              icon: Icons.play_circle_filled,
              title: 'สร้างการแจ้งเตือนทันที',
              onTap: () {
                Get.back();
                forceNotificationNow();
              },
            ),
            _buildQuickActionTile(
              icon: Icons.settings,
              title: 'ตั้งค่าการแจ้งเตือน',
              onTap: () {
                Get.back();
                goToSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue.shade600),
      ),
      title: Text(title),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  void showStatsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue),
            SizedBox(width: 8),
            Text('สถิติวันนี้'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('การแจ้งเตือนทั้งหมด', '${todayTotal.value} ครั้ง'),
            _buildStatRow('ทำเสร็จ', '${todayCompleted.value} ครั้ง'),
            _buildStatRow(
              'ข้าม',
              '${todayTotal.value - todayCompleted.value} ครั้ง',
            ),
            _buildStatRow(
              'อัตราความสำเร็จ',
              '${todaySuccessRate.value.toInt()}%',
            ),
            _buildStatRow('เวลาเฉลี่ยต่อครั้ง', averageSessionTime.value),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ปิด')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              goToStatistics();
            },
            child: const Text('ดูสถิติเพิ่มเติม'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Method to handle deep links or navigation with arguments
  void handleTodoNavigation(String? sessionId) {
    if (sessionId != null && sessionId.isNotEmpty) {
      Get.toNamed('/todo', arguments: sessionId);
    } else {
      goToTodo();
    }
  }

  // Cleanup and maintenance methods
  Future<void> performMaintenance() async {
    try {
      // Cleanup old sessions
      await DatabaseService.cleanupOldSessions();

      // Refresh all data
      await onRefresh();

      print('Maintenance completed successfully');
    } catch (e) {
      print('Error during maintenance: $e');
    }
  }

  // Debug methods (can be removed in production)
  void printCurrentState() {
    print('=== HomeController State ===');
    print('Is Loading: ${isLoading.value}');
    print('Notification Enabled: $isNotificationEnabled');
    print('Has Active Session: $hasActiveSession');
    print('Time Remaining: ${timeRemaining.value}');
    print('Progress: ${progressPercentage}%');
    print('Today Total: ${todayTotal.value}');
    print('Today Completed: ${todayCompleted.value}');
    print('Success Rate: ${todaySuccessRate.value}%');
    print('Selected Pain Points: ${selectedPainPoints.length}');
    print('============================');
  }

  // Method for handling app lifecycle changes
  void onAppResumed() {
    // Refresh data when app comes to foreground
    onRefresh();
  }

  void onAppPaused() {
    // Perform any necessary cleanup
  }

  // Emergency methods
  Future<void> emergencyStop() async {
    try {
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().disableNotifications();
      }

      await NotificationService.cancelAllNotifications();
      await NotificationService.clearPersistentNotification();

      Get.snackbar(
        'หยุดฉุกเฉิน',
        'ระบบแจ้งเตือนถูกหยุดเป็นการฉุกเฉิน',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );

      await onRefresh();
    } catch (e) {
      print('Error in emergency stop: $e');
    }
  }
}
