// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SymptomModelAdapter extends TypeAdapter<SymptomModel> {
  @override
  final int typeId = 4;

  @override
  SymptomModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SymptomModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      symptomType: fields[3] as String,
      severity: fields[4] as int,
      bodyPart: fields[5] as String?,
      notes: fields[6] as String?,
      triggers: (fields[7] as List?)?.cast<String>(),
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SymptomModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.symptomType)
      ..writeByte(4)
      ..write(obj.severity)
      ..writeByte(5)
      ..write(obj.bodyPart)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.triggers)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
