import 'package:hive/hive.dart';

part 'mood_log_model.g.dart';

@HiveType(typeId: 7)
class MoodLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String mood; // great, good, okay, bad, terrible

  @HiveField(4)
  int intensity; // 1-10

  @HiveField(5)
  List<String> factors; // sleep, exercise, work, relationships, weather, etc.

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime createdAt;

  MoodLogModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mood,
    required this.intensity,
    this.factors = const [],
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
      'intensity': intensity,
      'factors': factors,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MoodLogModel.fromJson(Map<String, dynamic> json) {
    return MoodLogModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      mood: json['mood'],
      intensity: json['intensity'],
      factors: json['factors'] != null ? List<String>.from(json['factors']) : [],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
