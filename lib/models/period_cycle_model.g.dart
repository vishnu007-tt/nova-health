// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_cycle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodCycleModelAdapter extends TypeAdapter<PeriodCycleModel> {
  @override
  final int typeId = 5;

  @override
  PeriodCycleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodCycleModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime?,
      flowIntensity: fields[4] as String,
      symptoms: (fields[5] as List).cast<String>(),
      mood: fields[6] as String?,
      notes: fields[7] as String?,
      cycleLength: fields[8] as int?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PeriodCycleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.flowIntensity)
      ..writeByte(5)
      ..write(obj.symptoms)
      ..writeByte(6)
      ..write(obj.mood)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.cycleLength)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodCycleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
