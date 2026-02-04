import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Supabase service for cloud storage, analytics, and AI predictions
/// Handles user data synchronization, analytics, and ML-based predictions
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _initialized = false;

  /// Initialize Supabase client
  /// Call this with your Supabase URL and anon key
  Future<void> init({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_initialized) return;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _client = Supabase.instance.client;
      _initialized = true;
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  }

  /// Get Supabase client instance
  SupabaseClient? get client => _client;

  /// Check if Supabase is initialized and available
  bool get isAvailable => _initialized && _client != null;

  /// Get current user
  User? get currentUser => _client?.auth.currentUser;

  /// Sign in with email and password
  Future<AuthResponse?> signInWithEmail(String email, String password) async {
    if (!isAvailable) return null;
    try {
      return await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Supabase sign in error: $e');
      return null;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse?> signUpWithEmail(String email, String password) async {
    if (!isAvailable) return null;
    try {
      return await _client!.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Supabase sign up error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _client!.auth.signOut();
    } catch (e) {
      debugPrint('Supabase sign out error: $e');
    }
  }

  // ==================== User Data Operations ====================

  /// Save user profile data
  Future<bool> saveUserProfile(Map<String, dynamic> userData) async {
    if (!isAvailable || currentUser == null) return false;
    try {
      await _client!.from('user_profiles').upsert({
        'user_id': currentUser!.id,
        ...userData,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (!isAvailable) return null;
    try {
      final response = await _client!
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // ==================== Analytics Operations ====================

  /// Log user event for analytics
  Future<bool> logAnalyticsEvent({
    required String eventType,
    required Map<String, dynamic> eventData,
  }) async {
    if (!isAvailable || currentUser == null) return false;
    try {
      await _client!.from('analytics_events').insert({
        'user_id': currentUser!.id,
        'event_type': eventType,
        'event_data': eventData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
      return false;
    }
  }

  /// Get analytics data for a user
  Future<List<Map<String, dynamic>>> getAnalyticsData(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!isAvailable) return [];
    try {
      var query = _client!.from('analytics_events').select().eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      final response = await query.order('timestamp', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting analytics data: $e');
      return [];
    }
  }

  // ==================== Health Data Sync ====================

  /// Sync workout data to cloud
  Future<bool> syncWorkoutData(List<Map<String, dynamic>> workouts) async {
    if (!isAvailable || workouts.isEmpty) return false;
    try {
      final dataWithTimestamp = workouts.map((w) => {
        ...w,
        'synced_at': DateTime.now().toIso8601String(),
      }).toList();

      await _client!.from('workout_data').upsert(dataWithTimestamp);
      return true;
    } catch (e) {
      debugPrint('Error syncing workout data: $e');
      return false;
    }
  }

  /// Sync hydration data to cloud
  Future<bool> syncHydrationData(List<Map<String, dynamic>> hydrationLogs) async {
    if (!isAvailable || hydrationLogs.isEmpty) return false;
    try {
      final dataWithTimestamp = hydrationLogs.map((h) => {
        ...h,
        'synced_at': DateTime.now().toIso8601String(),
      }).toList();

      await _client!.from('hydration_data').upsert(dataWithTimestamp);
      return true;
    } catch (e) {
      debugPrint('Error syncing hydration data: $e');
      return false;
    }
  }

  /// Sync health metrics to cloud
  Future<bool> syncHealthMetrics(List<Map<String, dynamic>> metrics) async {
    if (!isAvailable || metrics.isEmpty) return false;
    try {
      final dataWithTimestamp = metrics.map((m) => {
        ...m,
        'synced_at': DateTime.now().toIso8601String(),
      }).toList();

      await _client!.from('health_metrics').upsert(dataWithTimestamp);
      return true;
    } catch (e) {
      debugPrint('Error syncing health metrics: $e');
      return false;
    }
  }

  /// Sync mood logs to cloud
  Future<bool> syncMoodData(List<Map<String, dynamic>> moodLogs) async {
    if (!isAvailable || moodLogs.isEmpty) return false;
    try {
      final dataWithTimestamp = moodLogs.map((m) => {
        ...m,
        'synced_at': DateTime.now().toIso8601String(),
      }).toList();

      await _client!.from('mood_data').upsert(dataWithTimestamp);
      return true;
    } catch (e) {
      debugPrint('Error syncing mood data: $e');
      return false;
    }
  }

  /// Sync food logs to cloud
  Future<bool> syncFoodLogs(List<Map<String, dynamic>> foodLogs) async {
    if (!isAvailable || foodLogs.isEmpty) return false;
    try {
      final dataWithTimestamp = foodLogs.map((f) => {
        ...f,
        'synced_at': DateTime.now().toIso8601String(),
      }).toList();

      await _client!.from('food_log_data').upsert(dataWithTimestamp);
      return true;
    } catch (e) {
      debugPrint('Error syncing food logs: $e');
      return false;
    }
  }

  // ==================== AI Predictions & Recommendations ====================

  /// Get health predictions based on user data
  Future<Map<String, dynamic>?> getHealthPredictions(String userId) async {
    if (!isAvailable) return null;
    try {
      // Call Supabase Edge Function for AI predictions
      final response = await _client!.functions.invoke(
        'health-predictions',
        body: {'user_id': userId},
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting health predictions: $e');
      return null;
    }
  }

  /// Get personalized recommendations
  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    if (!isAvailable) return [];
    try {
      final response = await _client!.functions.invoke(
        'get-recommendations',
        body: {'user_id': userId},
      );
      return List<Map<String, dynamic>>.from(response.data ?? []);
    } catch (e) {
      debugPrint('Error getting recommendations: $e');
      return [];
    }
  }

  /// Generate meal plan using AI
  Future<Map<String, dynamic>?> generateMealPlan({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    if (!isAvailable) return null;
    try {
      final response = await _client!.functions.invoke(
        'generate-meal-plan',
        body: {
          'user_id': userId,
          'preferences': preferences,
        },
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error generating meal plan: $e');
      return null;
    }
  }

  /// Predict period cycle
  Future<Map<String, dynamic>?> predictPeriodCycle(String userId) async {
    if (!isAvailable) return null;
    try {
      final response = await _client!.functions.invoke(
        'predict-period-cycle',
        body: {'user_id': userId},
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error predicting period cycle: $e');
      return null;
    }
  }

  // ==================== Real-time Subscriptions ====================

  /// Subscribe to user data changes
  RealtimeChannel? subscribeToUserData(
    String userId,
    void Function(Map<String, dynamic>) onData,
  ) {
    if (!isAvailable) return null;
    try {
      return _client!
          .channel('user_data_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'user_profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              onData(payload.newRecord);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error subscribing to user data: $e');
      return null;
    }
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      await _client!.removeChannel(channel);
    } catch (e) {
      debugPrint('Error unsubscribing: $e');
    }
  }

  // ==================== Batch Operations ====================

  /// Sync all user data to cloud
  Future<Map<String, bool>> syncAllData({
    List<Map<String, dynamic>>? workouts,
    List<Map<String, dynamic>>? hydration,
    List<Map<String, dynamic>>? healthMetrics,
    List<Map<String, dynamic>>? moodLogs,
    List<Map<String, dynamic>>? foodLogs,
  }) async {
    final results = <String, bool>{};

    if (workouts != null && workouts.isNotEmpty) {
      results['workouts'] = await syncWorkoutData(workouts);
    }
    if (hydration != null && hydration.isNotEmpty) {
      results['hydration'] = await syncHydrationData(hydration);
    }
    if (healthMetrics != null && healthMetrics.isNotEmpty) {
      results['health_metrics'] = await syncHealthMetrics(healthMetrics);
    }
    if (moodLogs != null && moodLogs.isNotEmpty) {
      results['mood_logs'] = await syncMoodData(moodLogs);
    }
    if (foodLogs != null && foodLogs.isNotEmpty) {
      results['food_logs'] = await syncFoodLogs(foodLogs);
    }

    return results;
  }
}
