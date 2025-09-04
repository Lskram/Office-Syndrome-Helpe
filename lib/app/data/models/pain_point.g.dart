// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pain_point.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PainPointAdapter extends TypeAdapter<PainPoint> {
  @override
  final int typeId = 5;

  @override
  PainPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PainPoint(
      id: fields[0] as int,
      nameTh: fields[1] as String,
      nameEn: fields[2] as String,
      descriptionTh: fields[3] as String,
      descriptionEn: fields[4] as String,
      iconName: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PainPoint obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameTh)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.descriptionTh)
      ..writeByte(4)
      ..write(obj.descriptionEn)
      ..writeByte(5)
      ..write(obj.iconName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PainPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
