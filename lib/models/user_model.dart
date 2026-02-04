import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String username;

  @HiveField(3)
  String? fullName;

  @HiveField(4)
  String? gender;

  @HiveField(5)
  DateTime? dateOfBirth;

  @HiveField(6)
  double? weight; // in kg

  @HiveField(7)
  double? height; // in cm

  @HiveField(8)
  String? phone;

  @HiveField(9)
  String? profilePictureUrl;

  @HiveField(10)
  String activityLevel; // sedentary, lightly_active, moderately_active, very_active, extra_active

  @HiveField(11)
  String healthGoal; // weight_loss, weight_gain, maintenance, fitness

  @HiveField(12)
  double? targetWeight;

  @HiveField(13)
  int dailyCalorieGoal;

  @HiveField(14)
  int dailyWaterGoalMl;

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  @HiveField(17)
  Map<String, bool>? notificationPreferences;

  @HiveField(18)
  String? dietaryPreference; // standard, vegetarian, vegan, keto, etc.

  @HiveField(19)
  List<String>? allergies;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.weight,
    this.height,
    this.phone,
    this.profilePictureUrl,
    this.activityLevel = 'sedentary',
    this.healthGoal = 'maintenance',
    this.targetWeight,
    this.dailyCalorieGoal = 2000,
    this.dailyWaterGoalMl = 2000,
    required this.createdAt,
    required this.updatedAt,
    this.notificationPreferences,
    this.dietaryPreference,
    this.allergies,
  });

  // Calculate age
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Calculate BMI
  double? get bmi {
    if (weight == null || height == null) return null;
    final heightM = height! / 100;
    return weight! / (heightM * heightM);
  }

  // Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate BMR
  double? get bmr {
    if (weight == null || height == null || age == null) return null;
    final isMale = gender?.toLowerCase() == 'male';
    if (isMale) {
      return (10 * weight!) + (6.25 * height!) - (5 * age!) + 5;
    } else {
      return (10 * weight!) + (6.25 * height!) - (5 * age!) - 161;
    }
  }

  // Calculate TDEE
  double? get tdee {
    final bmrValue = bmr;
    if (bmrValue == null) return null;

    const multipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'extra_active': 1.9,
    };

    return bmrValue * (multipliers[activityLevel] ?? 1.2);
  }

  // Copy with
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    double? weight,
    double? height,
    String? phone,
    String? profilePictureUrl,
    String? activityLevel,
    String? healthGoal,
    double? targetWeight,
    int? dailyCalorieGoal,
    int? dailyWaterGoalMl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, bool>? notificationPreferences,
    String? dietaryPreference,
    List<String>? allergies,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      activityLevel: activityLevel ?? this.activityLevel,
      healthGoal: healthGoal ?? this.healthGoal,
      targetWeight: targetWeight ?? this.targetWeight,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      allergies: allergies ?? this.allergies,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'weight': weight,
      'height': height,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'activityLevel': activityLevel,
      'healthGoal': healthGoal,
      'targetWeight': targetWeight,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notificationPreferences': notificationPreferences,
      'dietaryPreference': dietaryPreference,
      'allergies': allergies,
    };
  }

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      phone: json['phone'],
      profilePictureUrl: json['profilePictureUrl'],
      activityLevel: json['activityLevel'] ?? 'sedentary',
      healthGoal: json['healthGoal'] ?? 'maintenance',
      targetWeight: json['targetWeight']?.toDouble(),
      dailyCalorieGoal: json['dailyCalorieGoal'] ?? 2000,
      dailyWaterGoalMl: json['dailyWaterGoalMl'] ?? 2000,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notificationPreferences: json['notificationPreferences'] != null
          ? Map<String, bool>.from(json['notificationPreferences'])
          : null,
      dietaryPreference: json['dietaryPreference'],
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : null,
    );
  }
}
