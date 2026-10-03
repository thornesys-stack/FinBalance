import '../../../core/money/currency.dart';

/// 分析页总览 [V1.1 §28]。
///
/// 后端（GET /api/v1/analysis/overview 的 data）的金额字段都是 Money 对象
/// `{amount_minor, currency}`：
/// ```json
/// {
///   "period": {...}, "base_currency": "CNY",
///   "income": {"amount_minor": ...}, "expense": {...}, "net_cash_flow": {...},
///   "saving_rate": 0.42, "bill_count": 17,
///   "categories": [
///     {"category_code": "food", "category_name": "餐饮",
///      "amount": {"amount_minor": ...}, "percentage": 38.5}
///   ], ...
/// }
/// ```
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

  factory AnalysisOverview.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as List? ?? [];

    return AnalysisOverview(
      // 后端字段名是 income / expense（不是 total_income / total_expense）。
      totalIncome: _moneyToMajor(json['income'] ?? json['total_income']),
      totalExpense: _moneyToMajor(json['expense'] ?? json['total_expense']),
      // saving_rate 可能为 null（收入为 0 时）。
      savingsRate: _toDouble(json['saving_rate'] ?? json['savings_rate']),
      categories:
          rawCategories
              .whereType<Map>()
              .map(
                (item) =>
                    CategoryAnalysis.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
    );
  }

  /// 把 `{amount_minor, currency}` 折算成主单位；裸数字按已是主单位处理。
  static double _moneyToMajor(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      final minor = map['amount_minor'] ?? map['amountMinor'];

      if (minor is num) {
        final code = map['currency']?.toString();
        final currency =
            (code != null && code.isNotEmpty)
                ? Currency.fromCode(code)
                : Currency.cny;

        var divisor = 1;
        for (var i = 0; i < currency.decimalDigits; i++) {
          divisor *= 10;
        }

        return minor / divisor;
      }

      return _toDouble(map['amount']);
    }

    return _toDouble(value);
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
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

  factory CategoryAnalysis.fromJson(Map<String, dynamic> json) {
    return CategoryAnalysis(
      // 展示名优先 category_name（后端本地化），缺失时退回稳定的 code。
      category:
          _text(json['category_name']) ??
          _text(json['category_code']) ??
          _text(json['category']) ??
          '',
      amount: AnalysisOverview._moneyToMajor(json['amount']),
      percentage: AnalysisOverview._toDouble(json['percentage']),
    );
  }

  static String? _text(dynamic value) {
    final text = value?.toString().trim();

    return (text == null || text.isEmpty) ? null : text;
  }
}
