class TransactionSummary {
  final double income;
  final double expense;
  final double balance;

  const TransactionSummary({
    required this.income,
    required this.expense,
    required this.balance,
  });

  factory TransactionSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionSummary(
      income: _toDouble(json['income']),
      expense: _toDouble(json['expense']),
      balance: _toDouble(json['balance']),
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