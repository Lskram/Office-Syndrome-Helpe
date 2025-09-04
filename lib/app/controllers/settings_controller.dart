import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../data/models/user_settings.dart';
import '../data/models/pain_point.dart';
import '../services/database_service.dart';

class SettingsController extends GetxController {
  final Rx<UserSettings> settings = UserSettings.createDefault().obs;
  final RxBool isLoading = false.obs;
  final RxString currentLanguage = 'th'.obs;

  // Pain points data
  final RxList<PainPoint> allPainPoints = <PainPoint>[].obs;
  final RxList<int> selectedPainPoints = <int>[].obs;

  // UI state
  final RxBool isExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadPainPoints();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final loadedSettings = await DatabaseService.loadSettings();
      settings.value = loadedSettings;
      selectedPainPoints.assignAll(loadedSettings.selectedPainPoints);
      currentLanguage.value = loadedSettings.languageCode;
    } catch (e) {
      print('Error loading settings: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถโหลดการตั้งค่าได้');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      await DatabaseService.saveSettings(settings.value);

      // Notify other controllers about settings change
      _notifySettingsChanged();

      Get.snackbar(
        'บันทึกแล้ว',
        'การตั้งค่าได้รับการบันทึกเรียบร้อย',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error saving settings: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถบันทึกการตั้งค่าได้');
    }
  }

  void loadPainPoints() {
    try {
      allPainPoints.assignAll(DatabaseService.getAllPainPoints());
    } catch (e) {
      print('Error loading pain points: $e');
      allPainPoints.assignAll(PainPoint.getAllPainPoints());
    }
  }

  // Notification settings
  void toggleNotifications(bool enabled) {
    settings.value.notificationEnabled = enabled;
    saveSettings();
  }

  void updateNotificationInterval(int minutes) {
    settings.value.notificationInterval = minutes;
    saveSettings();
  }

  void updateWorkStartTime(TimeOfDay time) {
    settings.value.workStartTime = time;
    saveSettings();
  }

  void updateWorkEndTime(TimeOfDay time) {
    settings.value.workEndTime = time;
    saveSettings();
  }

  void updateWorkingDays(List<int> days) {
    settings.value.workingDays = days;
    saveSettings();
  }

  void toggleSound(bool enabled) {
    settings.value.soundEnabled = enabled;
    saveSettings();
  }

  void toggleVibration(bool enabled) {
    settings.value.vibrationEnabled = enabled;
    saveSettings();
  }

  // Pain points management
  void togglePainPoint(int painPointId) {
    if (selectedPainPoints.contains(painPointId)) {
      selectedPainPoints.remove(painPointId);
    } else {
      if (selectedPainPoints.length < 3) {
        selectedPainPoints.add(painPointId);
      } else {
        Get.snackbar(
          'ไม่สามารถเลือกได้',
          'สามารถเลือกได้สูงสุด 3 จุด',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
        );
        return;
      }
    }

    settings.value.selectedPainPoints = selectedPainPoints.toList();
    saveSettings();
  }

  void updateSelectedPainPoints(List<int> painPointIds) {
    if (painPointIds.length > 3) {
      Get.snackbar('ข้อผิดพลาด', 'สามารถเลือกได้สูงสุด 3 จุด');
      return;
    }

    selectedPainPoints.assignAll(painPointIds);
    settings.value.selectedPainPoints = painPointIds;
    saveSettings();
  }

  // Break periods management
  void addBreakPeriod(BreakPeriod breakPeriod) {
    settings.value.breakPeriods.add(breakPeriod);
    saveSettings();
  }

  void removeBreakPeriod(int index) {
    if (index < settings.value.breakPeriods.length) {
      settings.value.breakPeriods.removeAt(index);
      saveSettings();
    }
  }

  void updateBreakPeriod(int index, BreakPeriod breakPeriod) {
    if (index < settings.value.breakPeriods.length) {
      settings.value.breakPeriods[index] = breakPeriod;
      saveSettings();
    }
  }

  // Language settings
  void changeLanguage(String languageCode) {
    if (languageCode != settings.value.languageCode) {
      settings.value.languageCode = languageCode;
      currentLanguage.value = languageCode;

      // Update locale
      final locale = Locale(languageCode);
      Get.updateLocale(locale);

      saveSettings();
    }
  }

  // Reset methods
  Future<void> resetToDefaults() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('รีเซ็ตการตั้งค่า'),
          content: const Text(
            'คุณต้องการรีเซ็ตการตั้งค่าทั้งหมดกลับเป็นค่าเริ่มต้นใช่หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('รีเซ็ต'),
            ),
          ],
        ),
      );

      if (result == true) {
        final defaultSettings = UserSettings.createDefault();
        defaultSettings.hasRequestedPermissions =
            settings.value.hasRequestedPermissions;

        settings.value = defaultSettings;
        selectedPainPoints.assignAll(defaultSettings.selectedPainPoints);
        currentLanguage.value = defaultSettings.languageCode;

        await saveSettings();

        Get.snackbar(
          'รีเซ็ตแล้ว',
          'การตั้งค่าได้รับการรีเซ็ตเป็นค่าเริ่มต้น',
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade800,
        );
      }
    } catch (e) {
      print('Error resetting settings: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถรีเซ็ตการตั้งค่าได้');
    }
  }

  Future<void> factoryReset() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text('รีเซ็ตข้อมูลทั้งหมด'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'การดำเนินการนี้จะลบข้อมูลทั้งหมดในแอป ได้แก่:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• การตั้งค่าทั้งหมด'),
              Text('• ประวัติการออกกำลังกาย'),
              Text('• สถิติการใช้งาน'),
              Text('• ท่าออกกำลังกายที่สร้างเอง'),
              SizedBox(height: 12),
              Text(
                'ข้อมูลที่ลบแล้วจะไม่สามารถกู้คืนได้',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('ลบข้อมูลทั้งหมด'),
            ),
          ],
        ),
      );

      if (result == true) {
        isLoading.value = true;

        await DatabaseService.clearAllData();

        // Reset to defaults
        final defaultSettings = UserSettings.createDefault();
        settings.value = defaultSettings;
        selectedPainPoints.assignAll(defaultSettings.selectedPainPoints);
        currentLanguage.value = defaultSettings.languageCode;

        Get.snackbar(
          'รีเซ็ตแล้ว',
          'ข้อมูลทั้งหมดได้รับการลบและรีเซ็ตเรียบร้อย',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );

        // Navigate back to first time setup
        Get.offAllNamed('/first-time-setup');
      }
    } catch (e) {
      print('Error performing factory reset: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถรีเซ็ตข้อมูลได้');
    } finally {
      isLoading.value = false;
    }
  }

  // Export/Import methods
  Future<void> exportSettings() async {
    try {
      isLoading.value = true;

      final data = await DatabaseService.exportData();

      // Here you would typically save to file or share
      // For now, we'll just show success message
      Get.snackbar(
        'ส่งออกสำเร็จ',
        'ข้อมูลได้รับการส่งออกเรียบร้อย',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      // In a real implementation, you might:
      // - Save to downloads folder
      // - Share via email/messaging apps
      // - Copy to clipboard as JSON
    } catch (e) {
      print('Error exporting settings: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถส่งออกข้อมูลได้');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importSettings(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      await DatabaseService.importData(data);
      await loadSettings();

      Get.snackbar(
        'นำเข้าสำเร็จ',
        'ข้อมูลได้รับการนำเข้าเรียบร้อย',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      print('Error importing settings: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถนำเข้าข้อมูลได้');
    } finally {
      isLoading.value = false;
    }
  }

  // Getters for computed values
  String get formattedWorkTime {
    final start = settings.value.workStartTime;
    final end = settings.value.workEndTime;
    return "${start.format(Get.context!)} - ${end.format(Get.context!)}";
  }

  String get workingDaysText {
    final dayNames = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์',
    ];
    final selectedDays = settings.value.workingDays
        .map((day) => dayNames[day - 1])
        .toList();

    if (selectedDays.length == 7) {
      return 'ทุกวัน';
    } else if (selectedDays.length == 5 &&
        settings.value.workingDays.every((day) => day <= 5)) {
      return 'จันทร์-ศุกร์';
    } else {
      return selectedDays.join(', ');
    }
  }

  List<PainPoint> get selectedPainPointsData {
    return allPainPoints
        .where((pp) => selectedPainPoints.contains(pp.id))
        .toList();
  }

  bool isPainPointSelected(int painPointId) {
    return selectedPainPoints.contains(painPointId);
  }

  // Validation methods
  bool get isValidConfiguration {
    return selectedPainPoints.isNotEmpty &&
        settings.value.notificationInterval > 0 &&
        settings.value.workingDays.isNotEmpty;
  }

  String? validateNotificationInterval(int? value) {
    if (value == null || value <= 0) {
      return 'กรุณาระบุช่วงเวลาที่ถูกต้อง';
    }
    if (value < 15 || value > 120) {
      return 'ช่วงเวลาต้องอยู่ระหว่าง 15-120 นาที';
    }
    return null;
  }

  String? validateWorkingHours() {
    final start = settings.value.workStartTime;
    final end = settings.value.workEndTime;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes >= endMinutes) {
      return 'เวลาเริ่มต้องมาก่อนเวลาสิ้นสุด';
    }

    final diffMinutes = endMinutes - startMinutes;
    if (diffMinutes < settings.value.notificationInterval) {
      return 'เวลาทำงานต้องมากกว่าช่วงการแจ้งเตือน';
    }

    return null;
  }

  // Private methods
  void _notifySettingsChanged() {
    try {
      // Notify NotificationController
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().onSettingsChanged();
      }

      // Notify HomeController
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().onSettingsChanged();
      }

      print('Settings change notification sent to controllers');
    } catch (e) {
      print('Error notifying controllers: $e');
    }
  }

  // Refresh method for pull-to-refresh
  Future<void> refresh() async {
    await loadSettings();
    loadPainPoints();
  }
}
