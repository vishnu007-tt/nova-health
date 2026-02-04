// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeditationSessionModelAdapter
    extends TypeAdapter<MeditationSessionModel> {
  @override
  final int typeId = 8;

  @override
  MeditationSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationSessionModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      type: fields[3] as String,
      durationMinutes: fields[4] as int,
      exerciseName: fields[5] as String?,
      notes: fields[6] as String?,
      completed: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationSessionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.exerciseName)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
