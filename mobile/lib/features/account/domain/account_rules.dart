class AccountRules {
  final bool automaticCategorization;
  final bool anomalyDetection;
  final bool monthlyReport;
  final bool aiAssistant;

  const AccountRules({
    required this.automaticCategorization,
    required this.anomalyDetection,
    required this.monthlyReport,
    required this.aiAssistant,
  });

  factory AccountRules.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccountRules(
      automaticCategorization:
          json['automatic_categorization'] as bool? ?? true,
      anomalyDetection:
          json['anomaly_detection'] as bool? ?? true,
      monthlyReport:
          json['monthly_report'] as bool? ?? true,
      aiAssistant:
          json['ai_assistant'] as bool? ?? true,
    );
  }
}