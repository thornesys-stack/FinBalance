// FinBalance 全局货币模型。
class Currency {
  // ISO 4217 货币代码。
  final String code;
  // 货币显示名称。
  final String name;
  // 常用货币符号。
  final String symbol;
  // 该货币通常使用的小数位。
  final int decimalDigits;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
  });
  // 根据 ISO 4217 货币代码获取系统内置货币。
  factory Currency.fromCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'CNY':
        return cny;

      case 'USD':
        return usd;

      case 'JPY':
        return jpy;

      case 'EUR':
        return eur;

      case 'GBP':
        return gbp;

      default:
        throw FormatException('Unsupported currency code: $code');
    }
  }

  // 人民币。
  static const cny = Currency(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    decimalDigits: 2,
  );

  // 美元。
  static const usd = Currency(
    code: 'USD',
    name: 'United States Dollar',
    symbol: '\$',
    decimalDigits: 2,
  );

  // 日元。
  static const jpy = Currency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    decimalDigits: 0,
  );

  // 欧元。
  static const eur = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    decimalDigits: 2,
  );

  // 英镑。
  static const gbp = Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    decimalDigits: 2,
  );

  @override
  String toString() {
    return code;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
