import 'package:hive/hive.dart';

part 'meal_plan_model.g.dart';

@HiveType(typeId: 9)
class RecipeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category; // breakfast, lunch, dinner, snack, dessert

  @HiveField(3)
  int prepTimeMinutes;

  @HiveField(4)
  int cookTimeMinutes;

  @HiveField(5)
  int servings;

  @HiveField(6)
  List<String> ingredients;

  @HiveField(7)
  List<String> instructions;

  @HiveField(8)
  double calories;

  @HiveField(9)
  double protein;

  @HiveField(10)
  double carbs;

  @HiveField(11)
  double fats;

  @HiveField(12)
  String? imageUrl;

  @HiveField(13)
  List<String>? tags; // vegetarian, vegan, gluten-free, etc.

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.imageUrl,
    this.tags,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      prepTimeMinutes: json['prepTimeMinutes'],
      cookTimeMinutes: json['cookTimeMinutes'],
      servings: json['servings'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      imageUrl: json['imageUrl'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
