import 'package:intl/intl.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Calculate BMI
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor formula
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    const multipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'extra_active': 1.9,
    };
    return bmr * (multipliers[activityLevel] ?? 1.2);
  }

  // Calculate recommended water intake in ml
  static int calculateWaterIntake(double weightKg, {String activityLevel = 'sedentary'}) {
    double baseIntake = weightKg * 33; // 33ml per kg

    // Add extra for activity level
    if (activityLevel == 'moderately_active') {
      baseIntake *= 1.1;
    } else if (activityLevel == 'very_active' || activityLevel == 'extra_active') {
      baseIntake *= 1.2;
    }

    return baseIntake.round();
  }

  // Calculate calories burned for activity (MET-based)
  static double calculateCaloriesBurned({
    required double met,
    required double weightKg,
    required double durationMinutes,
  }) {
    // Calories = MET × weight(kg) × duration(hours)
    return met * weightKg * (durationMinutes / 60);
  }

  // Format calories
  static String formatCalories(double calories) {
    return '${calories.toStringAsFixed(0)} kcal';
  }

  // Format weight
  static String formatWeight(double weightKg) {
    return '${weightKg.toStringAsFixed(1)} kg';
  }

  // Format height
  static String formatHeight(double heightCm) {
    return '${heightCm.toStringAsFixed(0)} cm';
  }

  // Format water amount
  static String formatWater(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  // Calculate age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Calculate percentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // Clamp value between min and max
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // Parse date string to DateTime
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Validate and parse double
  static double? parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  // Validate and parse int
  static int? parseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }
}
