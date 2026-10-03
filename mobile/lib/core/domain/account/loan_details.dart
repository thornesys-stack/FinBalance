import '../../money/money.dart';

// 贷款账户的基础信息。
// V1 阶段用于描述贷款账户的核心余额和还款信息。
// 不在这里实现复杂的利息预测、提前还款模拟等功能。
class LoanDetails {
  // 最初的贷款金额。
  final Money originalPrincipal;
  // 当前剩余本金。
  final Money outstandingPrincipal;
  // 每期需要偿还的金额。
  final Money installmentAmount;
  // 下一次还款日期。
  final DateTime? nextPaymentDate;
  // 贷款还款周期。
  final String? repaymentFrequency;

  const LoanDetails({
    required this.originalPrincipal,
    required this.outstandingPrincipal,
    required this.installmentAmount,
    this.nextPaymentDate,
    this.repaymentFrequency,
  });
  // 是否已经设置下一次还款日期。
  bool get hasNextPaymentDate => nextPaymentDate != null;
  // 是否已经设置还款周期。
  bool get hasRepaymentFrequency =>
      repaymentFrequency != null && repaymentFrequency!.isNotEmpty;

  LoanDetails copyWith({
    Money? originalPrincipal,
    Money? outstandingPrincipal,
    Money? installmentAmount,
    DateTime? nextPaymentDate,
    String? repaymentFrequency,
  }) {
    return LoanDetails(
      originalPrincipal: originalPrincipal ?? this.originalPrincipal,
      outstandingPrincipal: outstandingPrincipal ?? this.outstandingPrincipal,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      repaymentFrequency: repaymentFrequency ?? this.repaymentFrequency,
    );
  }

  @override
  String toString() {
    return 'LoanDetails('
        'originalPrincipal: $originalPrincipal, '
        'outstandingPrincipal: $outstandingPrincipal, '
        'installmentAmount: $installmentAmount, '
        'nextPaymentDate: $nextPaymentDate, '
        'repaymentFrequency: $repaymentFrequency'
        ')';
  }
}
