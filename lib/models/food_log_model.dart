import 'package:hive/hive.dart';

part 'food_log_model.g.dart';

@HiveType(typeId: 6)
class FoodLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String mealType; // breakfast, lunch, dinner, snack

  @HiveField(4)
  String foodName;

  @HiveField(5)
  double servingSize;

  @HiveField(6)
  String servingUnit; // g, ml, cup, piece, etc.

  @HiveField(7)
  double calories;

  @HiveField(8)
  double protein; // in grams

  @HiveField(9)
  double carbs; // in grams

  @HiveField(10)
  double fats; // in grams

  @HiveField(11)
  double? fiber; // in grams

  @HiveField(12)
  double? sugar; // in grams

  @HiveField(13)
  String? notes;

  @HiveField(14)
  DateTime createdAt;

  FoodLogModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mealType,
    required this.foodName,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber,
    this.sugar,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'mealType': mealType,
      'foodName': foodName,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodLogModel.fromJson(Map<String, dynamic> json) {
    return FoodLogModel(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      mealType: json['mealType'],
      foodName: json['foodName'],
      servingSize: json['servingSize'].toDouble(),
      servingUnit: json['servingUnit'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
