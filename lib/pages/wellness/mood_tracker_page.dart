import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../models/mood_log_model.dart';
import '../../providers/wellness_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/helpers.dart';

const uuid = Uuid();

class MoodTrackerPage extends ConsumerStatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  ConsumerState<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends ConsumerState<MoodTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  String _mood = 'okay';
  double _intensity = 5;
  final List<String> _selectedFactors = [];
  final _notesController = TextEditingController();

  final Map<String, Map<String, dynamic>> _moods = {
    'great': {'emoji': '😄', 'color': Colors.green, 'label': 'Great'},
    'good': {'emoji': '🙂', 'color': Colors.lightGreen, 'label': 'Good'},
    'okay': {'emoji': '😐', 'color': Colors.orange, 'label': 'Okay'},
    'bad': {'emoji': '😞', 'color': Colors.deepOrange, 'label': 'Bad'},
    'terrible': {'emoji': '😢', 'color': Colors.red, 'label': 'Terrible'},
  };

  final List<String> _factorOptions = [
    'Sleep',
    'Exercise',
    'Work',
    'Relationships',
    'Weather',
    'Health',
    'Diet',
    'Stress',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodLogs = ref.watch(moodLogsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Mood Tracker'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add mood form
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
                        'How are you feeling?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),

                      // Mood selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _moods.entries.map((entry) {
                          final isSelected = _mood == entry.key;
                          return GestureDetector(
                            onTap: () => setState(() => _mood = entry.key),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? entry.value['color']
                                        : Colors.grey[200],
                                    border: Border.all(
                                      color: isSelected
                                          ? entry.value['color']
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      entry.value['emoji'],
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.value['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Intensity slider
                      Text('Intensity: ${_intensity.toInt()}/10'),
                      Slider(
                        value: _intensity,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _intensity.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            _intensity = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Contributing factors
                      const Text('What might be affecting your mood?'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _factorOptions.map((factor) {
                          final isSelected = _selectedFactors.contains(factor);
                          return FilterChip(
                            label: Text(factor),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFactors.add(factor);
                                } else {
                                  _selectedFactors.remove(factor);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'How are you feeling today?',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _logMood,
                        child: const Text('Save Mood'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Mood trends chart
            if (moodLogs.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Trends (Last 30 Days)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildMoodChart(moodLogs),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Mood history
            if (moodLogs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Moods',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: moodLogs.length > 20 ? 20 : moodLogs.length,
                itemBuilder: (context, index) {
                  final log = moodLogs[index];
                  final moodData = _moods[log.mood]!;

                  return Card(
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: moodData['color'],
                        child: Text(
                          moodData['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(moodData['label']),
                      subtitle: Text(
                        '${Helpers.formatDateTime(log.timestamp)} • Intensity: ${log.intensity}/10',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMood(log.id),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (log.factors.isNotEmpty) ...[
                                const Text(
                                  'Contributing Factors:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: log.factors
                                      .map((f) => Chip(
                                            label: Text(f, style: const TextStyle(fontSize: 12)),
                                            visualDensity: VisualDensity.compact,
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (log.notes != null && log.notes!.isNotEmpty) ...[
                                const Text(
                                  'Notes:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(log.notes!),
                              ],
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildMoodChart(List<MoodLogModel> logs) {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    final recentLogs = logs.where((log) => log.timestamp.isAfter(last30Days)).toList();

    if (recentLogs.isEmpty) {
      return const Center(child: Text('Not enough data to show chart'));
    }

    final moodToValue = {
      'terrible': 1.0,
      'bad': 3.0,
      'okay': 5.0,
      'good': 7.0,
      'great': 9.0,
    };

    final spots = recentLogs.asMap().entries.map((entry) {
      final value = moodToValue[entry.value.mood] ?? 5.0;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 10,
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

  void _logMood() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final moodLog = MoodLogModel(
      id: uuid.v4(),
      userId: user.id,
      timestamp: DateTime.now(),
      mood: _mood,
      intensity: _intensity.toInt(),
      factors: List.from(_selectedFactors),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
    );

    ref.read(moodLogsProvider.notifier).addMoodLog(moodLog);

    showSuccessSnackbar(context, 'Mood logged successfully!');

    setState(() {
      _intensity = 5;
      _selectedFactors.clear();
      _notesController.clear();
    });
  }

  void _deleteMood(String id) {
    ref.read(moodLogsProvider.notifier).deleteMoodLog(id);
  }
}
