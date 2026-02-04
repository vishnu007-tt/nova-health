// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeModelAdapter extends TypeAdapter<RecipeModel> {
  @override
  final int typeId = 9;

  @override
  RecipeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      prepTimeMinutes: fields[3] as int,
      cookTimeMinutes: fields[4] as int,
      servings: fields[5] as int,
      ingredients: (fields[6] as List).cast<String>(),
      instructions: (fields[7] as List).cast<String>(),
      calories: fields[8] as double,
      protein: fields[9] as double,
      carbs: fields[10] as double,
      fats: fields[11] as double,
      imageUrl: fields[12] as String?,
      tags: (fields[13] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecipeModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.prepTimeMinutes)
      ..writeByte(4)
      ..write(obj.cookTimeMinutes)
      ..writeByte(5)
      ..write(obj.servings)
      ..writeByte(6)
      ..write(obj.ingredients)
      ..writeByte(7)
      ..write(obj.instructions)
      ..writeByte(8)
      ..write(obj.calories)
      ..writeByte(9)
      ..write(obj.protein)
      ..writeByte(10)
      ..write(obj.carbs)
      ..writeByte(11)
      ..write(obj.fats)
      ..writeByte(12)
      ..write(obj.imageUrl)
      ..writeByte(13)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
