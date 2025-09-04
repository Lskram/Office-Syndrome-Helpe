// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSessionAdapter extends TypeAdapter<NotificationSession> {
  @override
  final int typeId = 2;

  @override
  NotificationSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSession(
      id: fields[0] as String,
      scheduledTime: fields[1] as DateTime,
      actualTime: fields[2] as DateTime?,
      painPointId: fields[3] as int,
      treatmentIds: (fields[4] as List).cast<int>(),
      status: fields[5] as SessionStatus,
      snoozeCount: fields[6] as int,
      completedTime: fields[7] as DateTime?,
      treatmentCompleted: (fields[8] as List?)?.cast<bool>(),
      createdAt: fields[9] as DateTime?,
      sessionDurationSeconds: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scheduledTime)
      ..writeByte(2)
      ..write(obj.actualTime)
      ..writeByte(3)
      ..write(obj.painPointId)
      ..writeByte(4)
      ..write(obj.treatmentIds)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.snoozeCount)
      ..writeByte(7)
      ..write(obj.completedTime)
      ..writeByte(8)
      ..write(obj.treatmentCompleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.sessionDurationSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionStatusAdapter extends TypeAdapter<SessionStatus> {
  @override
  final int typeId = 3;

  @override
  SessionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SessionStatus.scheduled;
      case 1:
        return SessionStatus.inProgress;
      case 2:
        return SessionStatus.completed;
      case 3:
        return SessionStatus.snoozed;
      case 4:
        return SessionStatus.skipped;
      default:
        return SessionStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, SessionStatus obj) {
    switch (obj) {
      case SessionStatus.scheduled:
        writer.writeByte(0);
        break;
      case SessionStatus.inProgress:
        writer.writeByte(1);
        break;
      case SessionStatus.completed:
        writer.writeByte(2);
        break;
      case SessionStatus.snoozed:
        writer.writeByte(3);
        break;
      case SessionStatus.skipped:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
