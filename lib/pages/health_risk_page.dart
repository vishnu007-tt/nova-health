import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../services/ml_prediction_service.dart';
import '../services/database_service.dart';
import '../services/health_insights_engine.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/health_insights_models.dart';

/// Health Risk Assessment Page - Shows ML predictions + Rule-Based Insights
class HealthRiskPage extends ConsumerStatefulWidget {
  const HealthRiskPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HealthRiskPage> createState() => _HealthRiskPageState();
}

class _HealthRiskPageState extends ConsumerState<HealthRiskPage>
    with SingleTickerProviderStateMixin {
  final MLPredictionService _mlService = MLPredictionService();
  final DatabaseService _dbService = DatabaseService();
  final HealthInsightsEngine _insightsEngine = HealthInsightsEngine();

  bool _isLoading = false;
  bool _serverAvailable = false;
  HealthRiskPrediction? _prediction;
  UserHealthInsights? _insights;
  String? _error;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // Get data for analysis
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));

      // Get all user data
      final allHydrationLogs = _dbService.getUserHydrationLogs(user.id);
      final hydrationLogs = allHydrationLogs
          .where((log) =>
              log.timestamp.isAfter(weekAgo) && log.timestamp.isBefore(now))
          .toList();

      final allMoodLogs = _dbService.getUserMoodLogs(user.id);
      final moodLogs = allMoodLogs
          .where((log) =>
              log.timestamp.isAfter(weekAgo) && log.timestamp.isBefore(now))
          .toList();

      final allSymptoms = _dbService.getUserSymptoms(user.id);
      final symptoms = allSymptoms
          .where((symptom) =>
              symptom.timestamp.isAfter(weekAgo) &&
              symptom.timestamp.isBefore(now))
          .toList();

      final workouts =
          _dbService.getUserWorkoutsByDateRange(user.id, weekAgo, now);
      final totalExerciseMinutes = workouts.fold<double>(
          0.0, (sum, workout) => sum + workout.durationMinutes.toDouble());
      final avgDailyExercise =
          workouts.isNotEmpty ? (totalExerciseMinutes / 7).round() : 0;
      final avgIntensity = workouts.isNotEmpty
          ? (workouts.map((w) => w.caloriesBurned).reduce((a, b) => a + b) /
                  workouts.length /
                  10)
              .round()
          : 5;

      // Get extended data for insights
      final healthMetrics =
          _dbService.getHealthMetricsByDateRange(user.id, ninetyDaysAgo, now);
      final allWorkouts =
          _dbService.getUserWorkoutsByDateRange(user.id, ninetyDaysAgo, now);
      final foodLogs = _dbService.getUserFoodLogs(user.id);
      final periodCycles = _dbService.getUserPeriodCycles(user.id);

      // Generate rule-based insights (always works, no server needed)
      final insights = _insightsEngine.generateInsights(
        healthMetrics: healthMetrics,
        workouts: allWorkouts,
        hydrationLogs: allHydrationLogs,
        moodLogs: allMoodLogs,
        foodLogs: foodLogs,
        periodCycles: periodCycles,
      );

      setState(() {
        _insights = insights;
      });

      // Try to get ML predictions (requires server)
      _serverAvailable = await _mlService.checkServerHealth();

      if (_serverAvailable) {
        final prediction = await _mlService.predictHealthRisk(
          user: user,
          hydrationLogs: hydrationLogs,
          moodLogs: moodLogs,
          symptoms: symptoms,
          exerciseDuration: avgDailyExercise,
          exerciseIntensity: avgIntensity.clamp(1, 10),
          sleepHours: 7.0,
        );

        setState(() {
          _prediction = prediction;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Health Analysis'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh Analysis',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'ML Risk'),
            Tab(icon: Icon(Icons.insights), text: 'Insights'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMLPredictionTab(),
                    _buildInsightsTab(),
                  ],
                ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryGreen),
          const SizedBox(height: 24),
          Text(
            'Analyzing your health data...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ML PREDICTION TAB ====================

  Widget _buildMLPredictionTab() {
    if (!_serverAvailable) {
      return _buildServerUnavailableView();
    }

    if (_prediction == null) {
      return const Center(child: Text('No prediction data available'));
    }

    final prediction = _prediction!;
    final obesity = prediction.obesityRisk;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Risk Score Card
          _buildRiskScoreCard(prediction.overallRiskScore),

          const SizedBox(height: 16),

          // Key Insights from ML
          _buildKeyInsightsCard(prediction.keyInsights),

          const SizedBox(height: 16),

          // Symptom Risk Analysis (if available)
          if (prediction.symptomRiskAnalysis != null)
            _buildSymptomRiskCard(prediction.symptomRiskAnalysis!),

          if (prediction.symptomRiskAnalysis != null)
            const SizedBox(height: 16),

          // Obesity Risk Card
          _buildObesityRiskCard(obesity),

          const SizedBox(height: 16),

          // Exercise Recommendation (if available)
          if (prediction.exerciseRecommendation != null)
            _buildExerciseCard(prediction.exerciseRecommendation!),

          const SizedBox(height: 16),

          // Recommendations
          _buildRecommendationsCard(obesity.recommendations),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildServerUnavailableView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_off, size: 64, color: Colors.orange[700]),
                const SizedBox(height: 16),
                Text(
                  'ML Server Offline',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The ML prediction server is not available. Rule-based insights are still working in the Insights tab.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[700]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.insights),
                  label: const Text('View Insights'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To enable ML predictions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'The ML server at novahealth-backend.onrender.com needs to be running.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskScoreCard(double score) {
    Color color;
    String level;

    if (score < 30) {
      color = Colors.green;
      level = 'Low Risk';
    } else if (score < 60) {
      color = Colors.orange;
      level = 'Moderate Risk';
    } else {
      color = Colors.red;
      level = 'High Risk';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Overall Health Risk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${score.toInt()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    level,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsightsCard(List<String> insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Key Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(insight)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildObesityRiskCard(ObesityRiskResult obesity) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Weight & BMI Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Risk Level', obesity.riskLevelDisplay),
            _buildInfoRow('BMI', obesity.bmi.toStringAsFixed(1)),
            _buildInfoRow('BMR', '${obesity.bmr.toStringAsFixed(0)} cal/day'),
            _buildInfoRow(
                'Confidence', '${(obesity.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            const Text(
              'Risk Distribution:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...obesity.allProbabilities.entries.map((entry) {
              final percentage = (entry.value * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key.replaceAll('_', ' '),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseRecommendation exercise) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_run, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Exercise Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Calories Burned', '${exercise.predictedCalories.toStringAsFixed(0)} cal'),
            _buildInfoRow(
                'Calories/Minute', exercise.caloriesPerMinute.toStringAsFixed(1)),
            _buildInfoRow('MET Score', exercise.metScore.toStringAsFixed(1)),
            _buildInfoRow('Intensity', exercise.intensityLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomRiskCard(SymptomRiskAnalysis analysis) {
    Color riskColor;
    IconData riskIcon;

    switch (analysis.riskLevel) {
      case 'Critical':
        riskColor = Colors.red[900]!;
        riskIcon = Icons.error;
        break;
      case 'High':
        riskColor = Colors.red;
        riskIcon = Icons.warning;
        break;
      case 'Moderate':
        riskColor = Colors.orange;
        riskIcon = Icons.info;
        break;
      default:
        riskColor = Colors.blue;
        riskIcon = Icons.check_circle;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: riskColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(riskIcon, color: riskColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Symptom Risk Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Risk Level: ${analysis.riskLevel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              analysis.urgency,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: riskColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Probable Health Conditions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...analysis.probableConditions.map((condition) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.medical_services, color: riskColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(condition, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            const Text(
              'Detected Symptoms:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...analysis.detectedSymptoms.map((symptom) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${symptom['type']} (Severity: ${symptom['severity']}/10)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Personalized Recommendations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ==================== INSIGHTS TAB ====================

  Widget _buildInsightsTab() {
    if (_insights == null) {
      return const Center(child: Text('No insights available'));
    }

    final insights = _insights!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _buildInsightsSummaryCard(insights),

          const SizedBox(height: 20),

          // Critical & Warning Insights
          if (insights.criticalInsights.isNotEmpty ||
              insights.warningInsights.isNotEmpty) ...[
            _buildSectionHeader(
              'Needs Attention',
              Icons.warning_amber_rounded,
              Colors.red[700]!,
            ),
            const SizedBox(height: 12),
            ...insights.criticalInsights.map((i) => _buildInsightCard(i)),
            ...insights.warningInsights.map((i) => _buildInsightCard(i)),
            const SizedBox(height: 20),
          ],

          // Attention Insights
          if (insights.attentionInsights.isNotEmpty) ...[
            _buildSectionHeader(
              'Worth Considering',
              Icons.lightbulb_outline,
              Colors.orange[700]!,
            ),
            const SizedBox(height: 12),
            ...insights.attentionInsights.map((i) => _buildInsightCard(i)),
            const SizedBox(height: 20),
          ],

          // Info Insights
          if (insights.infoInsights.isNotEmpty) ...[
            _buildSectionHeader(
              'Observations',
              Icons.info_outline,
              Colors.blue[700]!,
            ),
            const SizedBox(height: 12),
            ...insights.infoInsights.map((i) => _buildInsightCard(i)),
            const SizedBox(height: 20),
          ],

          // No insights message
          if (insights.totalInsights == 0 ||
              (insights.totalInsights == 1 &&
                  insights.insights.first.id == 'insufficient_data')) ...[
            _buildNoInsightsCard(),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInsightsSummaryCard(UserHealthInsights insights) {
    final hasUrgent = insights.hasUrgentInsights;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasUrgent
              ? [Colors.orange.shade400, Colors.deepOrange.shade500]
              : [AppTheme.primaryGreen, AppTheme.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (hasUrgent ? Colors.orange : AppTheme.primaryGreen)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasUrgent ? Icons.priority_high : Icons.insights,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasUrgent ? 'Action Needed' : 'Pattern Analysis',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${insights.daysOfDataAvailable} days analyzed',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  '${insights.criticalInsights.length + insights.warningInsights.length}',
                  'Urgent',
                  Icons.error_outline,
                ),
                _buildSummaryItem(
                  '${insights.attentionInsights.length}',
                  'Attention',
                  Icons.lightbulb_outline,
                ),
                _buildSummaryItem(
                  '${insights.infoInsights.length}',
                  'Info',
                  Icons.info_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(HealthInsight insight) {
    final colors = _getSeverityColors(insight.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: colors['border']!, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors['background'],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(insight.category),
            color: colors['icon'],
            size: 24,
          ),
        ),
        title: Text(
          insight.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors['background'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  insight.categoryLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors['icon'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors['badge'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  insight.severityLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors['border'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          Text(
            insight.explanation,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (insight.contributingFactors.isNotEmpty) ...[
            Text(
              'Contributing Factors:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...insight.contributingFactors.map((factor) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 6, color: colors['icon']),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          factor,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (insight.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, size: 18, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Recommendations',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...insight.recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 16, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rec,
                                style: TextStyle(fontSize: 13, color: Colors.green[800]),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.celebration, size: 64, color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          const Text(
            'Looking Good!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep logging your health data to receive personalized insights. The more data you provide, the better the analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getSeverityColors(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.critical:
        return {
          'border': Colors.red[700]!,
          'background': Colors.red[50]!,
          'icon': Colors.red[600]!,
          'badge': Colors.red[100]!,
        };
      case InsightSeverity.warning:
        return {
          'border': Colors.orange[700]!,
          'background': Colors.orange[50]!,
          'icon': Colors.orange[600]!,
          'badge': Colors.orange[100]!,
        };
      case InsightSeverity.attention:
        return {
          'border': Colors.amber[700]!,
          'background': Colors.amber[50]!,
          'icon': Colors.amber[700]!,
          'badge': Colors.amber[100]!,
        };
      case InsightSeverity.info:
        return {
          'border': Colors.blue[600]!,
          'background': Colors.blue[50]!,
          'icon': Colors.blue[600]!,
          'badge': Colors.blue[100]!,
        };
    }
  }

  IconData _getCategoryIcon(InsightCategory category) {
    switch (category) {
      case InsightCategory.weight:
        return Icons.monitor_weight_outlined;
      case InsightCategory.activity:
        return Icons.directions_run;
      case InsightCategory.sleep:
        return Icons.bedtime_outlined;
      case InsightCategory.hydration:
        return Icons.water_drop_outlined;
      case InsightCategory.stress:
        return Icons.psychology_outlined;
      case InsightCategory.mood:
        return Icons.mood;
      case InsightCategory.nutrition:
        return Icons.restaurant_outlined;
      case InsightCategory.menstrual:
        return Icons.favorite_outline;
      case InsightCategory.cardiovascular:
        return Icons.favorite;
      case InsightCategory.recovery:
        return Icons.self_improvement;
    }
  }
}
