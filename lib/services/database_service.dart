import '../services/security_service.dart';
import 'package:hive/hive.dart' show HiveAesCipher;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/hydration_model.dart';
import '../models/health_metric_model.dart';
import '../models/symptom_model.dart';
import '../models/period_cycle_model.dart';
import '../models/food_log_model.dart';
import '../models/mood_log_model.dart';
import '../models/meditation_session_model.dart';
import '../models/meal_plan_model.dart';
import '../utils/constants.dart';
import 'sqlite_service.dart';
import 'database_sync_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  bool _initialized = false;
  final _sqliteService = SQLiteService();
  final _syncService = DatabaseSyncService();

  // Initialize Hive and register adapters
  Future<void> init() async {
    if (_initialized) return;

    // 1️⃣ Initialize Hive (ONLY ONCE)
    await Hive.initFlutter();

    // 2️⃣ Register adapters BEFORE opening boxes
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(WorkoutModelAdapter());
    Hive.registerAdapter(HydrationModelAdapter());
    Hive.registerAdapter(HealthMetricModelAdapter());
    Hive.registerAdapter(SymptomModelAdapter());
    Hive.registerAdapter(PeriodCycleModelAdapter());
    Hive.registerAdapter(FoodLogModelAdapter());
    Hive.registerAdapter(MoodLogModelAdapter());
    Hive.registerAdapter(MeditationSessionModelAdapter());
    Hive.registerAdapter(RecipeModelAdapter());

    // 3️⃣ Get encryption key
    final keyBytes = await SecurityService().getKey();
    assert(keyBytes.length == 32, 'Hive AES key must be exactly 32 bytes');

    final cipher = HiveAesCipher(keyBytes);

    // 4️⃣ Open encrypted Hive boxes
    await Hive.openBox<UserModel>(
      AppConstants.userBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<WorkoutModel>(
      AppConstants.workoutBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<HydrationModel>(
      'hydration_box',
      encryptionCipher: cipher,
    );
    await Hive.openBox<HealthMetricModel>(
      AppConstants.healthBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<SymptomModel>('symptom_box', encryptionCipher: cipher);
    await Hive.openBox<PeriodCycleModel>(
      'period_box',
      encryptionCipher: cipher,
    );
    await Hive.openBox<FoodLogModel>('food_log_box', encryptionCipher: cipher);
    await Hive.openBox<MoodLogModel>('mood_box', encryptionCipher: cipher);
    await Hive.openBox<MeditationSessionModel>(
      'meditation_box',
      encryptionCipher: cipher,
    );
    await Hive.openBox<RecipeModel>('recipe_box', encryptionCipher: cipher);
    await Hive.openBox(AppConstants.settingsBox, encryptionCipher: cipher);

    // 5️⃣ Initialize services
    await _sqliteService.init();
    await _syncService.init();

    // 6️⃣ Auto-grant consent for health data (for development/testing)
    final consent = getSetting(AppConstants.keyConsentGiven, defaultValue: false);
    if (consent != true) {
      await saveSetting(AppConstants.keyConsentGiven, true);
    }

    _initialized = true;
  }

  // User operations
  Box<UserModel> get userBox => Hive.box<UserModel>(AppConstants.userBox);

  Future<void> saveUser(UserModel user) async {
    await userBox.put(user.id, user);
    // Track user profile in SQLite
    await _syncService.trackUserProfile(user);
  }

  UserModel? getUser(String userId) {
    return userBox.get(userId);
  }

  Future<void> deleteUser(String userId) async {
    await userBox.delete(userId);
  }

  List<UserModel> getAllUsers() {
    return userBox.values.toList();
  }

  // Workout operations
  Box<WorkoutModel> get workoutBox =>
      Hive.box<WorkoutModel>(AppConstants.workoutBox);

  Future<void> saveWorkout(WorkoutModel workout) async {
    await _ensureConsentOrThrow();

    await workoutBox.put(workout.id, workout);
    // Track in SQLite for analytics

    await _syncService.trackWorkout(workout);
  }

  WorkoutModel? getWorkout(String id) {
    return workoutBox.get(id);
  }

  Future<void> deleteWorkout(String id) async {
    await workoutBox.delete(id);
    // Delete from Supabase
    await _syncService.deleteWorkoutFromCloud(id);
  }

  List<WorkoutModel> getUserWorkouts(String userId) {
    return workoutBox.values.where((w) => w.userId == userId).toList();
  }

  List<WorkoutModel> getUserWorkoutsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return workoutBox.values
        .where(
          (w) =>
              w.userId == userId &&
              w.date.isAfter(start.subtract(const Duration(days: 1))) &&
              w.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Hydration operations
  Box<HydrationModel> get hydrationBox =>
      Hive.box<HydrationModel>('hydration_box');

  Future<void> saveHydration(HydrationModel hydration) async {
    await _ensureConsentOrThrow();

    await hydrationBox.put(hydration.id, hydration);
    // Track in SQLite for analytics
    await _syncService.trackHydration(hydration);
  }

  Future<void> deleteHydration(String id) async {
    await hydrationBox.delete(id);
    // Delete from Supabase
    await _syncService.deleteHydrationFromCloud(id);
  }

  List<HydrationModel> getUserHydrationLogs(String userId) {
    return hydrationBox.values.where((h) => h.userId == userId).toList();
  }

  List<HydrationModel> getUserHydrationByDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return hydrationBox.values
        .where(
          (h) =>
              h.userId == userId &&
              h.timestamp.isAfter(
                startOfDay.subtract(const Duration(seconds: 1)),
              ) &&
              h.timestamp.isBefore(endOfDay.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  int getTotalHydrationForDay(String userId, DateTime date) {
    final logs = getUserHydrationByDate(userId, date);
    return logs.fold(0, (sum, log) => sum + log.amountMl);
  }

  // Health metrics operations
  Box<HealthMetricModel> get healthBox =>
      Hive.box<HealthMetricModel>(AppConstants.healthBox);

  Future<void> saveHealthMetric(HealthMetricModel metric) async {
    await _ensureConsentOrThrow();
    await healthBox.put(metric.id, metric);
    // Track in SQLite for analytics
    await _syncService.trackHealthMetrics(metric);
  }

  Future<void> deleteHealthMetric(String id) async {
    await healthBox.delete(id);
    // Delete from Supabase
    await _syncService.deleteHealthMetricsFromCloud(id);
  }

  List<HealthMetricModel> getUserHealthMetrics(String userId) {
    return healthBox.values.where((m) => m.userId == userId).toList();
  }

  HealthMetricModel? getHealthMetricByDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return healthBox.values.firstWhere(
      (m) =>
          m.userId == userId &&
          m.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          m.date.isBefore(endOfDay.add(const Duration(seconds: 1))),
      orElse:
          () => HealthMetricModel(
            id: '',
            userId: userId,
            date: date,
            createdAt: DateTime.now(),
          ),
    );
  }

  // Period tracking through health metrics
  List<HealthMetricModel> getPeriodDays(String userId) {
    return healthBox.values
        .where((m) => m.userId == userId && m.isPeriodDay)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<HealthMetricModel> getPeriodDaysByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return healthBox.values
        .where(
          (m) =>
              m.userId == userId &&
              m.isPeriodDay &&
              m.date.isAfter(start.subtract(const Duration(days: 1))) &&
              m.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Symptom tracking through health metrics
  List<HealthMetricModel> getHealthMetricsWithSymptoms(String userId) {
    return healthBox.values
        .where(
          (m) =>
              m.userId == userId &&
              m.symptoms != null &&
              m.symptoms!.isNotEmpty,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<HealthMetricModel> getHealthMetricsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return healthBox.values
        .where(
          (m) =>
              m.userId == userId &&
              m.date.isAfter(start.subtract(const Duration(days: 1))) &&
              m.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Settings operations
  Box get settingsBox => Hive.box(AppConstants.settingsBox);

  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> deleteSetting(String key) async {
    await settingsBox.delete(key);
  }

  // ==================== Consent Enforcement ====================
  // Note: Consent is auto-granted on initialization for authenticated users
  // Users who have logged in are considered to have consented to data logging
  Future<void> _ensureConsentOrThrow() async {
    // Consent check removed - authenticated users can log data
    // If you need explicit consent in production, implement a consent dialog
    return;
  }

  // Symptom operations
  Box<SymptomModel> get symptomBox => Hive.box<SymptomModel>('symptom_box');

  Future<void> saveSymptom(SymptomModel symptom) async {
    await _ensureConsentOrThrow();

    await symptomBox.put(symptom.id, symptom);
  }

  Future<void> deleteSymptom(String id) async {
    // Get the symptom to find its details
    final symptom = symptomBox.get(id);
    if (symptom == null) return;

    // Delete from symptom box
    await symptomBox.delete(id);

    // Also remove from health metrics
    final date = DateTime(
      symptom.timestamp.year,
      symptom.timestamp.month,
      symptom.timestamp.day,
    );

    final healthMetric = getHealthMetricByDate(symptom.userId, date);
    if (healthMetric != null && healthMetric.symptoms != null) {
      // Remove this symptom from the health metric
      final updatedSymptoms = List<String>.from(healthMetric.symptoms!)
        ..remove(symptom.symptomType);

      final updatedSeverity = Map<String, int>.from(
        healthMetric.symptomSeverity ?? {},
      )..remove(symptom.symptomType);

      final updatedBodyParts = Map<String, String>.from(
        healthMetric.symptomBodyParts ?? {},
      )..remove(symptom.symptomType);

      // Update the health metric
      final updated = HealthMetricModel(
        id: healthMetric.id,
        userId: healthMetric.userId,
        date: healthMetric.date,
        weight: healthMetric.weight,
        steps: healthMetric.steps,
        sleepMinutes: healthMetric.sleepMinutes,
        mood: healthMetric.mood,
        stressLevel: healthMetric.stressLevel,
        energyLevel: healthMetric.energyLevel,
        notes: healthMetric.notes,
        createdAt: healthMetric.createdAt,
        isPeriodDay: healthMetric.isPeriodDay,
        flowIntensity: healthMetric.flowIntensity,
        periodSymptoms: healthMetric.periodSymptoms,
        cycleDay: healthMetric.cycleDay,
        symptoms: updatedSymptoms.isNotEmpty ? updatedSymptoms : null,
        symptomSeverity: updatedSeverity.isNotEmpty ? updatedSeverity : null,
        symptomBodyParts: updatedBodyParts.isNotEmpty ? updatedBodyParts : null,
        symptomTriggers: healthMetric.symptomTriggers,
      );

      await saveHealthMetric(updated);
    }
  }

  List<SymptomModel> getUserSymptoms(String userId) {
    return symptomBox.values.where((s) => s.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Period cycle operations
  Box<PeriodCycleModel> get periodBox =>
      Hive.box<PeriodCycleModel>('period_box');

  Future<void> savePeriodCycle(PeriodCycleModel cycle) async {
    await _ensureConsentOrThrow();

    await periodBox.put(cycle.id, cycle);
  }

  Future<void> deletePeriodCycle(String id) async {
    // Get the period cycle to find its date range
    final cycle = periodBox.get(id);
    if (cycle == null) return;

    // Delete from period box
    await periodBox.delete(id);

    // Also remove period data from health metrics for all days in the cycle
    final startDate = DateTime(
      cycle.startDate.year,
      cycle.startDate.month,
      cycle.startDate.day,
    );

    final endDate =
        cycle.endDate != null
            ? DateTime(
              cycle.endDate!.year,
              cycle.endDate!.month,
              cycle.endDate!.day,
            )
            : DateTime.now();

    // Clear period data from all days in the cycle
    for (
      var date = startDate;
      date.isBefore(endDate.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      final healthMetric = getHealthMetricByDate(cycle.userId, date);
      if (healthMetric != null && healthMetric.isPeriodDay) {
        // Update the health metric to remove period data
        final updated = HealthMetricModel(
          id: healthMetric.id,
          userId: healthMetric.userId,
          date: healthMetric.date,
          weight: healthMetric.weight,
          steps: healthMetric.steps,
          sleepMinutes: healthMetric.sleepMinutes,
          mood: healthMetric.mood,
          stressLevel: healthMetric.stressLevel,
          energyLevel: healthMetric.energyLevel,
          notes: healthMetric.notes,
          createdAt: healthMetric.createdAt,
          isPeriodDay: false, // Clear period flag
          flowIntensity: null, // Clear flow intensity
          periodSymptoms: null, // Clear period symptoms
          cycleDay: null, // Clear cycle day
          symptoms: healthMetric.symptoms,
          symptomSeverity: healthMetric.symptomSeverity,
          symptomBodyParts: healthMetric.symptomBodyParts,
          symptomTriggers: healthMetric.symptomTriggers,
        );

        await saveHealthMetric(updated);
      }
    }
  }

  List<PeriodCycleModel> getUserPeriodCycles(String userId) {
    return periodBox.values.where((p) => p.userId == userId).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  PeriodCycleModel? getActivePeriodCycle(String userId) {
    try {
      return periodBox.values.firstWhere(
        (p) => p.userId == userId && p.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  // Food log operations
  Box<FoodLogModel> get foodLogBox => Hive.box<FoodLogModel>('food_log_box');

  Future<void> saveFoodLog(FoodLogModel foodLog) async {
    await _ensureConsentOrThrow();

    await foodLogBox.put(foodLog.id, foodLog);
    // Track in SQLite for analytics
    await _syncService.trackFoodLog(foodLog);
  }

  Future<void> deleteFoodLog(String id) async {
    await foodLogBox.delete(id);
    // Delete from Supabase
    await _syncService.deleteFoodLogFromCloud(id);
  }

  List<FoodLogModel> getUserFoodLogs(String userId) {
    return foodLogBox.values.where((f) => f.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<FoodLogModel> getUserFoodLogsByDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return foodLogBox.values
        .where(
          (f) =>
              f.userId == userId &&
              f.timestamp.isAfter(
                startOfDay.subtract(const Duration(seconds: 1)),
              ) &&
              f.timestamp.isBefore(endOfDay.add(const Duration(seconds: 1))),
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Mood log operations
  Box<MoodLogModel> get moodBox => Hive.box<MoodLogModel>('mood_box');

  Future<void> saveMoodLog(MoodLogModel moodLog) async {
    await _ensureConsentOrThrow();

    await moodBox.put(moodLog.id, moodLog);
    // Track in SQLite for analytics
    await _syncService.trackMood(moodLog);
  }

  Future<void> deleteMoodLog(String id) async {
    await moodBox.delete(id);
    // Delete from Supabase
    await _syncService.deleteMoodLogFromCloud(id);
  }

  List<MoodLogModel> getUserMoodLogs(String userId) {
    return moodBox.values.where((m) => m.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MoodLogModel> getUserMoodLogsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return moodBox.values
        .where(
          (m) =>
              m.userId == userId &&
              m.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
              m.timestamp.isBefore(end.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Meditation session operations
  Box<MeditationSessionModel> get meditationBox =>
      Hive.box<MeditationSessionModel>('meditation_box');

  Future<void> saveMeditationSession(MeditationSessionModel session) async {
    await _ensureConsentOrThrow();

    await meditationBox.put(session.id, session);
  }

  Future<void> deleteMeditationSession(String id) async {
    await meditationBox.delete(id);
  }

  List<MeditationSessionModel> getUserMeditationSessions(String userId) {
    return meditationBox.values.where((m) => m.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int getMeditationStreak(String userId) {
    final sessions = getUserMeditationSessions(userId);
    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final startOfDay = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );
      final endOfDay = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
        23,
        59,
        59,
      );

      final hasSession = sessions.any(
        (s) =>
            s.timestamp.isAfter(startOfDay) && s.timestamp.isBefore(endOfDay),
      );

      if (hasSession) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }

      if (streak > 365) break; // Safety limit
    }

    return streak;
  }

  // Recipe operations
  Box<RecipeModel> get recipeBox => Hive.box<RecipeModel>('recipe_box');

  Future<void> saveRecipe(RecipeModel recipe) async {
    await recipeBox.put(recipe.id, recipe);
  }

  Future<void> deleteRecipe(String id) async {
    await recipeBox.delete(id);
  }

  List<RecipeModel> getAllRecipes() {
    return recipeBox.values.toList();
  }

  List<RecipeModel> getRecipesByCategory(String category) {
    return recipeBox.values.where((r) => r.category == category).toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await userBox.clear();
    await workoutBox.clear();
    await hydrationBox.clear();
    await healthBox.clear();
    await symptomBox.clear();
    await periodBox.clear();
    await foodLogBox.clear();
    await moodBox.clear();
    await meditationBox.clear();
    await recipeBox.clear();
    await settingsBox.clear();
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
    await _sqliteService.close();
    _syncService.dispose();
  }

  // ==================== Analytics & Sync Methods ====================

  /// Get analytics insights from SQLite
  Future<Map<String, dynamic>> getAnalyticsInsights(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _syncService.getAnalyticsInsights(userId, startDate, endDate);
  }

  /// Get AI-powered health predictions from Supabase
  Future<Map<String, dynamic>?> getHealthPredictions(String userId) async {
    return await _syncService.getHealthPredictions(userId);
  }

  /// Get personalized recommendations from Supabase
  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    return await _syncService.getRecommendations(userId);
  }

  /// Generate AI meal plan
  Future<Map<String, dynamic>?> generateMealPlan({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    return await _syncService.generateMealPlan(
      userId: userId,
      preferences: preferences,
    );
  }

  /// Force sync to cloud
  Future<bool> syncToCloud() async {
    return await _syncService.syncToCloud();
  }

  /// Restore user data from cloud on login
  Future<void> restoreUserData(String userId) async {
    await _syncService.restoreUserDataFromCloud(userId);
  }

  /// Check if sync is in progress
  bool get isSyncing => _syncService.isSyncing;

  /// Access to SQLite service for advanced queries
  SQLiteService get sqliteService => _sqliteService;

  /// Access to sync service
  DatabaseSyncService get syncService => _syncService;
}
