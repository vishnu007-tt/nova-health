import 'package:hive/hive.dart';

part 'meditation_session_model.g.dart';

@HiveType(typeId: 8)
class MeditationSessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String type; // meditation, breathing

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  String? exerciseName; // e.g., "4-7-8 Breathing", "Box Breathing", "Guided Meditation"

  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool completed;

  @HiveField(8)
  DateTime createdAt;

  MeditationSessionModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.durationMinutes,
    this.exerciseName,
    this.notes,
    this.completed = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'durationMinutes': durationMinutes,
      'exerciseName': exerciseName,
      'notes': notes,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MeditationSessionModel.fromJson(Map<String, dynamic> json) {
    return MeditationSessionModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      durationMinutes: json['durationMinutes'],
      exerciseName: json['exerciseName'],
      notes: json['notes'],
      completed: json['completed'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
