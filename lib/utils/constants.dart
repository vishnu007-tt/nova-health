// App Constants
class AppConstants {
  // App Info
  static const String appName = 'NovaHealth';
  static const String appVersion = '1.0.0';

  // Colors
  static const int primaryGreen = 0xFF616F57;
  static const int darkGreen = 0xFF25460E;
  static const int lightGreen = 0xFFDFF7E1;
  static const int peach = 0xFFFFC8B6;
  static const int lightPeach = 0xFFFFCDBD;
  static const int accentGreen = 0x66CCE1BE;
  static const int mediumGreen = 0xE26E9552;

  // Database
  static const String userBox = 'user_box';
  static const String healthBox = 'health_box';
  static const String workoutBox = 'workout_box';
  static const String nutritionBox = 'nutrition_box';
  static const String settingsBox = 'settings_box';

  // Preferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';

  // 🔐 Health data consent
  static const String keyConsentGiven = 'consent_given';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minAge = 13;
  static const int maxAge = 120;

  // Activity Levels
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extra_active': 1.9,
  };

  // Health Metrics
  static const double waterIntakePerKg = 0.033; // liters per kg body weight
  static const int defaultWaterGoalMl = 2000;
  static const int defaultCalorieGoal = 2000;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int pageTransitionDuration = 300;
}
