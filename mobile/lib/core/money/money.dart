import 'currency.dart';

// FinBalance 的金融金额模型。
class Money {
  // 金额的最小货币单位。
  final int amountMinor;
  // 当前金额所属货币。
  final Currency currency;

  const Money({required this.amountMinor, required this.currency});
  // 零金额。
  factory Money.zero(Currency currency) {
    return Money(amountMinor: 0, currency: currency);
  }
  // 判断金额是否为零。
  bool get isZero => amountMinor == 0;
  // 判断金额是否为正数。
  bool get isPositive => amountMinor > 0;
  // 判断金额是否为负数。
  bool get isNegative => amountMinor < 0;
  // 返回绝对值。
  Money abs() {
    return Money(amountMinor: amountMinor.abs(), currency: currency);
  }

  // 金额相加。
  Money operator +(Money other) {
    _ensureSameCurrency(other);

    return Money(
      amountMinor: amountMinor + other.amountMinor,
      currency: currency,
    );
  }

  // 金额相减。
  Money operator -(Money other) {
    _ensureSameCurrency(other);

    return Money(
      amountMinor: amountMinor - other.amountMinor,
      currency: currency,
    );
  }

  // 金额取负。
  Money operator -() {
    return Money(amountMinor: -amountMinor, currency: currency);
  }

  void _ensureSameCurrency(Money other) {
    if (currency.code != other.currency.code) {
      throw ArgumentError(
        '不同货币不能直接进行金额运算: '
        '${currency.code} vs ${other.currency.code}',
      );
    }
  }

  @override
  String toString() {
    return 'Money('
        'amountMinor: $amountMinor, '
        'currency: ${currency.code}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Money &&
        other.amountMinor == amountMinor &&
        other.currency.code == currency.code;
  }

  @override
  int get hashCode {
    return Object.hash(amountMinor, currency.code);
  }
}
