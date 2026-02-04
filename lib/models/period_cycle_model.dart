import 'package:hive/hive.dart';

part 'period_cycle_model.g.dart';

@HiveType(typeId: 5)
class PeriodCycleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  DateTime? endDate;

  @HiveField(4)
  String flowIntensity; // light, medium, heavy

  @HiveField(5)
  List<String> symptoms; // cramps, headache, mood_swings, fatigue, bloating, etc.

  @HiveField(6)
  String? mood; // happy, irritable, sad, anxious, etc.

  @HiveField(7)
  String? notes;

  @HiveField(8)
  int? cycleLength; // calculated from previous cycle

  @HiveField(9)
  DateTime createdAt;

  PeriodCycleModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.flowIntensity = 'medium',
    this.symptoms = const [],
    this.mood,
    this.notes,
    this.cycleLength,
    required this.createdAt,
  });

  // Calculate period length in days
  int? get periodLength {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays + 1;
  }

  // Check if period is active
  bool get isActive {
    return endDate == null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'flowIntensity': flowIntensity,
      'symptoms': symptoms,
      'mood': mood,
      'notes': notes,
      'cycleLength': cycleLength,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PeriodCycleModel.fromJson(Map<String, dynamic> json) {
    return PeriodCycleModel(
      id: json['id'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      flowIntensity: json['flowIntensity'] ?? 'medium',
      symptoms: json['symptoms'] != null ? List<String>.from(json['symptoms']) : [],
      mood: json['mood'],
      notes: json['notes'],
      cycleLength: json['cycleLength'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
