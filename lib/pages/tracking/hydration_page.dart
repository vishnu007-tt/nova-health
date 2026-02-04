import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../models/hydration_model.dart';
import '../../providers/health_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/common_widgets.dart';

const uuid = Uuid();

class HydrationPage extends ConsumerStatefulWidget {
  const HydrationPage({super.key});

  @override
  ConsumerState<HydrationPage> createState() => _HydrationPageState();
}

class _HydrationPageState extends ConsumerState<HydrationPage> {
  final _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _addHydration(int amountMl) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final hydration = HydrationModel(
      id: uuid.v4(),
      userId: user.id,
      timestamp: DateTime.now(),
      amountMl: amountMl,
      beverageType: 'water',
    );

    ref.read(hydrationProvider.notifier).addHydration(hydration);

    showSuccessSnackbar(context, 'Added ${Helpers.formatWater(amountMl)} of water!');
  }

  void _showCustomAmountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Amount'),
        content: TextField(
          controller: _customAmountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(_customAmountController.text);
              if (amount != null && amount > 0) {
                _addHydration(amount);
                _customAmountController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final hydrationLogs = ref.watch(hydrationProvider);
    final totalToday = ref.watch(todayHydrationTotalProvider);
    final goalMl = user?.dailyWaterGoalMl ?? 2000;
    final progress = (totalToday / goalMl).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),

                    // Circular progress indicator
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? Colors.green
                                    : AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: 40,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Helpers.formatWater(totalToday),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'of ${Helpers.formatWater(goalMl)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick add buttons
            Text(
              'Quick Add',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _QuickAddButton(
                  amount: 250,
                  icon: Icons.local_drink,
                  onTap: () => _addHydration(250),
                ),
                _QuickAddButton(
                  amount: 500,
                  icon: Icons.water_drop,
                  onTap: () => _addHydration(500),
                ),
                _QuickAddButton(
                  amount: 750,
                  icon: Icons.sports_bar,
                  onTap: () => _addHydration(750),
                ),
                _QuickAddButton(
                  amount: 1000,
                  icon: Icons.water,
                  onTap: () => _addHydration(1000),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showCustomAmountDialog,
              icon: const Icon(Icons.add),
              label: const Text('Custom Amount'),
            ),
            const SizedBox(height: 20),

            // Weekly chart
            if (hydrationLogs.isNotEmpty) ...[
              Card(
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
                        child: _buildWeeklyChart(user?.id ?? '', goalMl),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Today's history
            if (hydrationLogs.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s History',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    '${hydrationLogs.length} entries',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hydrationLogs.length,
                itemBuilder: (context, index) {
                  final log = hydrationLogs[hydrationLogs.length - 1 - index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.2),
                        child: const Icon(Icons.water_drop, color: Colors.blue),
                      ),
                      title: Text('${log.amountMl}ml'),
                      subtitle: Text(
                        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteLog(log.id),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(String userId, int goalMl) {
    final db = ref.read(databaseServiceProvider);
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final intakeByDay = <DateTime, int>{};
    for (final day in last7Days) {
      intakeByDay[DateTime(day.year, day.month, day.day)] =
          db.getTotalHydrationForDay(userId, day);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (goalMl * 1.5).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
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
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (index) {
          final day = last7Days[index];
          final key = DateTime(day.year, day.month, day.day);
          final intake = intakeByDay[key] ?? 0;
          final isGoalMet = intake >= goalMl;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: intake.toDouble(),
                color: isGoalMet ? Colors.green : Colors.blue,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _deleteLog(String id) {
    ref.read(hydrationProvider.notifier).deleteHydration(id);
  }
}

class _QuickAddButton extends StatelessWidget {
  final int amount;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.amount,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              '${amount}ml',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
