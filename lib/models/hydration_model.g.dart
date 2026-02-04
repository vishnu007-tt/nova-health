// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydration_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HydrationModelAdapter extends TypeAdapter<HydrationModel> {
  @override
  final int typeId = 2;

  @override
  HydrationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HydrationModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      amountMl: fields[3] as int,
      beverageType: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HydrationModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.amountMl)
      ..writeByte(4)
      ..write(obj.beverageType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HydrationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
