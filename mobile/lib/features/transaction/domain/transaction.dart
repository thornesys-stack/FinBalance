class FinancialTransaction {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String? note;
  final DateTime date;

  const FinancialTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.date,
  });

  factory FinancialTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialTransaction(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      note: json['note']?.toString(),
      date: DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
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