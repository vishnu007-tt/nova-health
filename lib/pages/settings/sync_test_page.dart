import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/workout_model.dart';
import '../../models/hydration_model.dart';
import '../../models/mood_log_model.dart';
import 'package:uuid/uuid.dart';

/// Test page to manually trigger sync and add test data
class SyncTestPage extends StatefulWidget {
  const SyncTestPage({super.key});

  @override
  State<SyncTestPage> createState() => _SyncTestPageState();
}

class _SyncTestPageState extends State<SyncTestPage> {
  final _dbService = DatabaseService();
  bool _syncing = false;
  String _status = 'Ready to sync';

  Future<void> _addTestWorkout() async {
    try {
      final workout = WorkoutModel(
        id: const Uuid().v4(),
        userId: 'test-user-123', // Replace with actual user ID
        date: DateTime.now(),
        activityType: 'Running',
        durationMinutes: 30,
        intensity: 'moderate',
        caloriesBurned: 250,
        createdAt: DateTime.now(),
      );

      await _dbService.saveWorkout(workout);
      
      setState(() {
        _status = 'Test workout added!';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Test workout added')),
      );
    } catch (e) {
      setState(() {
        _status = 'Error adding workout: $e';
      });
    }
  }

  Future<void> _addTestHydration() async {
    try {
      final hydration = HydrationModel(
        id: const Uuid().v4(),
        userId: 'test-user-123', // Replace with actual user ID
        amountMl: 250,
        timestamp: DateTime.now(),
      );

      await _dbService.saveHydration(hydration);
      
      setState(() {
        _status = 'Test hydration added!';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Test hydration added')),
      );
    } catch (e) {
      setState(() {
        _status = 'Error adding hydration: $e';
      });
    }
  }

  Future<void> _addTestMood() async {
    try {
      final mood = MoodLogModel(
        id: const Uuid().v4(),
        userId: 'test-user-123', // Replace with actual user ID
        mood: 'happy',
        intensity: 8,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _dbService.saveMoodLog(mood);
      
      setState(() {
        _status = 'Test mood added!';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Test mood added')),
      );
    } catch (e) {
      setState(() {
        _status = 'Error adding mood: $e';
      });
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _syncing = true;
      _status = 'Syncing to Supabase...';
    });

    try {
      final success = await _dbService.syncToCloud();
      
      setState(() {
        _syncing = false;
        _status = success 
            ? '✅ Sync completed successfully!' 
            : '⚠️ Sync completed with some issues';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Data synced to Supabase!' : '⚠️ Sync had issues'),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _syncing = false;
        _status = '❌ Sync failed: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Test'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_sync, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_syncing)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '1. Add Test Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addTestWorkout,
              icon: const Icon(Icons.fitness_center),
              label: const Text('Add Test Workout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addTestHydration,
              icon: const Icon(Icons.water_drop),
              label: const Text('Add Test Hydration'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addTestMood,
              icon: const Icon(Icons.mood),
              label: const Text('Add Test Mood'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '2. Sync to Supabase',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _syncing ? null : _syncNow,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Sync Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Instructions:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Click buttons above to add test data\n'
                      '2. Click "Sync Now" to upload to Supabase\n'
                      '3. Check Supabase Table Editor to see data\n'
                      '4. Auto-sync runs every 5 minutes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
