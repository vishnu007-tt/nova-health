import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/symptom_model.dart';
import '../../models/health_metric_model.dart';
import '../../providers/tracking_providers.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/helpers.dart';

const uuid = Uuid();

class SymptomsPage extends ConsumerStatefulWidget {
  const SymptomsPage({super.key});

  @override
  ConsumerState<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends ConsumerState<SymptomsPage> {
  final _formKey = GlobalKey<FormState>();
  String _symptomType = 'Headache';
  double _severity = 5;
  String? _bodyPart;
  final _notesController = TextEditingController();
  final List<String> _selectedTriggers = [];

  final List<String> _symptomTypes = [
    'Headache',
    'Fatigue',
    'Nausea',
    'Pain',
    'Fever',
    'Dizziness',
    'Cough',
    'Sore Throat',
    'Muscle Ache',
    'Stomach Ache',
    'Anxiety',
    'Insomnia',
  ];

  final List<String> _bodyParts = [
    'Head',
    'Neck',
    'Chest',
    'Back',
    'Abdomen',
    'Arms',
    'Legs',
    'Joints',
  ];

  final List<String> _triggerOptions = [
    'Stress',
    'Lack of Sleep',
    'Weather',
    'Food',
    'Exercise',
    'Medication',
    'Menstruation',
    'Dehydration',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symptoms = ref.watch(symptomsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Symptoms Recorder'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add symptom form
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
                        'Log Symptom',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Symptom type dropdown
                      DropdownButtonFormField<String>(
                        value: _symptomType,
                        decoration: const InputDecoration(
                          labelText: 'Symptom Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _symptomTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _symptomType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Severity slider
                      Text('Severity: ${_severity.toInt()}/10'),
                      Slider(
                        value: _severity,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _severity.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            _severity = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mild', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Text('Severe', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Body part (for pain)
                      if (_symptomType == 'Pain' || _symptomType == 'Muscle Ache')
                        DropdownButtonFormField<String>(
                          value: _bodyPart,
                          decoration: const InputDecoration(
                            labelText: 'Body Part',
                            border: OutlineInputBorder(),
                          ),
                          items: _bodyParts.map((part) {
                            return DropdownMenuItem(
                              value: part,
                              child: Text(part),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _bodyPart = value;
                            });
                          },
                        ),
                      if (_symptomType == 'Pain' || _symptomType == 'Muscle Ache')
                        const SizedBox(height: 16),

                      // Triggers
                      const Text('Possible Triggers'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _triggerOptions.map((trigger) {
                          final isSelected = _selectedTriggers.contains(trigger);
                          return FilterChip(
                            label: Text(trigger),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTriggers.add(trigger);
                                } else {
                                  _selectedTriggers.remove(trigger);
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
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Save button
                      ElevatedButton(
                        onPressed: _saveSymptom,
                        child: const Text('Save Symptom'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Symptom history
            if (symptoms.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Symptoms',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: symptoms.length > 20 ? 20 : symptoms.length,
                itemBuilder: (context, index) {
                  final symptom = symptoms[index];
                  return Card(
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getSeverityColor(symptom.severity),
                        child: Text(
                          '${symptom.severity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(symptom.symptomType),
                      subtitle: Text(
                        Helpers.formatDateTime(symptom.timestamp),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSymptom(symptom.id),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (symptom.bodyPart != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Text('Body Part: ${symptom.bodyPart}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (symptom.triggers != null && symptom.triggers!.isNotEmpty) ...[
                                const Row(
                                  children: [
                                    Icon(Icons.warning, size: 16),
                                    SizedBox(width: 4),
                                    Text('Triggers:'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: symptom.triggers!
                                      .map((t) => Chip(
                                            label: Text(t, style: const TextStyle(fontSize: 12)),
                                            visualDensity: VisualDensity.compact,
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (symptom.notes != null && symptom.notes!.isNotEmpty) ...[
                                const Row(
                                  children: [
                                    Icon(Icons.note, size: 16),
                                    SizedBox(width: 4),
                                    Text('Notes:'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(symptom.notes!),
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

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }

  void _saveSymptom() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final symptomId = uuid.v4();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Save to old SymptomModel for backward compatibility
      final symptom = SymptomModel(
        id: symptomId,
        userId: user.id,
        timestamp: now,
        symptomType: _symptomType,
        severity: _severity.toInt(),
        bodyPart: _bodyPart,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        triggers: _selectedTriggers.isEmpty ? null : List.from(_selectedTriggers),
        createdAt: now,
      );

      ref.read(symptomsProvider.notifier).addSymptom(symptom);

      // ALSO save to HealthMetricModel for Supabase sync
      final db = DatabaseService();
      
      // Get or create today's health metric
      var healthMetric = db.getHealthMetricByDate(user.id, today);
      
      // If no metric exists for today, create new one
      if (healthMetric == null || healthMetric.id.isEmpty) {
        healthMetric = HealthMetricModel(
          id: uuid.v4(),
          userId: user.id,
          date: today,
          createdAt: now,
          symptoms: [_symptomType],
          symptomSeverity: {_symptomType: _severity.toInt()},
          symptomBodyParts: _bodyPart != null ? {_symptomType: _bodyPart!} : null,
          symptomTriggers: _selectedTriggers.isEmpty ? null : List.from(_selectedTriggers),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      } else {
        // Update existing metric with new symptom
        final existingSymptoms = healthMetric.symptoms ?? [];
        final existingSeverity = healthMetric.symptomSeverity ?? {};
        final existingBodyParts = healthMetric.symptomBodyParts ?? {};
        final existingTriggers = healthMetric.symptomTriggers ?? [];

        healthMetric = HealthMetricModel(
          id: healthMetric.id,
          userId: healthMetric.userId,
          date: healthMetric.date,
          weight: healthMetric.weight,
          steps: healthMetric.steps,
          sleepMinutes: healthMetric.sleepMinutes,
          mood: healthMetric.mood,
          stressLevel: healthMetric.stressLevel,
          energyLevel: healthMetric.energyLevel,
          notes: healthMetric.notes ?? _notesController.text,
          createdAt: healthMetric.createdAt,
          isPeriodDay: healthMetric.isPeriodDay,
          flowIntensity: healthMetric.flowIntensity,
          periodSymptoms: healthMetric.periodSymptoms,
          cycleDay: healthMetric.cycleDay,
          symptoms: [...existingSymptoms, _symptomType],
          symptomSeverity: {...existingSeverity, _symptomType: _severity.toInt()},
          symptomBodyParts: _bodyPart != null 
              ? {...existingBodyParts, _symptomType: _bodyPart!}
              : existingBodyParts.isNotEmpty ? existingBodyParts : null,
          symptomTriggers: _selectedTriggers.isNotEmpty
              ? [...existingTriggers, ..._selectedTriggers].toSet().toList()
              : existingTriggers.isNotEmpty ? existingTriggers : null,
        );
      }

      await db.saveHealthMetric(healthMetric);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Symptom logged successfully!')),
        );
      }

      // Reset form
      setState(() {
        _severity = 5;
        _bodyPart = null;
        _selectedTriggers.clear();
        _notesController.clear();
      });
    }
  }

  void _deleteSymptom(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Symptom'),
        content: const Text('Are you sure you want to delete this symptom record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(symptomsProvider.notifier).deleteSymptom(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
