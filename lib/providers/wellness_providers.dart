import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_log_model.dart';
import '../models/meditation_session_model.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';
import 'health_provider.dart';

// Mood logs provider
final moodLogsProvider = StateNotifierProvider<MoodLogsNotifier, List<MoodLogModel>>((ref) {
  return MoodLogsNotifier(ref);
});

class MoodLogsNotifier extends StateNotifier<List<MoodLogModel>> {
  MoodLogsNotifier(this.ref) : super([]) {
    _loadMoodLogs();
  }

  final Ref ref;

  void _loadMoodLogs() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      state = db.getUserMoodLogs(user.id);
    }
  }

  Future<void> addMoodLog(MoodLogModel moodLog) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveMoodLog(moodLog);
    _loadMoodLogs();
  }

  Future<void> deleteMoodLog(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteMoodLog(id);
    _loadMoodLogs();
  }

  List<MoodLogModel> getLogsForDateRange(DateTime start, DateTime end) {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      return db.getUserMoodLogsByDateRange(user.id, start, end);
    }
    return [];
  }

  void refresh() {
    _loadMoodLogs();
  }
}

// Meditation sessions provider
final meditationSessionsProvider = StateNotifierProvider<MeditationSessionsNotifier, List<MeditationSessionModel>>((ref) {
  return MeditationSessionsNotifier(ref);
});

class MeditationSessionsNotifier extends StateNotifier<List<MeditationSessionModel>> {
  MeditationSessionsNotifier(this.ref) : super([]) {
    _loadSessions();
  }

  final Ref ref;

  void _loadSessions() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final db = ref.read(databaseServiceProvider);
      state = db.getUserMeditationSessions(user.id);
    }
  }

  Future<void> addSession(MeditationSessionModel session) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveMeditationSession(session);
    _loadSessions();
  }

  Future<void> deleteSession(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteMeditationSession(id);
    _loadSessions();
  }

  int getTotalMinutes() {
    return state.where((s) => s.completed).fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int getSessionCount() {
    return state.where((s) => s.completed).length;
  }

  void refresh() {
    _loadSessions();
  }
}

// Meditation streak provider
final meditationStreakProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    final db = ref.read(databaseServiceProvider);
    return db.getMeditationStreak(user.id);
  }
  return 0;
});
