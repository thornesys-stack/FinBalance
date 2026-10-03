import '../../../core/money/currency.dart';

/// 首页总览 [V1.1 §23]。
///
/// 后端（GET /api/v1/home/overview 的 data）的收支字段是 Money 对象
/// `{amount_minor, currency}`，不是裸数字：
/// ```json
/// {
///   "period": {...},
///   "base_currency": "CNY",
///   "income":        {"amount_minor": 12300, "currency": "CNY"},
///   "expense":       {"amount_minor": 4500,  "currency": "CNY"},
///   "net_cash_flow": {"amount_minor": 7800,  "currency": "CNY"},
///   "saving_rate": 0.634, ...
/// }
/// ```
/// 这里把最小货币单位折算成主单位 double（展示层不再做换算）。
class HomeOverview {
  final double income;
  final double expense;
  final double balance;
  final double savingsRate;

  const HomeOverview({
    required this.income,
    required this.expense,
    required this.balance,
    required this.savingsRate,
  });

  factory HomeOverview.fromJson(Map<String, dynamic> json) {
    return HomeOverview(
      income: _moneyToMajor(json['income']),
      expense: _moneyToMajor(json['expense']),
      // 「结余」在后端叫 net_cash_flow（本期净现金流）。
      balance: _moneyToMajor(json['net_cash_flow'] ?? json['balance']),
      // saving_rate 可能为 null（收入为 0 时除不出来），null 按 0 展示。
      savingsRate: _toDouble(json['saving_rate'] ?? json['savings_rate']),
    );
  }

  /// 把 `{amount_minor, currency}` 折算成主单位；裸数字按已是主单位处理。
  static double _moneyToMajor(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      final minor = map['amount_minor'] ?? map['amountMinor'];

      if (minor is num) {
        final currency = _currencyFromJson(map['currency']);

        return minor / _pow10(currency.decimalDigits);
      }

      return _toDouble(map['amount']);
    }

    return _toDouble(value);
  }

  static Currency _currencyFromJson(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return Currency.fromCode(value);
    }

    return Currency.cny;
  }

  static int _pow10(int exponent) {
    var result = 1;

    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }

    return result;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
