// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodLogModelAdapter extends TypeAdapter<FoodLogModel> {
  @override
  final int typeId = 6;

  @override
  FoodLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      mealType: fields[3] as String,
      foodName: fields[4] as String,
      servingSize: fields[5] as double,
      servingUnit: fields[6] as String,
      calories: fields[7] as double,
      protein: fields[8] as double,
      carbs: fields[9] as double,
      fats: fields[10] as double,
      fiber: fields[11] as double?,
      sugar: fields[12] as double?,
      notes: fields[13] as String?,
      createdAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FoodLogModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.foodName)
      ..writeByte(5)
      ..write(obj.servingSize)
      ..writeByte(6)
      ..write(obj.servingUnit)
      ..writeByte(7)
      ..write(obj.calories)
      ..writeByte(8)
      ..write(obj.protein)
      ..writeByte(9)
      ..write(obj.carbs)
      ..writeByte(10)
      ..write(obj.fats)
      ..writeByte(11)
      ..write(obj.fiber)
      ..writeByte(12)
      ..write(obj.sugar)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
