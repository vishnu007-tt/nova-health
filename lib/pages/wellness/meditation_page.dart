import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/meditation_session_model.dart';
import '../../providers/wellness_providers.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

const uuid = Uuid();

class MeditationPage extends ConsumerStatefulWidget {
  const MeditationPage({super.key});

  @override
  ConsumerState<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends ConsumerState<MeditationPage> with TickerProviderStateMixin {
  bool _isTimerActive = false;
  int _selectedDuration = 5;
  int _remainingSeconds = 0;
  Timer? _timer;
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breatheController.dispose();
    super.dispose();
  }

  void _startMeditation() {
    setState(() {
      _isTimerActive = true;
      _remainingSeconds = _selectedDuration * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeMeditation();
      }
    });
  }

  void _stopMeditation() {
    _timer?.cancel();
    setState(() {
      _isTimerActive = false;
      _remainingSeconds = 0;
    });
  }

  void _completeMeditation() {
    _timer?.cancel();

    final user = ref.read(currentUserProvider);
    if (user != null) {
      final session = MeditationSessionModel(
        id: uuid.v4(),
        userId: user.id,
        timestamp: DateTime.now(),
        type: 'meditation',
        durationMinutes: _selectedDuration,
        exerciseName: 'Meditation Timer',
        completed: true,
        createdAt: DateTime.now(),
      );

      ref.read(meditationSessionsProvider.notifier).addSession(session);
    }

    setState(() {
      _isTimerActive = false;
      _remainingSeconds = 0;
    });

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meditation Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Great job! You completed $_selectedDuration minutes of meditation.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _logBreathingExercise(String exerciseName, int duration) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final session = MeditationSessionModel(
      id: uuid.v4(),
      userId: user.id,
      timestamp: DateTime.now(),
      type: 'breathing',
      durationMinutes: duration,
      exerciseName: exerciseName,
      completed: true,
      createdAt: DateTime.now(),
    );

    ref.read(meditationSessionsProvider.notifier).addSession(session);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$exerciseName completed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(meditationSessionsProvider);
    final streak = ref.watch(meditationStreakProvider);
    final totalMinutes = ref.read(meditationSessionsProvider.notifier).getTotalMinutes();
    final sessionCount = ref.read(meditationSessionsProvider.notifier).getSessionCount();

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Meditation & Breathing'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streak days',
                      color: Colors.orange,
                    ),
                    _StatItem(
                      icon: Icons.timer,
                      label: 'Total Time',
                      value: '$totalMinutes min',
                      color: Colors.blue,
                    ),
                    _StatItem(
                      icon: Icons.self_improvement,
                      label: 'Sessions',
                      value: '$sessionCount',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            // Meditation Timer
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Meditation Timer',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),

                    if (_isTimerActive) ...[
                      // Active timer
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryGreen,
                            width: 8,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Breathe...'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _stopMeditation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Stop'),
                      ),
                    ] else ...[
                      // Duration selector
                      const Text('Select Duration'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [5, 10, 15, 20, 30].map((duration) {
                          final isSelected = _selectedDuration == duration;
                          return ChoiceChip(
                            label: Text('$duration min'),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedDuration = duration;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _startMeditation,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Meditation'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Breathing Exercises
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Breathing Exercises',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Breathing exercise cards
            _BreathingExerciseCard(
              title: 'Box Breathing',
              description: '4-4-4-4 pattern: Inhale, Hold, Exhale, Hold',
              icon: Icons.crop_square,
              color: Colors.blue,
              onStart: () => _startBreathingExercise('Box Breathing'),
            ),
            _BreathingExerciseCard(
              title: '4-7-8 Breathing',
              description: 'Inhale 4, Hold 7, Exhale 8 - Great for sleep',
              icon: Icons.bedtime,
              color: Colors.purple,
              onStart: () => _startBreathingExercise('4-7-8 Breathing'),
            ),
            _BreathingExerciseCard(
              title: 'Deep Breathing',
              description: 'Simple deep breaths to reduce stress',
              icon: Icons.air,
              color: Colors.green,
              onStart: () => _startBreathingExercise('Deep Breathing'),
            ),
            const SizedBox(height: 16),

            // Session history
            if (sessions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Sessions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sessions.length > 10 ? 10 : sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: session.type == 'meditation'
                            ? Colors.purple
                            : Colors.blue,
                        child: Icon(
                          session.type == 'meditation'
                              ? Icons.self_improvement
                              : Icons.air,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(session.exerciseName ?? session.type),
                      subtitle: Text(
                        '${session.durationMinutes} min • ${Helpers.formatDateTime(session.timestamp)}',
                      ),
                      trailing: session.completed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
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

  void _startBreathingExercise(String exerciseName) {
    showDialog(
      context: context,
      builder: (context) => _BreathingExerciseDialog(
        exerciseName: exerciseName,
        onComplete: (duration) {
          _logBreathingExercise(exerciseName, duration);
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _BreathingExerciseCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onStart;

  const _BreathingExerciseCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_filled),
          color: color,
          iconSize: 32,
          onPressed: onStart,
        ),
      ),
    );
  }
}

class _BreathingExerciseDialog extends StatefulWidget {
  final String exerciseName;
  final Function(int) onComplete;

  const _BreathingExerciseDialog({
    required this.exerciseName,
    required this.onComplete,
  });

  @override
  State<_BreathingExerciseDialog> createState() => _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<_BreathingExerciseDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _cyclesCompleted = 0;
  String _instruction = 'Inhale';
  int _startTime = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 100, end: 200).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _instruction = 'Exhale';
          });
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _cyclesCompleted++;
            _instruction = 'Inhale';
          });
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exerciseName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Cycle: $_cyclesCompleted'),
          const SizedBox(height: 20),
          Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                _instruction,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Follow the circle'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final duration = ((DateTime.now().millisecondsSinceEpoch - _startTime) / 60000).ceil();
            widget.onComplete(duration > 0 ? duration : 1);
            Navigator.pop(context);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
