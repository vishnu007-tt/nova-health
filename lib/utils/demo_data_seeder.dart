import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../models/hydration_model.dart';
import '../models/symptom_model.dart';
import '../models/period_cycle_model.dart';
import '../models/food_log_model.dart';
import '../models/mood_log_model.dart';
import '../models/meditation_session_model.dart';
import '../services/database_service.dart';

const uuid = Uuid();

class DemoDataSeeder {
  final String userId;
  final DatabaseService _db = DatabaseService();
  final Random _random = Random();

  DemoDataSeeder(this.userId);

  /// Seed all demo data for the past 7 days
  Future<void> seedAllData() async {
    final now = DateTime.now();

    // Generate data for the past 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));

      // Seed workout logs (varied activities)
      await _seedWorkoutForDay(date);

      // Seed hydration logs (realistic daily patterns)
      await _seedHydrationForDay(date);

      // Seed food logs (breakfast, lunch, dinner, snacks)
      await _seedFoodLogsForDay(date);

      // Seed mood logs
      await _seedMoodLogForDay(date);

      // Seed meditation sessions (not every day)
      if (_random.nextBool() || i < 3) {
        await _seedMeditationForDay(date);
      }
    }

    // Seed some symptoms logs (not every day)
    await _seedSymptomsLogs(now);

    // Seed period cycle data (if applicable)
    await _seedPeriodCycleData(now);
  }

  /// Seed varied workout activities
  Future<void> _seedWorkoutForDay(DateTime date) async {
    final activities = [
      {'type': 'running', 'duration': 30.0, 'distance': 5.0, 'calories': 300.0, 'intensity': 'moderate'},
      {'type': 'cycling', 'duration': 45.0, 'distance': 15.0, 'calories': 400.0, 'intensity': 'moderate'},
      {'type': 'gym', 'duration': 60.0, 'distance': null, 'calories': 350.0, 'intensity': 'vigorous'},
      {'type': 'yoga', 'duration': 30.0, 'distance': null, 'calories': 150.0, 'intensity': 'light'},
      {'type': 'swimming', 'duration': 40.0, 'distance': 2.0, 'calories': 380.0, 'intensity': 'moderate'},
      {'type': 'walking', 'duration': 25.0, 'distance': 3.0, 'calories': 120.0, 'intensity': 'light'},
    ];

    // Not every day has a workout
    if (_random.nextDouble() > 0.3) {
      final activity = activities[_random.nextInt(activities.length)];

      final workout = WorkoutModel(
        id: uuid.v4(),
        userId: userId,
        date: DateTime(date.year, date.month, date.day, 8 + _random.nextInt(10)),
        activityType: activity['type'] as String,
        durationMinutes: activity['duration'] as double,
        intensity: activity['intensity'] as String,
        distance: activity['distance'] as double?,
        caloriesBurned: activity['calories'] as double,
        notes: _random.nextBool() ? 'Felt great!' : null,
        createdAt: date,
      );

      await _db.saveWorkout(workout);
    }
  }

  /// Seed realistic hydration logs throughout the day
  Future<void> _seedHydrationForDay(DateTime date) async {
    // Morning (6-10 AM): 1-2 glasses
    final morningLogs = 1 + _random.nextInt(2);
    for (int i = 0; i < morningLogs; i++) {
      await _db.saveHydration(HydrationModel(
        id: uuid.v4(),
        userId: userId,
        timestamp: DateTime(date.year, date.month, date.day, 6 + _random.nextInt(4), _random.nextInt(60)),
        amountMl: 250,
        beverageType: i == 0 ? 'water' : _random.nextBool() ? 'water' : 'tea',
      ));
    }

    // Midday (10 AM - 2 PM): 2-3 glasses
    final middayLogs = 2 + _random.nextInt(2);
    for (int i = 0; i < middayLogs; i++) {
      await _db.saveHydration(HydrationModel(
        id: uuid.v4(),
        userId: userId,
        timestamp: DateTime(date.year, date.month, date.day, 10 + _random.nextInt(4), _random.nextInt(60)),
        amountMl: 250,
        beverageType: 'water',
      ));
    }

    // Afternoon (2-6 PM): 1-2 glasses
    final afternoonLogs = 1 + _random.nextInt(2);
    for (int i = 0; i < afternoonLogs; i++) {
      await _db.saveHydration(HydrationModel(
        id: uuid.v4(),
        userId: userId,
        timestamp: DateTime(date.year, date.month, date.day, 14 + _random.nextInt(4), _random.nextInt(60)),
        amountMl: 250,
        beverageType: _random.nextBool() ? 'water' : 'juice',
      ));
    }

    // Evening (6-10 PM): 1-2 glasses
    final eveningLogs = 1 + _random.nextInt(2);
    for (int i = 0; i < eveningLogs; i++) {
      await _db.saveHydration(HydrationModel(
        id: uuid.v4(),
        userId: userId,
        timestamp: DateTime(date.year, date.month, date.day, 18 + _random.nextInt(4), _random.nextInt(60)),
        amountMl: 200,
        beverageType: 'water',
      ));
    }
  }

  /// Seed food logs for a day (breakfast, lunch, dinner, snacks)
  Future<void> _seedFoodLogsForDay(DateTime date) async {
    // Breakfast
    final breakfastFoods = [
      {'name': 'Oatmeal with berries', 'calories': 320.0, 'protein': 12.0, 'carbs': 54.0, 'fats': 8.0},
      {'name': 'Scrambled eggs with toast', 'calories': 380.0, 'protein': 22.0, 'carbs': 35.0, 'fats': 16.0},
      {'name': 'Greek yogurt with granola', 'calories': 290.0, 'protein': 18.0, 'carbs': 42.0, 'fats': 6.0},
      {'name': 'Smoothie bowl', 'calories': 350.0, 'protein': 15.0, 'carbs': 58.0, 'fats': 9.0},
    ];
    final breakfast = breakfastFoods[_random.nextInt(breakfastFoods.length)];
    await _db.saveFoodLog(FoodLogModel(
      id: uuid.v4(),
      userId: userId,
      timestamp: DateTime(date.year, date.month, date.day, 7 + _random.nextInt(2), _random.nextInt(60)),
      mealType: 'breakfast',
      foodName: breakfast['name'] as String,
      servingSize: 1,
      servingUnit: 'bowl',
      calories: breakfast['calories'] as double,
      protein: breakfast['protein'] as double,
      carbs: breakfast['carbs'] as double,
      fats: breakfast['fats'] as double,
      fiber: 5.0 + _random.nextDouble() * 5,
      sugar: 8.0 + _random.nextDouble() * 10,
      createdAt: date,
    ));

    // Lunch
    final lunchFoods = [
      {'name': 'Grilled chicken salad', 'calories': 420.0, 'protein': 35.0, 'carbs': 28.0, 'fats': 18.0},
      {'name': 'Turkey sandwich', 'calories': 480.0, 'protein': 28.0, 'carbs': 52.0, 'fats': 16.0},
      {'name': 'Quinoa bowl with vegetables', 'calories': 390.0, 'protein': 16.0, 'carbs': 58.0, 'fats': 12.0},
      {'name': 'Pasta with marinara sauce', 'calories': 520.0, 'protein': 18.0, 'carbs': 82.0, 'fats': 14.0},
    ];
    final lunch = lunchFoods[_random.nextInt(lunchFoods.length)];
    await _db.saveFoodLog(FoodLogModel(
      id: uuid.v4(),
      userId: userId,
      timestamp: DateTime(date.year, date.month, date.day, 12 + _random.nextInt(2), _random.nextInt(60)),
      mealType: 'lunch',
      foodName: lunch['name'] as String,
      servingSize: 1,
      servingUnit: 'serving',
      calories: lunch['calories'] as double,
      protein: lunch['protein'] as double,
      carbs: lunch['carbs'] as double,
      fats: lunch['fats'] as double,
      fiber: 6.0 + _random.nextDouble() * 6,
      sugar: 4.0 + _random.nextDouble() * 8,
      createdAt: date,
    ));

    // Snack
    if (_random.nextBool()) {
      final snacks = [
        {'name': 'Apple with almond butter', 'calories': 180.0, 'protein': 4.0, 'carbs': 24.0, 'fats': 8.0},
        {'name': 'Protein bar', 'calories': 220.0, 'protein': 20.0, 'carbs': 25.0, 'fats': 7.0},
        {'name': 'Mixed nuts', 'calories': 160.0, 'protein': 6.0, 'carbs': 8.0, 'fats': 14.0},
        {'name': 'Fruit smoothie', 'calories': 190.0, 'protein': 8.0, 'carbs': 36.0, 'fats': 2.0},
      ];
      final snack = snacks[_random.nextInt(snacks.length)];
      await _db.saveFoodLog(FoodLogModel(
        id: uuid.v4(),
        userId: userId,
        timestamp: DateTime(date.year, date.month, date.day, 15 + _random.nextInt(2), _random.nextInt(60)),
        mealType: 'snack',
        foodName: snack['name'] as String,
        servingSize: 1,
        servingUnit: 'serving',
        calories: snack['calories'] as double,
        protein: snack['protein'] as double,
        carbs: snack['carbs'] as double,
        fats: snack['fats'] as double,
        fiber: 2.0 + _random.nextDouble() * 3,
        sugar: 5.0 + _random.nextDouble() * 10,
        createdAt: date,
      ));
    }

    // Dinner
    final dinnerFoods = [
      {'name': 'Grilled salmon with vegetables', 'calories': 540.0, 'protein': 42.0, 'carbs': 32.0, 'fats': 26.0},
      {'name': 'Chicken stir-fry with rice', 'calories': 580.0, 'protein': 38.0, 'carbs': 65.0, 'fats': 18.0},
      {'name': 'Beef tacos', 'calories': 620.0, 'protein': 32.0, 'carbs': 54.0, 'fats': 28.0},
      {'name': 'Vegetarian curry with naan', 'calories': 490.0, 'protein': 16.0, 'carbs': 72.0, 'fats': 16.0},
    ];
    final dinner = dinnerFoods[_random.nextInt(dinnerFoods.length)];
    await _db.saveFoodLog(FoodLogModel(
      id: uuid.v4(),
      userId: userId,
      timestamp: DateTime(date.year, date.month, date.day, 18 + _random.nextInt(2), _random.nextInt(60)),
      mealType: 'dinner',
      foodName: dinner['name'] as String,
      servingSize: 1,
      servingUnit: 'plate',
      calories: dinner['calories'] as double,
      protein: dinner['protein'] as double,
      carbs: dinner['carbs'] as double,
      fats: dinner['fats'] as double,
      fiber: 7.0 + _random.nextDouble() * 6,
      sugar: 6.0 + _random.nextDouble() * 8,
      createdAt: date,
    ));
  }

  /// Seed mood logs
  Future<void> _seedMoodLogForDay(DateTime date) async {
    final moods = ['great', 'good', 'okay', 'bad', 'terrible'];
    final moodIndex = _random.nextInt(moods.length);
    final mood = moods[moodIndex];

    // Intensity correlates with mood (great = 8-10, terrible = 1-3)
    int intensity;
    switch (moodIndex) {
      case 0: // great
        intensity = 8 + _random.nextInt(3);
        break;
      case 1: // good
        intensity = 6 + _random.nextInt(3);
        break;
      case 2: // okay
        intensity = 4 + _random.nextInt(3);
        break;
      case 3: // bad
        intensity = 2 + _random.nextInt(3);
        break;
      default: // terrible
        intensity = 1 + _random.nextInt(2);
    }

    final allFactors = ['sleep', 'exercise', 'work', 'relationships', 'weather', 'health', 'diet'];
    final factorCount = 1 + _random.nextInt(3);
    final selectedFactors = <String>[];
    for (int i = 0; i < factorCount; i++) {
      final factor = allFactors[_random.nextInt(allFactors.length)];
      if (!selectedFactors.contains(factor)) {
        selectedFactors.add(factor);
      }
    }

    final moodLog = MoodLogModel(
      id: uuid.v4(),
      userId: userId,
      timestamp: DateTime(date.year, date.month, date.day, 20 + _random.nextInt(2), _random.nextInt(60)),
      mood: mood,
      intensity: intensity,
      factors: selectedFactors,
      notes: _random.nextBool() ? 'Feeling $mood today' : null,
      createdAt: date,
    );

    await _db.saveMoodLog(moodLog);
  }

  /// Seed meditation sessions
  Future<void> _seedMeditationForDay(DateTime date) async {
    final types = ['meditation', 'breathing'];
    final exercises = [
      '4-7-8 Breathing',
      'Box Breathing',
      'Guided Meditation',
      'Mindfulness Practice',
      'Body Scan',
    ];

    final type = types[_random.nextInt(types.length)];
    final duration = [5, 10, 15, 20][_random.nextInt(4)];

    final session = MeditationSessionModel(
      id: uuid.v4(),
      userId: userId,
      timestamp: DateTime(date.year, date.month, date.day, 6 + _random.nextInt(16), _random.nextInt(60)),
      type: type,
      durationMinutes: duration,
      exerciseName: exercises[_random.nextInt(exercises.length)],
      notes: _random.nextBool() ? 'Very relaxing session' : null,
      completed: true,
      createdAt: date,
    );

    await _db.saveMeditationSession(session);
  }

  /// Seed some symptom logs (not every day)
  Future<void> _seedSymptomsLogs(DateTime now) async {
    final symptoms = [
      {'type': 'headache', 'severity': 5, 'bodyPart': 'head'},
      {'type': 'fatigue', 'severity': 6, 'bodyPart': null},
      {'type': 'pain', 'severity': 4, 'bodyPart': 'back'},
      {'type': 'nausea', 'severity': 3, 'bodyPart': null},
    ];

    // Add 2-3 random symptoms over the past week
    final symptomCount = 2 + _random.nextInt(2);
    for (int i = 0; i < symptomCount; i++) {
      final symptom = symptoms[_random.nextInt(symptoms.length)];
      final daysAgo = _random.nextInt(7);
      final date = now.subtract(Duration(days: daysAgo));

      await _db.saveSymptom(SymptomModel(
        id: uuid.v4(),
        userId: userId,
        timestamp: DateTime(date.year, date.month, date.day, 8 + _random.nextInt(12), _random.nextInt(60)),
        symptomType: symptom['type'] as String,
        severity: symptom['severity'] as int,
        bodyPart: symptom['bodyPart'] as String?,
        notes: _random.nextBool() ? 'Started after lunch' : null,
        triggers: _random.nextBool() ? ['stress', 'lack of sleep'] : null,
        createdAt: date,
      ));
    }
  }

  /// Seed period cycle data
  Future<void> _seedPeriodCycleData(DateTime now) async {
    // Create a cycle that ended about 10 days ago
    final lastCycleEnd = now.subtract(const Duration(days: 10));
    final lastCycleStart = lastCycleEnd.subtract(const Duration(days: 5));

    final cycle1 = PeriodCycleModel(
      id: uuid.v4(),
      userId: userId,
      startDate: lastCycleStart,
      endDate: lastCycleEnd,
      flowIntensity: ['light', 'medium', 'heavy'][_random.nextInt(3)],
      symptoms: ['cramps', 'fatigue', 'mood_swings'],
      mood: 'irritable',
      notes: 'Normal cycle',
      cycleLength: 28,
      createdAt: lastCycleStart,
    );

    await _db.savePeriodCycle(cycle1);

    // Create a previous cycle (about 38 days ago)
    final prevCycleEnd = lastCycleStart.subtract(const Duration(days: 23));
    final prevCycleStart = prevCycleEnd.subtract(const Duration(days: 4));

    final cycle2 = PeriodCycleModel(
      id: uuid.v4(),
      userId: userId,
      startDate: prevCycleStart,
      endDate: prevCycleEnd,
      flowIntensity: 'medium',
      symptoms: ['cramps', 'headache', 'bloating'],
      mood: 'anxious',
      notes: 'Slightly heavy this month',
      cycleLength: 27,
      createdAt: prevCycleStart,
    );

    await _db.savePeriodCycle(cycle2);
  }

  /// Clear all existing data (use with caution!)
  Future<void> clearAllData() async {
    await _db.clearAllData();
  }
}
