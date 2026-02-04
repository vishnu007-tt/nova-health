// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodLogModelAdapter extends TypeAdapter<MoodLogModel> {
  @override
  final int typeId = 7;

  @override
  MoodLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      mood: fields[3] as String,
      intensity: fields[4] as int,
      factors: (fields[5] as List).cast<String>(),
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MoodLogModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.intensity)
      ..writeByte(5)
      ..write(obj.factors)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
