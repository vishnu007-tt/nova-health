import 'package:hive/hive.dart';

part 'hydration_model.g.dart';

@HiveType(typeId: 2)
class HydrationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  int amountMl;

  @HiveField(4)
  String beverageType; // water, tea, coffee, juice, etc.

  HydrationModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.amountMl,
    this.beverageType = 'water',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'amountMl': amountMl,
      'beverageType': beverageType,
    };
  }

  factory HydrationModel.fromJson(Map<String, dynamic> json) {
    return HydrationModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      amountMl: json['amountMl'],
      beverageType: json['beverageType'] ?? 'water',
    );
  }
}
