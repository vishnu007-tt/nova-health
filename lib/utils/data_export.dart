import 'dart:convert';
import 'dart:html' as html;
import '../models/workout_model.dart';
import '../models/hydration_model.dart';
import '../models/food_log_model.dart';
import '../models/mood_log_model.dart';
import '../models/symptom_model.dart';
import '../models/period_cycle_model.dart';
import '../models/meditation_session_model.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class DataExporter {
  final String userId;
  final DatabaseService _db = DatabaseService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateFormat _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  DataExporter(this.userId);

  /// Export all health data to CSV format
  Future<void> exportAllData() async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final filename = 'novahealth_export_$timestamp.csv';

    // Collect all data
    final workouts = _db.getUserWorkouts(userId);
    final hydrationLogs = _db.getUserHydrationLogs(userId);
    final foodLogs = _db.getUserFoodLogs(userId);
    final moodLogs = _db.getUserMoodLogs(userId);
    final symptoms = _db.getUserSymptoms(userId);
    final periodCycles = _db.getUserPeriodCycles(userId);
    final meditationSessions = _db.getUserMeditationSessions(userId);

    // Generate CSV content
    final csvContent = _generateCombinedCSV(
      workouts: workouts,
      hydrationLogs: hydrationLogs,
      foodLogs: foodLogs,
      moodLogs: moodLogs,
      symptoms: symptoms,
      periodCycles: periodCycles,
      meditationSessions: meditationSessions,
    );

    // Download CSV file (web-specific)
    _downloadCSV(csvContent, filename);
  }

  /// Export only workout data
  Future<void> exportWorkouts() async {
    final workouts = _db.getUserWorkouts(userId);
    final csv = _workoutsToCSV(workouts);
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    _downloadCSV(csv, 'workouts_$timestamp.csv');
  }

  /// Export only hydration data
  Future<void> exportHydration() async {
    final logs = _db.getUserHydrationLogs(userId);
    final csv = _hydrationToCSV(logs);
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    _downloadCSV(csv, 'hydration_$timestamp.csv');
  }

  /// Export only nutrition data
  Future<void> exportNutrition() async {
    final logs = _db.getUserFoodLogs(userId);
    final csv = _nutritionToCSV(logs);
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    _downloadCSV(csv, 'nutrition_$timestamp.csv');
  }

  /// Export only mood data
  Future<void> exportMoodLogs() async {
    final logs = _db.getUserMoodLogs(userId);
    final csv = _moodLogsToCSV(logs);
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    _downloadCSV(csv, 'mood_logs_$timestamp.csv');
  }

  /// Generate a combined CSV with all data types
  String _generateCombinedCSV({
    required List<WorkoutModel> workouts,
    required List<HydrationModel> hydrationLogs,
    required List<FoodLogModel> foodLogs,
    required List<MoodLogModel> moodLogs,
    required List<SymptomModel> symptoms,
    required List<PeriodCycleModel> periodCycles,
    required List<MeditationSessionModel> meditationSessions,
  }) {
    final buffer = StringBuffer();

    // Add metadata
    buffer.writeln('NovaHealth Data Export');
    buffer.writeln('Export Date: ${DateTime.now().toIso8601String()}');
    buffer.writeln('User ID: $userId');
    buffer.writeln('');

    // Workouts section
    buffer.writeln('=== WORKOUTS ===');
    buffer.writeln(_workoutsToCSV(workouts));
    buffer.writeln('');

    // Hydration section
    buffer.writeln('=== HYDRATION LOGS ===');
    buffer.writeln(_hydrationToCSV(hydrationLogs));
    buffer.writeln('');

    // Nutrition section
    buffer.writeln('=== FOOD LOGS ===');
    buffer.writeln(_nutritionToCSV(foodLogs));
    buffer.writeln('');

    // Mood logs section
    buffer.writeln('=== MOOD LOGS ===');
    buffer.writeln(_moodLogsToCSV(moodLogs));
    buffer.writeln('');

    // Symptoms section
    buffer.writeln('=== SYMPTOMS ===');
    buffer.writeln(_symptomsToCSV(symptoms));
    buffer.writeln('');

    // Period cycles section
    buffer.writeln('=== PERIOD CYCLES ===');
    buffer.writeln(_periodCyclesToCSV(periodCycles));
    buffer.writeln('');

    // Meditation sessions section
    buffer.writeln('=== MEDITATION SESSIONS ===');
    buffer.writeln(_meditationToCSV(meditationSessions));

    return buffer.toString();
  }

  /// Convert workouts to CSV
  String _workoutsToCSV(List<WorkoutModel> workouts) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Activity Type,Duration (min),Intensity,Distance (km),Calories Burned,Notes');

    for (final workout in workouts) {
      buffer.writeln([
        _dateOnlyFormat.format(workout.date),
        _escapeCSV(workout.activityType),
        workout.durationMinutes,
        _escapeCSV(workout.intensity),
        workout.distance ?? '',
        workout.caloriesBurned,
        _escapeCSV(workout.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Convert hydration logs to CSV
  String _hydrationToCSV(List<HydrationModel> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Amount (ml),Beverage Type');

    for (final log in logs) {
      buffer.writeln([
        _dateOnlyFormat.format(log.timestamp),
        DateFormat('HH:mm:ss').format(log.timestamp),
        log.amountMl,
        _escapeCSV(log.beverageType),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Convert food logs to CSV
  String _nutritionToCSV(List<FoodLogModel> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Meal Type,Food Name,Serving Size,Unit,Calories,Protein (g),Carbs (g),Fats (g),Fiber (g),Sugar (g),Notes');

    for (final log in logs) {
      buffer.writeln([
        _dateOnlyFormat.format(log.timestamp),
        DateFormat('HH:mm:ss').format(log.timestamp),
        _escapeCSV(log.mealType),
        _escapeCSV(log.foodName),
        log.servingSize,
        _escapeCSV(log.servingUnit),
        log.calories,
        log.protein,
        log.carbs,
        log.fats,
        log.fiber ?? '',
        log.sugar ?? '',
        _escapeCSV(log.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Convert mood logs to CSV
  String _moodLogsToCSV(List<MoodLogModel> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Mood,Intensity,Factors,Notes');

    for (final log in logs) {
      buffer.writeln([
        _dateOnlyFormat.format(log.timestamp),
        DateFormat('HH:mm:ss').format(log.timestamp),
        _escapeCSV(log.mood),
        log.intensity,
        _escapeCSV(log.factors.join('; ')),
        _escapeCSV(log.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Convert symptoms to CSV
  String _symptomsToCSV(List<SymptomModel> symptoms) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Symptom Type,Severity,Body Part,Triggers,Notes');

    for (final symptom in symptoms) {
      buffer.writeln([
        _dateOnlyFormat.format(symptom.timestamp),
        DateFormat('HH:mm:ss').format(symptom.timestamp),
        _escapeCSV(symptom.symptomType),
        symptom.severity,
        _escapeCSV(symptom.bodyPart ?? ''),
        _escapeCSV(symptom.triggers?.join('; ') ?? ''),
        _escapeCSV(symptom.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Convert period cycles to CSV
  String _periodCyclesToCSV(List<PeriodCycleModel> cycles) {
    final buffer = StringBuffer();
    buffer.writeln('Start Date,End Date,Flow Intensity,Symptoms,Mood,Cycle Length,Period Length,Notes');

    for (final cycle in cycles) {
      buffer.writeln([
        _dateOnlyFormat.format(cycle.startDate),
        cycle.endDate != null ? _dateOnlyFormat.format(cycle.endDate!) : 'Ongoing',
        _escapeCSV(cycle.flowIntensity),
        _escapeCSV(cycle.symptoms.join('; ')),
        _escapeCSV(cycle.mood ?? ''),
        cycle.cycleLength ?? '',
        cycle.periodLength ?? '',
        _escapeCSV(cycle.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Convert meditation sessions to CSV
  String _meditationToCSV(List<MeditationSessionModel> sessions) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Type,Duration (min),Exercise Name,Completed,Notes');

    for (final session in sessions) {
      buffer.writeln([
        _dateOnlyFormat.format(session.timestamp),
        DateFormat('HH:mm:ss').format(session.timestamp),
        _escapeCSV(session.type),
        session.durationMinutes,
        _escapeCSV(session.exerciseName ?? ''),
        session.completed ? 'Yes' : 'No',
        _escapeCSV(session.notes ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Escape CSV values (handle commas and quotes)
  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Download CSV file using web APIs
  void _downloadCSV(String csvContent, String filename) {
    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
