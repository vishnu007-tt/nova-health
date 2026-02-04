import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../models/workout_model.dart';
import '../../providers/health_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';

const uuid = Uuid();

class WorkoutLogPage extends ConsumerStatefulWidget {
  const WorkoutLogPage({super.key});

  @override
  ConsumerState<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

class _WorkoutLogPageState extends ConsumerState<WorkoutLogPage> {
  final _formKey = GlobalKey<FormState>();
  String _activityType = 'Running';
  double _duration = 30;
  String _intensity = 'moderate';
  double? _distance;
  final _notesController = TextEditingController();

  // MET values for different activities and intensities
  final Map<String, Map<String, double>> _metValues = {
    'Running': {'light': 6.0, 'moderate': 9.8, 'vigorous': 12.3},
    'Cycling': {'light': 4.0, 'moderate': 8.0, 'vigorous': 12.0},
    'Swimming': {'light': 5.8, 'moderate': 9.8, 'vigorous': 13.8},
    'Walking': {'light': 2.5, 'moderate': 3.5, 'vigorous': 5.0},
    'Gym': {'light': 3.0, 'moderate': 5.0, 'vigorous': 8.0},
    'Yoga': {'light': 2.0, 'moderate': 3.0, 'vigorous': 4.0},
    'Dancing': {'light': 3.0, 'moderate': 5.5, 'vigorous': 8.5},
    'Basketball': {'light': 4.5, 'moderate': 6.5, 'vigorous': 8.0},
    'Tennis': {'light': 5.0, 'moderate': 7.3, 'vigorous': 9.5},
    'Soccer': {'light': 5.0, 'moderate': 7.0, 'vigorous': 10.0},
  };

  double _calculateCalories() {
    final user = ref.read(currentUserProvider);
    // Use default weight of 70kg if user hasn't set their weight
    final weightKg = user?.weight ?? 70.0;

    // If distance is provided for cardio activities, use distance-based calculation
    if (_distance != null && _distance! > 0 && 
        (_activityType == 'Running' || _activityType == 'Cycling' || _activityType == 'Walking')) {
      // Distance-based calorie calculation (more accurate for cardio)
      // Running: ~1 kcal per kg per km
      // Cycling: ~0.5 kcal per kg per km  
      // Walking: ~0.7 kcal per kg per km
      double caloriesPerKgPerKm;
      if (_activityType == 'Running') {
        caloriesPerKgPerKm = 1.0;
      } else if (_activityType == 'Cycling') {
        caloriesPerKgPerKm = 0.5;
      } else { // Walking
        caloriesPerKgPerKm = 0.7;
      }
      return weightKg * _distance! * caloriesPerKgPerKm;
    }

    // Default: MET-based calculation
    final met = _metValues[_activityType]?[_intensity] ?? 5.0;
    final hours = _duration / 60;

    // Calories = MET × weight(kg) × time(hours)
    return met * weightKg * hours;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Workout Logger'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add workout form
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Log Workout',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Activity type dropdown
                      DropdownButtonFormField<String>(
                        value: _activityType,
                        decoration: const InputDecoration(
                          labelText: 'Activity Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _metValues.keys.map((activity) {
                          return DropdownMenuItem(
                            value: activity,
                            child: Text(activity),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _activityType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Duration slider
                      Text('Duration: ${_duration.toInt()} minutes'),
                      Slider(
                        value: _duration,
                        min: 5,
                        max: 180,
                        divisions: 35,
                        label: '${_duration.toInt()} min',
                        onChanged: (value) {
                          setState(() {
                            _duration = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Intensity selector
                      const Text('Intensity'),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'light',
                            label: Text('Light'),
                            icon: Icon(Icons.trending_down),
                          ),
                          ButtonSegment(
                            value: 'moderate',
                            label: Text('Moderate'),
                            icon: Icon(Icons.trending_flat),
                          ),
                          ButtonSegment(
                            value: 'vigorous',
                            label: Text('Vigorous'),
                            icon: Icon(Icons.trending_up),
                          ),
                        ],
                        selected: {_intensity},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _intensity = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Distance (optional for cardio)
                      if (_activityType == 'Running' ||
                          _activityType == 'Cycling' ||
                          _activityType == 'Walking')
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Distance (km) - Optional',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _distance = double.tryParse(value);
                          },
                        ),
                      if (_activityType == 'Running' ||
                          _activityType == 'Cycling' ||
                          _activityType == 'Walking')
                        const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Calculated calories
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimated Calories Burned:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${_calculateCalories().toInt()} kcal',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Save button
                      ElevatedButton(
                        onPressed: _saveWorkout,
                        child: const Text('Save Workout'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Workout history
            if (workouts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Workouts',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Weekly chart
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last 7 Days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildWorkoutChart(workouts),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Workout list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: workouts.length > 10 ? 10 : workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen,
                        child: Icon(
                          _getActivityIcon(workout.activityType),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(workout.activityType),
                      subtitle: Text(
                        '${workout.durationMinutes.toInt()} min • ${workout.intensity} • ${workout.caloriesBurned.toInt()} kcal',
                      ),
                      trailing: Text(
                        Helpers.formatDate(workout.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onLongPress: () => _deleteWorkout(workout.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String activity) {
    switch (activity) {
      case 'Running':
        return Icons.directions_run;
      case 'Cycling':
        return Icons.directions_bike;
      case 'Swimming':
        return Icons.pool;
      case 'Walking':
        return Icons.directions_walk;
      case 'Gym':
        return Icons.fitness_center;
      case 'Yoga':
        return Icons.self_improvement;
      case 'Dancing':
        return Icons.music_note;
      case 'Basketball':
      case 'Tennis':
      case 'Soccer':
        return Icons.sports_basketball;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildWorkoutChart(List<WorkoutModel> workouts) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final caloriesByDay = <DateTime, double>{};
    for (final day in last7Days) {
      caloriesByDay[DateTime(day.year, day.month, day.day)] = 0;
    }

    for (final workout in workouts) {
      final workoutDate = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );
      if (caloriesByDay.containsKey(workoutDate)) {
        caloriesByDay[workoutDate] = caloriesByDay[workoutDate]! + workout.caloriesBurned;
      }
    }

    final spots = <FlSpot>[];
    int index = 0;
    for (final day in last7Days) {
      final key = DateTime(day.year, day.month, day.day);
      spots.add(FlSpot(index.toDouble(), caloriesByDay[key]!));
      index++;
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                  final date = last7Days[value.toInt()];
                  return Text(
                    '${date.day}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryGreen,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryGreen.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final workout = WorkoutModel(
        id: uuid.v4(),
        userId: user.id,
        date: DateTime.now(),
        activityType: _activityType,
        durationMinutes: _duration,
        intensity: _intensity,
        distance: _distance,
        caloriesBurned: _calculateCalories(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(),
      );

      ref.read(workoutsProvider.notifier).addWorkout(workout);

      showSuccessSnackbar(context, 'Workout logged successfully!');

      // Reset form
      setState(() {
        _duration = 30;
        _intensity = 'moderate';
        _distance = null;
        _notesController.clear();
      });
    }
  }

  void _deleteWorkout(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(workoutsProvider.notifier).deleteWorkout(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
