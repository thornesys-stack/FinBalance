class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(
    Map<String, dynamic> json,
  ) {
    return Currency(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
    );
  }
}