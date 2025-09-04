// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 0;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      selectedPainPoints: (fields[0] as List).cast<int>(),
      notificationInterval: fields[1] as int,
      workStartTimeString: fields[2] as String,
      workEndTimeString: fields[3] as String,
      workingDays: (fields[4] as List).cast<int>(),
      breakPeriods: (fields[5] as List).cast<BreakPeriod>(),
      soundEnabled: fields[6] as bool,
      vibrationEnabled: fields[7] as bool,
      notificationEnabled: fields[8] as bool,
      maxSnoozeCount: fields[9] as int,
      hasRequestedPermissions: fields[10] as bool,
      lastNotificationTime: fields[11] as DateTime?,
      currentSessionId: fields[12] as String?,
      languageCode: fields[13] as String,
      appVersion: fields[14] as int,
      dbVersion: fields[15] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.selectedPainPoints)
      ..writeByte(1)
      ..write(obj.notificationInterval)
      ..writeByte(2)
      ..write(obj.workStartTimeString)
      ..writeByte(3)
      ..write(obj.workEndTimeString)
      ..writeByte(4)
      ..write(obj.workingDays)
      ..writeByte(5)
      ..write(obj.breakPeriods)
      ..writeByte(6)
      ..write(obj.soundEnabled)
      ..writeByte(7)
      ..write(obj.vibrationEnabled)
      ..writeByte(8)
      ..write(obj.notificationEnabled)
      ..writeByte(9)
      ..write(obj.maxSnoozeCount)
      ..writeByte(10)
      ..write(obj.hasRequestedPermissions)
      ..writeByte(11)
      ..write(obj.lastNotificationTime)
      ..writeByte(12)
      ..write(obj.currentSessionId)
      ..writeByte(13)
      ..write(obj.languageCode)
      ..writeByte(14)
      ..write(obj.appVersion)
      ..writeByte(15)
      ..write(obj.dbVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BreakPeriodAdapter extends TypeAdapter<BreakPeriod> {
  @override
  final int typeId = 1;

  @override
  BreakPeriod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreakPeriod(
      startTimeString: fields[0] as String,
      endTimeString: fields[1] as String,
      name: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BreakPeriod obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startTimeString)
      ..writeByte(1)
      ..write(obj.endTimeString)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreakPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
