class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(
    double value, {
    String symbol = '¥',
  }) {
    return '$symbol${value.toStringAsFixed(2)}';
  }
}