import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/wellness_providers.dart';
import '../../services/database_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/quick_action_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final hydrationTotal = ref.watch(todayHydrationTotalProvider);
    final nutritionTotals = ref.watch(todayNutritionTotalsProvider);
    final meditationStreak = ref.watch(meditationStreakProvider);

    // Calculate weekly stats
    final weeklyStats = _calculateWeeklyStats(ref, user?.id);

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(hydrationProvider.notifier).refresh();
              ref.read(workoutsProvider.notifier).refresh();
              ref.read(foodLogsProvider.notifier).refresh();
              ref.read(moodLogsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card with streak indicators
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Helpers.getGreeting(),
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user?.fullName ?? user?.username ?? 'User',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                        if (meditationStreak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '$meditationStreak day${meditationStreak > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // This Week Summary
            Text(
              'This Week',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _WeeklySummaryCard(weeklyStats: weeklyStats),
            const SizedBox(height: 20),

            // Today's Overview
            Text(
              'Today\'s Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Water',
                    value: Helpers.formatWater(hydrationTotal),
                    goal: Helpers.formatWater(user?.dailyWaterGoalMl ?? 2000),
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    progress: hydrationTotal / (user?.dailyWaterGoalMl ?? 2000),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Calories',
                    value: '${nutritionTotals.calories.toInt()}',
                    goal: '${user?.dailyCalorieGoal ?? 2000}',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    progress: nutritionTotals.calories / (user?.dailyCalorieGoal ?? 2000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Weight',
                    value: user?.weight != null ? Helpers.formatWeight(user!.weight!) : '--',
                    goal: user?.targetWeight != null ? 'Goal: ${Helpers.formatWeight(user!.targetWeight!)}' : '--',
                    icon: Icons.monitor_weight,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'BMI',
                    value: user?.bmi != null ? user!.bmi!.toStringAsFixed(1) : '--',
                    goal: user?.bmiCategory ?? '--',
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                CompactQuickActionCard(
                  icon: Icons.water_drop,
                  title: 'Log Water',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.hydration),
                ),
                CompactQuickActionCard(
                  icon: Icons.restaurant,
                  title: 'Log Meal',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.nutrition),
                ),
                CompactQuickActionCard(
                  icon: Icons.fitness_center,
                  title: 'Log Workout',
                  color: AppTheme.primaryGreen,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.workoutLog),
                ),
                CompactQuickActionCard(
                  icon: Icons.mood,
                  title: 'Log Mood',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.moodTracker),
                ),
                CompactQuickActionCard(
                  icon: Icons.analytics,
                  title: 'Health Analysis',
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.healthRisk),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateWeeklyStats(WidgetRef ref, String? userId) {
    if (userId == null) {
      return {
        'workoutCount': 0,
        'avgHydration': 0.0,
        'avgCalories': 0.0,
        'totalWorkoutMinutes': 0.0,
      };
    }

    final db = DatabaseService();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Get workouts for the week
    final workouts = db.getUserWorkoutsByDateRange(userId, weekStart, weekEnd);
    final totalWorkoutMinutes = workouts.fold<double>(0, (sum, w) => sum + w.durationMinutes);

    // Calculate average hydration
    double totalHydration = 0;
    int daysWithHydration = 0;
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dailyTotal = db.getTotalHydrationForDay(userId, date);
      if (dailyTotal > 0) {
        totalHydration += dailyTotal;
        daysWithHydration++;
      }
    }
    final avgHydration = daysWithHydration > 0 ? totalHydration / daysWithHydration : 0.0;

    // Calculate average calories
    double totalCalories = 0;
    int daysWithFood = 0;
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final foodLogs = db.getUserFoodLogsByDate(userId, date);
      final dailyCalories = foodLogs.fold<double>(0, (sum, f) => sum + f.calories);
      if (dailyCalories > 0) {
        totalCalories += dailyCalories;
        daysWithFood++;
      }
    }
    final avgCalories = daysWithFood > 0 ? totalCalories / daysWithFood : 0.0;

    return {
      'workoutCount': workouts.length,
      'avgHydration': avgHydration,
      'avgCalories': avgCalories,
      'totalWorkoutMinutes': totalWorkoutMinutes,
    };
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final Map<String, dynamic> weeklyStats;

  const _WeeklySummaryCard({required this.weeklyStats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeeklyStatItem(
                  icon: Icons.fitness_center,
                  color: AppTheme.primaryGreen,
                  value: '${weeklyStats['workoutCount']}',
                  label: 'Workouts',
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _WeeklyStatItem(
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  value: Helpers.formatWater(weeklyStats['avgHydration'].toInt()),
                  label: 'Avg Water',
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _WeeklyStatItem(
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  value: '${weeklyStats['avgCalories'].toInt()}',
                  label: 'Avg Cals',
                ),
              ],
            ),
            if (weeklyStats['totalWorkoutMinutes'] > 0) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 20, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    '${weeklyStats['totalWorkoutMinutes'].toInt()} minutes of exercise this week',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeeklyStatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _WeeklyStatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String goal;
  final IconData icon;
  final Color color;
  final double? progress;

  const _StatCard({
    required this.title,
    required this.value,
    required this.goal,
    required this.icon,
    required this.color,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              goal,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress! > 1 ? 1 : progress,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

