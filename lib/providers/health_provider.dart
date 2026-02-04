import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../models/hydration_model.dart';
import '../models/health_metric_model.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

// Database service provider
final databaseServiceProvider = Provider((ref) => DatabaseService());

// Workouts provider
final workoutsProvider = StateNotifierProvider<WorkoutsNotifier, List<WorkoutModel>>((ref) {
  return WorkoutsNotifier(ref);
});

class WorkoutsNotifier extends StateNotifier<List<WorkoutModel>> {
  WorkoutsNotifier(this.ref) : super([]) {
    _loadWorkouts();
  }

  final Ref ref;

  void _loadWorkouts() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      state = db.getUserWorkouts(user.id);
    }
  }

  Future<void> addWorkout(WorkoutModel workout) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveWorkout(workout);
    _loadWorkouts();
  }

  Future<void> deleteWorkout(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteWorkout(id);
    _loadWorkouts();
  }

  void refresh() {
    _loadWorkouts();
  }
}

// Hydration provider
final hydrationProvider = StateNotifierProvider<HydrationNotifier, List<HydrationModel>>((ref) {
  return HydrationNotifier(ref);
});

class HydrationNotifier extends StateNotifier<List<HydrationModel>> {
  HydrationNotifier(this.ref) : super([]) {
    _loadHydration();
  }

  final Ref ref;

  void _loadHydration() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      state = db.getUserHydrationByDate(user.id, DateTime.now());
    }
  }

  Future<void> addHydration(HydrationModel hydration) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveHydration(hydration);
    _loadHydration();
  }

  Future<void> deleteHydration(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteHydration(id);
    _loadHydration();
  }

  int getTotalForToday() {
    return state.fold(0, (sum, log) => sum + log.amountMl);
  }

  void refresh() {
    _loadHydration();
  }
}

// Today's hydration total provider
final todayHydrationTotalProvider = Provider<int>((ref) {
  final hydrationLogs = ref.watch(hydrationProvider);
  return hydrationLogs.fold(0, (sum, log) => sum + log.amountMl);
});

// Health metrics provider
final healthMetricsProvider = StateNotifierProvider<HealthMetricsNotifier, List<HealthMetricModel>>((ref) {
  return HealthMetricsNotifier(ref);
});

class HealthMetricsNotifier extends StateNotifier<List<HealthMetricModel>> {
  HealthMetricsNotifier(this.ref) : super([]) {
    _loadHealthMetrics();
  }

  final Ref ref;

  void _loadHealthMetrics() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      state = db.getUserHealthMetrics(user.id);
    }
  }

  Future<void> addHealthMetric(HealthMetricModel metric) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveHealthMetric(metric);
    _loadHealthMetrics();
  }

  Future<void> deleteHealthMetric(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteHealthMetric(id);
    _loadHealthMetrics();
  }

  void refresh() {
    _loadHealthMetrics();
  }
}
