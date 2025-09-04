// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TreatmentAdapter extends TypeAdapter<Treatment> {
  @override
  final int typeId = 4;

  @override
  Treatment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Treatment(
      id: fields[0] as int,
      nameTh: fields[1] as String,
      nameEn: fields[2] as String,
      descriptionTh: fields[3] as String,
      descriptionEn: fields[4] as String,
      durationSeconds: fields[5] as int,
      painPointId: fields[6] as int,
      isCustom: fields[7] as bool,
      createdAt: fields[8] as DateTime?,
      imageUrl: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Treatment obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.painPointId)
      ..writeByte(7)
      ..write(obj.isCustom)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreatmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
