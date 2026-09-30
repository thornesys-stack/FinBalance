class FinancialAccount {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final bool enabled;

  const FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.enabled,
  });

  factory FinancialAccount.fromJson(
    Map<String, dynamic> json,
  ) {
    return FinancialAccount(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      balance: _toDouble(json['balance']),
      currency: json['currency']?.toString() ?? 'CNY',
      enabled: json['enabled'] as bool? ?? true,
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