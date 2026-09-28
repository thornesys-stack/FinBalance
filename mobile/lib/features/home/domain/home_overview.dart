class HomeOverview {
  const HomeOverview({
    this.income,
    this.expense,
    this.periodBalance,
    this.totalAssets,
    this.totalLiabilities,
    this.netWorth,
    this.baseCurrency = 'CNY',
    this.aiSummary,
  });

  final double? income;
  final double? expense;
  final double? periodBalance;
  // V1 资产模型字段。
  final double? totalAssets;
  final double? totalLiabilities;
  final double? netWorth;

  final String baseCurrency;
  final String? aiSummary;

  factory HomeOverview.fromJson(Map<String, dynamic> json) {
    return HomeOverview(
      income: _number(json['income']),
      expense: _number(json['expense']),
      periodBalance: _number(json['balance'] ?? json['periodBalance']),
      totalAssets: _number(json['totalAssets']),
      totalLiabilities: _number(json['totalLiabilities']),
      netWorth: _number(json['netWorth']),
      baseCurrency: json['baseCurrency']?.toString() ?? 'CNY',
      aiSummary: json['aiSummary']?.toString(),
    );
  }

  static double? _number(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
