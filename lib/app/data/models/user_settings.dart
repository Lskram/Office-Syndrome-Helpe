import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings extends HiveObject {
  @HiveField(0)
  List<int> selectedPainPoints;

  @HiveField(1)
  int notificationInterval; // นาที

  @HiveField(2)
  String workStartTimeString; // Format: "HH:mm"

  @HiveField(3)
  String workEndTimeString; // Format: "HH:mm"

  @HiveField(4)
  List<int> workingDays; // 1=จันทร์, 7=อาทิตย์

  @HiveField(5)
  List<BreakPeriod> breakPeriods;

  @HiveField(6)
  bool soundEnabled;

  @HiveField(7)
  bool vibrationEnabled;

  @HiveField(8)
  bool notificationEnabled;

  @HiveField(9)
  int maxSnoozeCount;

  @HiveField(10)
  bool hasRequestedPermissions;

  @HiveField(11)
  DateTime? lastNotificationTime;

  @HiveField(12)
  String? currentSessionId;

  @HiveField(13)
  String languageCode; // 'th' หรือ 'en'

  @HiveField(14)
  int appVersion;

  @HiveField(15)
  int dbVersion;

  UserSettings({
    this.selectedPainPoints = const [3, 4, 5], // คอ, บ่าไหล่, หลังบน
    this.notificationInterval = 60,
    this.workStartTimeString = "09:00",
    this.workEndTimeString = "17:00",
    this.workingDays = const [1, 2, 3, 4, 5], // จันทร์-ศุกร์
    this.breakPeriods = const [],
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationEnabled = true,
    this.maxSnoozeCount = 3,
    this.hasRequestedPermissions = false,
    this.lastNotificationTime,
    this.currentSessionId,
    this.languageCode = 'th',
    this.appVersion = 1,
    this.dbVersion = 1,
  });

  // Helper getters
  TimeOfDay get workStartTime {
    final parts = workStartTimeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  set workStartTime(TimeOfDay time) {
    workStartTimeString =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  TimeOfDay get workEndTime {
    final parts = workEndTimeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  set workEndTime(TimeOfDay time) {
    workEndTimeString =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // Create default settings
  static UserSettings createDefault() {
    return UserSettings(
      breakPeriods: [
        BreakPeriod(startTime: "12:00", endTime: "13:30", name: "พักกลางวัน"),
      ],
    );
  }
}

@HiveType(typeId: 1)
class BreakPeriod extends HiveObject {
  @HiveField(0)
  String startTimeString;

  @HiveField(1)
  String endTimeString;

  @HiveField(2)
  String name;

  BreakPeriod({
    required this.startTimeString,
    required this.endTimeString,
    required this.name,
  });

  // Helper getters
  TimeOfDay get startTime {
    final parts = startTimeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  set startTime(TimeOfDay time) {
    startTimeString =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  TimeOfDay get endTime {
    final parts = endTimeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  set endTime(TimeOfDay time) {
    endTimeString =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
