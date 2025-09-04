import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../data/models/notification_session.dart';
import '../data/models/pain_point.dart';
import 'database_service.dart';

class NotificationService {
  static const int _notificationId = 0;
  static const int _persistentNotificationId = 1;
  static const int _testNotificationId = 999;

  static FlutterLocalNotificationsPlugin? _notifications;

  // Notification channels
  static const String _mainChannelId = 'office_syndrome_channel';
  static const String _persistentChannelId = 'office_syndrome_persistent';
  static const String _testChannelId = 'office_syndrome_test';

  static Future<void> initialize() async {
    try {
      _notifications = FlutterLocalNotificationsPlugin();

      // Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications!.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels for Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Initialize alarm manager for Android
      if (Platform.isAndroid) {
        await AndroidAlarmManager.initialize();
      }

      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
      throw Exception('Failed to initialize notifications: $e');
    }
  }

  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    // Main notification channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _mainChannelId,
        'Office Syndrome Notifications',
        description: 'การแจ้งเตือนออกกำลังกาย',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Persistent notification channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _persistentChannelId,
        'Office Syndrome Persistent',
        description: 'การแจ้งเตือนแบบติดค้าง',
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );

    // Test notification channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _testChannelId,
        'Office Syndrome Test',
        description: 'ทดสอบการแจ้งเตือน',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  static Future<void> showNotification(NotificationSession session) async {
    if (_notifications == null) {
      print('Notifications not initialized');
      return;
    }

    try {
      final painPoint = DatabaseService.getPainPoint(session.painPointId);
      final settings = await DatabaseService.loadSettings();

      if (painPoint == null) {
        print('Pain point not found for session ${session.id}');
        return;
      }

      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        _mainChannelId,
        'Office Syndrome Notifications',
        channelDescription: 'การแจ้งเตือนออกกำลังกาย',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ถึงเวลาออกกำลังกาย',
        playSound: settings.soundEnabled,
        enableVibration: settings.vibrationEnabled,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        ongoing: false,
        styleInformation: const BigTextStyleInformation(
          'กดเพื่อดูท่าออกกำลังกายที่แนะนำ',
          htmlFormatBigText: true,
          contentTitle: '⏰ ถึงเวลาดูแลสุขภาพแล้ว!',
          htmlFormatContentTitle: true,
        ),
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: 'exercise_reminder',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title =
          "⏰ ถึงเวลาดูแล: ${painPoint.getName(settings.languageCode)}";
      const body = "กดเพื่อดูท่าออกกำลังกาย";

      await _notifications!.show(
        _notificationId,
        title,
        body,
        details,
        payload: session.id,
      );

      // Show persistent notification
      await _showPersistentNotification(session);

      print('Notification shown for session: ${session.id}');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> _showPersistentNotification(
    NotificationSession session,
  ) async {
    if (_notifications == null) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        _persistentChannelId,
        'Office Syndrome Persistent',
        channelDescription: 'การแจ้งเตือนแบบติดค้าง',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        playSound: false,
        enableVibration: false,
        styleInformation: BigTextStyleInformation(
          'มีท่าออกกำลังกายรอให้ทำ - กดเพื่อดูรายละเอียด',
          contentTitle: '🏃‍♂️ Office Syndrome Helper',
        ),
      );

      const details = NotificationDetails(android: androidDetails);

      await _notifications!.show(
        _persistentNotificationId,
        "🏃‍♂️ Office Syndrome Helper",
        "มีท่าออกกำลังกายรอให้ทำ - กดเพื่อดูรายละเอียด",
        details,
        payload: session.id,
      );
    } catch (e) {
      print('Error showing persistent notification: $e');
    }
  }

  static Future<void> sendTestNotification() async {
    if (_notifications == null) {
      print('Notifications not initialized');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        _testChannelId,
        'Office Syndrome Test',
        channelDescription: 'ทดสอบการแจ้งเตือน',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ทดสอบการแจ้งเตือน',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          'หากคุณเห็นข้อความนี้แสดงว่าการแจ้งเตือนทำงานปกติ! 🎉',
          contentTitle: '🧪 ทดสอบการแจ้งเตือน',
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(
        _testNotificationId,
        "🧪 ทดสอบการแจ้งเตือน",
        "การแจ้งเตือนทำงานปกติ! 🎉",
        details,
      );

      print('Test notification sent');
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');

    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      // Navigate to Todo Page with session ID
      Get.toNamed('/todo', arguments: payload);
    } else {
      // Navigate to home if no payload
      Get.toNamed('/home');
    }
  }

  static Future<void> scheduleNotification({
    required String sessionId,
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    if (_notifications == null) return;

    try {
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        _mainChannelId,
        'Office Syndrome Notifications',
        channelDescription: 'การแจ้งเตือนออกกำลังกาย',
        importance: Importance.high,
        priority: Priority.high,
        fullScreenIntent: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.zonedSchedule(
        _notificationId,
        title,
        body,
        tzDateTime,
        details,
        payload: sessionId,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('Notification scheduled for: $scheduledTime');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification([int? id]) async {
    if (_notifications == null) return;

    try {
      if (id != null) {
        await _notifications!.cancel(id);
      } else {
        await _notifications!.cancel(_notificationId);
      }
      print('Notification cancelled: ${id ?? _notificationId}');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    if (_notifications == null) return;

    try {
      await _notifications!.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  static Future<void> clearPersistentNotification() async {
    if (_notifications == null) return;

    try {
      await _notifications!.cancel(_persistentNotificationId);
      print('Persistent notification cleared');
    } catch (e) {
      print('Error clearing persistent notification: $e');
    }
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    if (_notifications == null) return [];

    try {
      return await _notifications!.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  // Alarm manager methods for precise timing (Android only)
  static Future<void> setExactAlarm({
    required int alarmId,
    required DateTime scheduledTime,
    required String sessionId,
  }) async {
    if (!Platform.isAndroid) return;

    try {
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        _alarmCallback,
        exact: true,
        wakeup: true,
        params: {'sessionId': sessionId},
      );

      print('Exact alarm set for: $scheduledTime');
    } catch (e) {
      print('Error setting exact alarm: $e');
    }
  }

  static Future<void> cancelExactAlarm(int alarmId) async {
    if (!Platform.isAndroid) return;

    try {
      await AndroidAlarmManager.cancel(alarmId);
      print('Exact alarm cancelled: $alarmId');
    } catch (e) {
      print('Error cancelling exact alarm: $e');
    }
  }

  // Callback for alarm manager
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(
    int id,
    Map<String, dynamic> params,
  ) async {
    print('Alarm callback triggered: $id');

    final sessionId = params['sessionId'] as String?;
    if (sessionId != null) {
      // Load session and show notification
      final session = DatabaseService.getSession(sessionId);
      if (session != null) {
        await showNotification(session);
      }
    }
  }

  // Utility methods
  static Future<bool> areNotificationsEnabled() async {
    if (_notifications == null) return false;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notifications!
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        if (androidPlugin != null) {
          return await androidPlugin.areNotificationsEnabled() ?? false;
        }
      }
      return true; // Assume enabled for iOS and other platforms
    } catch (e) {
      print('Error checking notification status: $e');
      return false;
    }
  }

  static Future<void> requestNotificationPermissions() async {
    if (_notifications == null) return;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _notifications!
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        await androidPlugin?.requestNotificationsPermission();
      }

      if (Platform.isIOS) {
        final iosPlugin = _notifications!
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  // Create notification with custom sound
  static Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? sound,
    bool vibrate = true,
    String? payload,
  }) async {
    if (_notifications == null) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        _mainChannelId,
        'Office Syndrome Notifications',
        channelDescription: 'การแจ้งเตือนออกกำลังกาย',
        importance: Importance.high,
        priority: Priority.high,
        playSound: sound != null,
        sound: sound != null
            ? RawResourceAndroidNotificationSound(sound)
            : null,
        enableVibration: vibrate,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(id, title, body, details, payload: payload);
    } catch (e) {
      print('Error showing custom notification: $e');
    }
  }
}
