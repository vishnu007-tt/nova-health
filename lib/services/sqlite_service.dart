import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// SQLite database service for local data tracking across all platforms
/// Handles structured data storage with SQL queries for analytics and reporting
class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  Database? _database;
  bool _initialized = false;

  /// Initialize SQLite database for the current platform
  Future<void> init() async {
    if (_initialized) return;

    // Initialize FFI for desktop platforms
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (kIsWeb) {
      // SQLite not supported on web, skip initialization
      _initialized = true;
      return;
    }

    final dbPath = await _getDatabasePath();
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );

    _initialized = true;
  }

  /// Get database path based on platform
  Future<String> _getDatabasePath() async {
    if (kIsWeb) {
      return 'novahealth.db'; // Not used on web
    }

    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'novahealth_tracking.db');
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // User profile table - stores user credentials and dashboard data
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL UNIQUE,
        username TEXT,
        email TEXT,
        name TEXT,
        age INTEGER,
        gender TEXT,
        height REAL,
        weight REAL,
        profile_image TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_login INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // User analytics table
    await db.execute('''
      CREATE TABLE user_analytics (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        event_data TEXT,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Workout tracking table
    await db.execute('''
      CREATE TABLE workout_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        workout_type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories_burned INTEGER,
        intensity TEXT,
        date INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Hydration tracking table
    await db.execute('''
      CREATE TABLE hydration_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount_ml INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Health metrics tracking table (merged with period and symptom tracking)
    await db.execute('''
      CREATE TABLE health_metrics_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        weight REAL,
        height REAL,
        bmi REAL,
        heart_rate INTEGER,
        blood_pressure TEXT,
        sleep_hours REAL,
        steps INTEGER,
        mood TEXT,
        stress_level INTEGER,
        energy_level INTEGER,
        notes TEXT,
        date INTEGER NOT NULL,
        is_period_day INTEGER DEFAULT 0,
        flow_intensity TEXT,
        period_symptoms TEXT,
        cycle_day INTEGER,
        symptoms TEXT,
        symptom_severity TEXT,
        symptom_body_parts TEXT,
        symptom_triggers TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Symptom tracking table
    await db.execute('''
      CREATE TABLE symptom_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        symptom_name TEXT NOT NULL,
        severity INTEGER NOT NULL,
        notes TEXT,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Period tracking table
    await db.execute('''
      CREATE TABLE period_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        flow_intensity TEXT,
        symptoms TEXT,
        is_active INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Food log tracking table
    await db.execute('''
      CREATE TABLE food_log_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        food_name TEXT NOT NULL,
        calories INTEGER,
        protein REAL,
        carbs REAL,
        fats REAL,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Mood tracking table
    await db.execute('''
      CREATE TABLE mood_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        mood_type TEXT NOT NULL,
        mood_score INTEGER NOT NULL,
        notes TEXT,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Meditation tracking table
    await db.execute('''
      CREATE TABLE meditation_tracking (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        duration INTEGER NOT NULL,
        meditation_type TEXT,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_user_analytics_user_id ON user_analytics(user_id)');
    await db.execute('CREATE INDEX idx_user_analytics_timestamp ON user_analytics(timestamp)');
    await db.execute('CREATE INDEX idx_workout_tracking_user_id ON workout_tracking(user_id)');
    await db.execute('CREATE INDEX idx_workout_tracking_date ON workout_tracking(date)');
    await db.execute('CREATE INDEX idx_hydration_tracking_user_id ON hydration_tracking(user_id)');
    await db.execute('CREATE INDEX idx_health_metrics_user_id ON health_metrics_tracking(user_id)');
    await db.execute('CREATE INDEX idx_symptom_tracking_user_id ON symptom_tracking(user_id)');
    await db.execute('CREATE INDEX idx_period_tracking_user_id ON period_tracking(user_id)');
    await db.execute('CREATE INDEX idx_food_log_user_id ON food_log_tracking(user_id)');
    await db.execute('CREATE INDEX idx_mood_tracking_user_id ON mood_tracking(user_id)');
    await db.execute('CREATE INDEX idx_meditation_tracking_user_id ON meditation_tracking(user_id)');
  }

  /// Upgrade database schema
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations
  }

  /// Get database instance
  Database? get database => _database;

  /// Check if database is available (not on web)
  bool get isAvailable => !kIsWeb && _database != null;

  /// Insert or update data in any table
  Future<int> insertOrUpdate(String table, Map<String, dynamic> data) async {
    if (!isAvailable) return 0;
    return await _database!.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Query data from table
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    if (!isAvailable) return [];
    return await _database!.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Delete data from table
  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    if (!isAvailable) return 0;
    return await _database!.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Get unsynced records from any table
  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String table) async {
    if (!isAvailable) return [];
    return await _database!.query(
      table,
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  /// Mark records as synced
  Future<int> markAsSynced(String table, String id) async {
    if (!isAvailable) return 0;
    return await _database!.update(
      table,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get analytics data for a user within date range
  Future<List<Map<String, dynamic>>> getUserAnalytics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!isAvailable) return [];
    return await _database!.query(
      'user_analytics',
      where: 'user_id = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        userId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );
  }

  /// Get workout statistics for a user
  Future<Map<String, dynamic>> getWorkoutStats(String userId, DateTime startDate, DateTime endDate) async {
    if (!isAvailable) {
      return {
        'total_workouts': 0,
        'total_duration': 0,
        'total_calories': 0,
        'avg_duration': 0,
      };
    }

    final result = await _database!.rawQuery('''
      SELECT 
        COUNT(*) as total_workouts,
        SUM(duration) as total_duration,
        SUM(calories_burned) as total_calories,
        AVG(duration) as avg_duration
      FROM workout_tracking
      WHERE user_id = ? AND date >= ? AND date <= ?
    ''', [userId, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

    return result.first;
  }

  /// Get hydration statistics
  Future<Map<String, dynamic>> getHydrationStats(String userId, DateTime date) async {
    if (!isAvailable) {
      return {'total_ml': 0, 'count': 0};
    }

    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;

    final result = await _database!.rawQuery('''
      SELECT 
        SUM(amount_ml) as total_ml,
        COUNT(*) as count
      FROM hydration_tracking
      WHERE user_id = ? AND timestamp >= ? AND timestamp <= ?
    ''', [userId, startOfDay, endOfDay]);

    return result.first;
  }

  /// Get mood trends
  Future<List<Map<String, dynamic>>> getMoodTrends(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!isAvailable) return [];
    return await _database!.query(
      'mood_tracking',
      where: 'user_id = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        userId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp ASC',
    );
  }

  /// Clear all data
  Future<void> clearAllData() async {
    if (!isAvailable) return;
    
    final tables = [
      'user_analytics',
      'workout_tracking',
      'hydration_tracking',
      'health_metrics_tracking',
      'symptom_tracking',
      'period_tracking',
      'food_log_tracking',
      'mood_tracking',
      'meditation_tracking',
    ];

    for (final table in tables) {
      await _database!.delete(table);
    }
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _initialized = false;
    }
  }
}
