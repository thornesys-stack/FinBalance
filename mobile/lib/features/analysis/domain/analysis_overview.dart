class AnalysisOverview {
  final double totalIncome;
  final double totalExpense;
  final double savingsRate;
  final List<CategoryAnalysis> categories;

  const AnalysisOverview({
    required this.totalIncome,
    required this.totalExpense,
    required this.savingsRate,
    required this.categories,
  });

  factory AnalysisOverview.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawCategories =
        json['categories'] as List? ?? [];

    return AnalysisOverview(
      totalIncome: _toDouble(json['total_income']),
      totalExpense: _toDouble(json['total_expense']),
      savingsRate: _toDouble(json['savings_rate']),
      categories: rawCategories
          .map(
            (item) => CategoryAnalysis.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

class CategoryAnalysis {
  final String category;
  final double amount;
  final double percentage;

  const CategoryAnalysis({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryAnalysis.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoryAnalysis(
      category: json['category']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      percentage: _toDouble(json['percentage']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}