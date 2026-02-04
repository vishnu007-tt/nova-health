// Health Insights Models for Rule-Based Pattern Detection

enum InsightSeverity {
  info,      // General information
  warning,   // Needs attention soon
  attention, // Should address
  critical   // Urgent - consult healthcare provider
}

enum TrendDirection {
  increasing,
  decreasing,
  stable
}

enum InsightCategory {
  weight,
  activity,
  sleep,
  hydration,
  stress,
  mood,
  nutrition,
  menstrual,
  cardiovascular,
  recovery,
}

class HealthMetricTrend {
  final String metricName;
  final double currentValue;
  final double baselineValue;
  final double percentChange;
  final TrendDirection trendDirection;
  final int dataPointsAnalyzed;

  HealthMetricTrend({
    required this.metricName,
    required this.currentValue,
    required this.baselineValue,
    required this.percentChange,
    required this.trendDirection,
    this.dataPointsAnalyzed = 0,
  });

  bool get isSignificant => percentChange.abs() > 5;
}

class HealthInsight {
  final String id;
  final String title;
  final InsightSeverity severity;
  final InsightCategory category;
  final String explanation;
  final List<String> contributingFactors;
  final List<String> recommendations;
  final DateTime generatedAt;
  final String? iconName;

  HealthInsight({
    required this.id,
    required this.title,
    required this.severity,
    required this.category,
    required this.explanation,
    required this.contributingFactors,
    this.recommendations = const [],
    DateTime? generatedAt,
    this.iconName,
  }) : generatedAt = generatedAt ?? DateTime.now();

  String get severityLabel {
    switch (severity) {
      case InsightSeverity.info:
        return 'Info';
      case InsightSeverity.warning:
        return 'Warning';
      case InsightSeverity.attention:
        return 'Attention';
      case InsightSeverity.critical:
        return 'Critical';
    }
  }

  String get categoryLabel {
    switch (category) {
      case InsightCategory.weight:
        return 'Weight';
      case InsightCategory.activity:
        return 'Activity';
      case InsightCategory.sleep:
        return 'Sleep';
      case InsightCategory.hydration:
        return 'Hydration';
      case InsightCategory.stress:
        return 'Stress';
      case InsightCategory.mood:
        return 'Mood';
      case InsightCategory.nutrition:
        return 'Nutrition';
      case InsightCategory.menstrual:
        return 'Menstrual';
      case InsightCategory.cardiovascular:
        return 'Heart Health';
      case InsightCategory.recovery:
        return 'Recovery';
    }
  }
}

class UserHealthInsights {
  final List<HealthInsight> insights;
  final int daysOfDataAvailable;
  final DateTime generatedAt;
  final Map<InsightCategory, int> insightsByCategory;

  UserHealthInsights({
    required this.insights,
    required this.daysOfDataAvailable,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now(),
       insightsByCategory = _categorizeInsights(insights);

  static Map<InsightCategory, int> _categorizeInsights(List<HealthInsight> insights) {
    final Map<InsightCategory, int> counts = {};
    for (final insight in insights) {
      counts[insight.category] = (counts[insight.category] ?? 0) + 1;
    }
    return counts;
  }

  List<HealthInsight> get criticalInsights =>
      insights.where((i) => i.severity == InsightSeverity.critical).toList();

  List<HealthInsight> get warningInsights =>
      insights.where((i) => i.severity == InsightSeverity.warning).toList();

  List<HealthInsight> get attentionInsights =>
      insights.where((i) => i.severity == InsightSeverity.attention).toList();

  List<HealthInsight> get infoInsights =>
      insights.where((i) => i.severity == InsightSeverity.info).toList();

  bool get hasUrgentInsights => criticalInsights.isNotEmpty || warningInsights.isNotEmpty;

  int get totalInsights => insights.length;
}
