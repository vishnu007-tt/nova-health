import 'package:hive/hive.dart';

part 'health_metric_model.g.dart';

@HiveType(typeId: 3)
class HealthMetricModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  double? weight; // in kg

  @HiveField(4)
  int? steps;

  @HiveField(5)
  int? sleepMinutes;

  @HiveField(6)
  String? mood; // happy, sad, anxious, calm, stressed

  @HiveField(7)
  int? stressLevel; // 1-10

  @HiveField(8)
  int? energyLevel; // 1-10

  @HiveField(9)
  String? notes;

  @HiveField(10)
  DateTime createdAt;

  // Period tracking fields
  @HiveField(11)
  bool isPeriodDay; // Is this a period day?

  @HiveField(12)
  String? flowIntensity; // light, medium, heavy

  @HiveField(13)
  List<String>? periodSymptoms; // cramps, headache, mood_swings, fatigue, bloating, etc.

  @HiveField(14)
  int? cycleDay; // Day of the menstrual cycle

  // Symptom tracking fields
  @HiveField(15)
  List<String>? symptoms; // List of symptom types (headache, fatigue, nausea, pain, etc.)

  @HiveField(16)
  Map<String, int>? symptomSeverity; // Map of symptom to severity (1-10)

  @HiveField(17)
  Map<String, String>? symptomBodyParts; // Map of symptom to affected body part

  @HiveField(18)
  List<String>? symptomTriggers; // Possible triggers for symptoms

  HealthMetricModel({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.steps,
    this.sleepMinutes,
    this.mood,
    this.stressLevel,
    this.energyLevel,
    this.notes,
    required this.createdAt,
    this.isPeriodDay = false,
    this.flowIntensity,
    this.periodSymptoms,
    this.cycleDay,
    this.symptoms,
    this.symptomSeverity,
    this.symptomBodyParts,
    this.symptomTriggers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'steps': steps,
      'sleepMinutes': sleepMinutes,
      'mood': mood,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'isPeriodDay': isPeriodDay,
      'flowIntensity': flowIntensity,
      'periodSymptoms': periodSymptoms,
      'cycleDay': cycleDay,
      'symptoms': symptoms,
      'symptomSeverity': symptomSeverity,
      'symptomBodyParts': symptomBodyParts,
      'symptomTriggers': symptomTriggers,
    };
  }

  factory HealthMetricModel.fromJson(Map<String, dynamic> json) {
    return HealthMetricModel(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble(),
      steps: json['steps'],
      sleepMinutes: json['sleepMinutes'],
      mood: json['mood'],
      stressLevel: json['stressLevel'],
      energyLevel: json['energyLevel'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      isPeriodDay: json['isPeriodDay'] ?? false,
      flowIntensity: json['flowIntensity'],
      periodSymptoms: json['periodSymptoms'] != null ? List<String>.from(json['periodSymptoms']) : null,
      cycleDay: json['cycleDay'],
      symptoms: json['symptoms'] != null ? List<String>.from(json['symptoms']) : null,
      symptomSeverity: json['symptomSeverity'] != null ? Map<String, int>.from(json['symptomSeverity']) : null,
      symptomBodyParts: json['symptomBodyParts'] != null ? Map<String, String>.from(json['symptomBodyParts']) : null,
      symptomTriggers: json['symptomTriggers'] != null ? List<String>.from(json['symptomTriggers']) : null,
    );
  }
}
