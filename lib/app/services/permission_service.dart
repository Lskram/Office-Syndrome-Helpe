import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'database_service.dart';

class PermissionService {
  static Future<bool> checkAndRequestPermissions() async {
    try {
      final settings = await DatabaseService.loadSettings();

      // ถ้าเคยขออนุญาติแล้ว ให้เช็คสถานะปัจจุบัน
      if (settings.hasRequestedPermissions) {
        return await checkCurrentPermissionStatus();
      }

      // ขออนุญาติครั้งแรก
      final result = await _requestAllPermissions();

      // บันทึกว่าเคยขออนุญาติแล้ว
      settings.hasRequestedPermissions = true;
      await DatabaseService.saveSettings(settings);

      return result;
    } catch (e) {
      print('Error in checkAndRequestPermissions: $e');
      return false;
    }
  }

  static Future<bool> checkCurrentPermissionStatus() async {
    try {
      final permissions = await _getRequiredPermissions();

      for (final permission in permissions) {
        final status = await permission.status;
        if (!status.isGranted) {
          print('Permission ${permission.toString()} not granted: $status');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking current permission status: $e');
      return false;
    }
  }

  static Future<bool> _requestAllPermissions() async {
    try {
      // ขออนุญาติ notification
      final notificationStatus = await Permission.notification.request();
      if (!notificationStatus.isGranted) {
        _showPermissionDialog("การแจ้งเตือน");
        return false;
      }

      // ขออนุญาติ exact alarm (Android 12+)
      if (Platform.isAndroid) {
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        if (!alarmStatus.isGranted) {
          _showPermissionDialog("การตั้งเวลาแม่นยำ");
          return false;
        }
      }

      // ขออนุญาติ system alert window (สำหรับ full screen notification)
      if (Platform.isAndroid) {
        final alertStatus = await Permission.systemAlertWindow.request();
        // This permission is optional for better user experience
        if (!alertStatus.isGranted) {
          print(
            'System alert window permission not granted - app will still work',
          );
        }
      }

      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  static List<Permission> _getRequiredPermissions() {
    final permissions = <Permission>[Permission.notification];

    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.scheduleExactAlarm,
        // Permission.systemAlertWindow, // Optional
      ]);
    }

    return permissions;
  }

  static Future<Map<String, bool>> getDetailedPermissionStatus() async {
    final result = <String, bool>{};

    try {
      // Notification permission
      final notificationStatus = await Permission.notification.status;
      result['notification'] = notificationStatus.isGranted;

      if (Platform.isAndroid) {
        // Exact alarm permission
        final alarmStatus = await Permission.scheduleExactAlarm.status;
        result['exactAlarm'] = alarmStatus.isGranted;

        // System alert window permission
        final alertStatus = await Permission.systemAlertWindow.status;
        result['systemAlert'] = alertStatus.isGranted;
      }

      return result;
    } catch (e) {
      print('Error getting detailed permission status: $e');
      return result;
    }
  }

  static void _showPermissionDialog(String permissionName) {
    Get.dialog(
      AlertDialog(
        title: Text("ต้องการอนุญาติ$permissionName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("แอปต้องการ$permissionNameเพื่อทำงานได้อย่างถูกต้อง"),
            const SizedBox(height: 12),
            Text(
              "โดยไม่มี$permissionName แอปอาจไม่สามารถแจ้งเตือนให้คุณออกกำลังกายได้ตามเวลาที่กำหนด",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("ยกเลิก")),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text("ไปตั้งค่า"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> showPermissionGuideDialog() async {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text("คำแนะนำการอนุญาติ"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPermissionItem(
                icon: Icons.notifications,
                title: "การแจ้งเตือน",
                description: "จำเป็นสำหรับการแจ้งเตือนออกกำลังกาย",
                required: true,
              ),
              if (Platform.isAndroid) ...[
                const SizedBox(height: 12),
                _buildPermissionItem(
                  icon: Icons.schedule,
                  title: "การตั้งเวลาแม่นยำ",
                  description: "ทำให้การแจ้งเตือนตรงเวลามากขึ้น",
                  required: true,
                ),
                const SizedBox(height: 12),
                _buildPermissionItem(
                  icon: Icons.fullscreen,
                  title: "แสดงบนหน้าจอ",
                  description: "ช่วยให้เห็นการแจ้งเตือนได้ชัดเจนขึ้น",
                  required: false,
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "หากปฏิเสธการอนุญาติ สามารถเปลี่ยนใจได้ทีหลังในการตั้งค่าของแอป",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("เข้าใจแล้ว"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              checkAndRequestPermissions();
            },
            child: const Text("ขออนุญาติ"),
          ),
        ],
      ),
    );
  }

  static Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool required,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: required ? Colors.red.shade50 : Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: required ? Colors.red.shade600 : Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: required ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      required ? "จำเป็น" : "เสริม",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> checkBatteryOptimization() async {
    if (!Platform.isAndroid) return;

    try {
      // Check if battery optimization is disabled
      final isIgnoringBatteryOptimizations =
          await Permission.ignoreBatteryOptimizations.status;

      if (!isIgnoringBatteryOptimizations.isGranted) {
        _showBatteryOptimizationDialog();
      }
    } catch (e) {
      print('Error checking battery optimization: $e');
    }
  }

  static void _showBatteryOptimizationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.orange),
            SizedBox(width: 8),
            Text("การประหยัดแบตเตอรี่"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "เพื่อให้การแจ้งเตือนทำงานได้ดีที่สุด แนะนำให้ปิดการประหยัดแบตเตอรี่สำหรับแอปนี้",
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ขั้นตอน:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "1. ไปที่ตั้งค่า > แบตเตอรี่\n"
                    "2. เลือก 'การเพิ่มประสิทธิภาพแบตเตอรี่'\n"
                    "3. หา 'Office Syndrome Helper'\n"
                    "4. เปลี่ยนเป็น 'ไม่เพิ่มประสิทธิภาพ'",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("ข้ามไป")),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Permission.ignoreBatteryOptimizations.request();
            },
            child: const Text("ไปตั้งค่า"),
          ),
        ],
      ),
    );
  }

  static Future<bool> isNotificationEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  static Future<bool> isExactAlarmEnabled() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking exact alarm permission: $e');
      return false;
    }
  }

  static Future<void> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        _showPermissionDialog("การแจ้งเตือน");
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }

  static Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    try {
      final status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) {
        _showPermissionDialog("การตั้งเวลาแม่นยำ");
      }
    } catch (e) {
      print('Error requesting exact alarm permission: $e');
    }
  }
}
