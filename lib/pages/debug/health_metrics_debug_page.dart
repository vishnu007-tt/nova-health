import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_metric_model.dart';

class HealthMetricsDebugPage extends ConsumerWidget {
  const HealthMetricsDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Health Metrics Debug')),
        body: const Center(child: Text('No user logged in')),
      );
    }

    final db = DatabaseService();
    final allMetrics = db.getUserHealthMetrics(user.id);
    final metricsWithSymptoms = db.getHealthMetricsWithSymptoms(user.id);
    final periodDays = db.getPeriodDays(user.id);

    return Scaffold(
      backgroundColor: AppTheme.lightPeach,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('Health Metrics Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force sync
              db.syncToCloud();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing to cloud...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Total Health Metrics: ${allMetrics.length}'),
                    Text('Metrics with Symptoms: ${metricsWithSymptoms.length}'),
                    Text('Period Days: ${periodDays.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // All Metrics
            Text(
              'All Health Metrics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            
            if (allMetrics.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No health metrics found'),
                ),
              )
            else
              ...allMetrics.map((metric) => _buildMetricCard(context, metric)),

            const SizedBox(height: 16),

            // Metrics with Symptoms
            Text(
              'Metrics with Symptoms',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            
            if (metricsWithSymptoms.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No symptoms recorded in health metrics'),
                ),
              )
            else
              ...metricsWithSymptoms.map((metric) => _buildSymptomCard(context, metric)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, HealthMetricModel metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${metric.date.day}/${metric.date.month}/${metric.date.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'ID: ${metric.id.substring(0, 8)}...',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (metric.weight != null) Text('Weight: ${metric.weight} kg'),
            if (metric.steps != null) Text('Steps: ${metric.steps}'),
            if (metric.sleepMinutes != null) 
              Text('Sleep: ${(metric.sleepMinutes! / 60).toStringAsFixed(1)} hrs'),
            if (metric.mood != null) Text('Mood: ${metric.mood}'),
            if (metric.stressLevel != null) Text('Stress: ${metric.stressLevel}/10'),
            if (metric.energyLevel != null) Text('Energy: ${metric.energyLevel}/10'),
            if (metric.isPeriodDay) 
              Text('Period Day: Yes (${metric.flowIntensity ?? "N/A"})'),
            if (metric.symptoms != null && metric.symptoms!.isNotEmpty)
              Text(
                'Symptoms: ${metric.symptoms!.join(", ")}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            if (metric.symptomSeverity != null && metric.symptomSeverity!.isNotEmpty)
              Text('Severity: ${metric.symptomSeverity}'),
            if (metric.notes != null) 
              Text('Notes: ${metric.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCard(BuildContext context, HealthMetricModel metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${metric.date.day}/${metric.date.month}/${metric.date.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${metric.symptoms?.length ?? 0} symptoms',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Symptoms: ${metric.symptoms!.join(", ")}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (metric.symptomSeverity != null && metric.symptomSeverity!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Severity: ${metric.symptomSeverity}'),
            ],
            if (metric.symptomBodyParts != null && metric.symptomBodyParts!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Body Parts: ${metric.symptomBodyParts}'),
            ],
            if (metric.symptomTriggers != null && metric.symptomTriggers!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Triggers: ${metric.symptomTriggers!.join(", ")}'),
            ],
            if (metric.notes != null) ...[
              const SizedBox(height: 4),
              Text('Notes: ${metric.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}
