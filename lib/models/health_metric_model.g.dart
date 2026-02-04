// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_metric_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthMetricModelAdapter extends TypeAdapter<HealthMetricModel> {
  @override
  final int typeId = 3;

  @override
  HealthMetricModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthMetricModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      weight: fields[3] as double?,
      steps: fields[4] as int?,
      sleepMinutes: fields[5] as int?,
      mood: fields[6] as String?,
      stressLevel: fields[7] as int?,
      energyLevel: fields[8] as int?,
      notes: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      isPeriodDay: fields[11] as bool,
      flowIntensity: fields[12] as String?,
      periodSymptoms: (fields[13] as List?)?.cast<String>(),
      cycleDay: fields[14] as int?,
      symptoms: (fields[15] as List?)?.cast<String>(),
      symptomSeverity: (fields[16] as Map?)?.cast<String, int>(),
      symptomBodyParts: (fields[17] as Map?)?.cast<String, String>(),
      symptomTriggers: (fields[18] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HealthMetricModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.steps)
      ..writeByte(5)
      ..write(obj.sleepMinutes)
      ..writeByte(6)
      ..write(obj.mood)
      ..writeByte(7)
      ..write(obj.stressLevel)
      ..writeByte(8)
      ..write(obj.energyLevel)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.isPeriodDay)
      ..writeByte(12)
      ..write(obj.flowIntensity)
      ..writeByte(13)
      ..write(obj.periodSymptoms)
      ..writeByte(14)
      ..write(obj.cycleDay)
      ..writeByte(15)
      ..write(obj.symptoms)
      ..writeByte(16)
      ..write(obj.symptomSeverity)
      ..writeByte(17)
      ..write(obj.symptomBodyParts)
      ..writeByte(18)
      ..write(obj.symptomTriggers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetricModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
