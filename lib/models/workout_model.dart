import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 1)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String activityType; // running, cycling, swimming, gym, yoga, etc.

  @HiveField(4)
  double durationMinutes;

  @HiveField(5)
  String intensity; // light, moderate, vigorous

  @HiveField(6)
  double? distance; // in km, optional for cardio

  @HiveField(7)
  double caloriesBurned;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.activityType,
    required this.durationMinutes,
    required this.intensity,
    this.distance,
    required this.caloriesBurned,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'activityType': activityType,
      'durationMinutes': durationMinutes,
      'intensity': intensity,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      activityType: json['activityType'],
      durationMinutes: json['durationMinutes'].toDouble(),
      intensity: json['intensity'],
      distance: json['distance']?.toDouble(),
      caloriesBurned: json['caloriesBurned'].toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
