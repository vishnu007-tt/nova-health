import 'package:hive/hive.dart';

part 'symptom_model.g.dart';

@HiveType(typeId: 4)
class SymptomModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String symptomType; // headache, fatigue, nausea, pain, fever, dizziness, etc.

  @HiveField(4)
  int severity; // 1-10

  @HiveField(5)
  String? bodyPart; // for pain symptoms

  @HiveField(6)
  String? notes;

  @HiveField(7)
  List<String>? triggers; // possible triggers

  @HiveField(8)
  DateTime createdAt;

  SymptomModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.symptomType,
    required this.severity,
    this.bodyPart,
    this.notes,
    this.triggers,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'symptomType': symptomType,
      'severity': severity,
      'bodyPart': bodyPart,
      'notes': notes,
      'triggers': triggers,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      symptomType: json['symptomType'],
      severity: json['severity'],
      bodyPart: json['bodyPart'],
      notes: json['notes'],
      triggers: json['triggers'] != null ? List<String>.from(json['triggers']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
