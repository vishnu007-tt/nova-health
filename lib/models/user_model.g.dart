// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      username: fields[2] as String,
      fullName: fields[3] as String?,
      gender: fields[4] as String?,
      dateOfBirth: fields[5] as DateTime?,
      weight: fields[6] as double?,
      height: fields[7] as double?,
      phone: fields[8] as String?,
      profilePictureUrl: fields[9] as String?,
      activityLevel: fields[10] as String,
      healthGoal: fields[11] as String,
      targetWeight: fields[12] as double?,
      dailyCalorieGoal: fields[13] as int,
      dailyWaterGoalMl: fields[14] as int,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      notificationPreferences: (fields[17] as Map?)?.cast<String, bool>(),
      dietaryPreference: fields[18] as String?,
      allergies: (fields[19] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.dateOfBirth)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.height)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.profilePictureUrl)
      ..writeByte(10)
      ..write(obj.activityLevel)
      ..writeByte(11)
      ..write(obj.healthGoal)
      ..writeByte(12)
      ..write(obj.targetWeight)
      ..writeByte(13)
      ..write(obj.dailyCalorieGoal)
      ..writeByte(14)
      ..write(obj.dailyWaterGoalMl)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.notificationPreferences)
      ..writeByte(18)
      ..write(obj.dietaryPreference)
      ..writeByte(19)
      ..write(obj.allergies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
