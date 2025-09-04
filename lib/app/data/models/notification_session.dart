import 'package:hive/hive.dart';

part 'notification_session.g.dart';

@HiveType(typeId: 2)
class NotificationSession extends HiveObject {
  @HiveField(0)
  String id; // UUID

  @HiveField(1)
  DateTime scheduledTime;

  @HiveField(2)
  DateTime? actualTime;

  @HiveField(3)
  int painPointId;

  @HiveField(4)
  List<int> treatmentIds;

  @HiveField(5)
  SessionStatus status;

  @HiveField(6)
  int snoozeCount;

  @HiveField(7)
  DateTime? completedTime;

  @HiveField(8)
  List<bool> treatmentCompleted;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  int sessionDurationSeconds; // เก็บเวลาที่ใช้ทำท่า

  NotificationSession({
    required this.id,
    required this.scheduledTime,
    this.actualTime,
    required this.painPointId,
    required this.treatmentIds,
    this.status = SessionStatus.scheduled,
    this.snoozeCount = 0,
    this.completedTime,
    List<bool>? treatmentCompleted,
    DateTime? createdAt,
    this.sessionDurationSeconds = 0,
  }) : treatmentCompleted =
           treatmentCompleted ?? List.filled(treatmentIds.length, false),
       createdAt = createdAt ?? DateTime.now();

  // Helper methods
  bool get isCompleted => status == SessionStatus.completed;
  bool get isSkipped => status == SessionStatus.skipped;
  bool get isInProgress => status == SessionStatus.inProgress;

  bool get allTreatmentsCompleted =>
      treatmentCompleted.every((completed) => completed);

  int get completedTreatmentCount =>
      treatmentCompleted.where((completed) => completed).length;

  double get completionPercentage => treatmentCompleted.isEmpty
      ? 0.0
      : completedTreatmentCount / treatmentCompleted.length;

  String get formattedDuration {
    if (sessionDurationSeconds == 0) return '0:00';
    final minutes = sessionDurationSeconds ~/ 60;
    final seconds = sessionDurationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

@HiveType(typeId: 3)
enum SessionStatus {
  @HiveField(0)
  scheduled,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  completed,

  @HiveField(3)
  snoozed,

  @HiveField(4)
  skipped,
}

extension SessionStatusExtension on SessionStatus {
  String get displayName {
    switch (this) {
      case SessionStatus.scheduled:
        return 'รอดำเนินการ';
      case SessionStatus.inProgress:
        return 'กำลังทำ';
      case SessionStatus.completed:
        return 'ทำเสร็จ';
      case SessionStatus.snoozed:
        return 'เลื่อนเวลา';
      case SessionStatus.skipped:
        return 'ข้ามไป';
    }
  }

  String get displayNameEn {
    switch (this) {
      case SessionStatus.scheduled:
        return 'Scheduled';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.snoozed:
        return 'Snoozed';
      case SessionStatus.skipped:
        return 'Skipped';
    }
  }
}
