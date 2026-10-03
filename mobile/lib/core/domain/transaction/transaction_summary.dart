import '../../money/money.dart';

// FinBalance 交易汇总。
class TransactionSummary {
  // 总收入。
  final Money income;
  // 总支出。
  final Money expense;
  // 净现金流 / 结余。
  final Money balance;
  // 交易数量。
  final int transactionCount;

  const TransactionSummary({
    required this.income,
    required this.expense,
    required this.balance,
    this.transactionCount = 0,
  });
  // 创建当前汇总的副本。
  TransactionSummary copyWith({
    Money? income,
    Money? expense,
    Money? balance,
    int? transactionCount,
  }) {
    return TransactionSummary(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  String toString() {
    return 'TransactionSummary('
        'income: $income, '
        'expense: $expense, '
        'balance: $balance, '
        'transactionCount: $transactionCount'
        ')';
  }
}
