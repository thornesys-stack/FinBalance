import '../../money/money.dart';

/// 信用卡账户的详细财务信息。
/// V1 阶段只描述信用卡最核心的额度与还款信息。
/// 不在这里实现利息预测、提前还款模拟等 V2 能力。
class CreditCardDetails {
  // 信用额度。
  final Money creditLimit;
  // 当前已经使用的信用额度。
  final Money usedCredit;
  // 当前剩余可用额度。
  final Money availableCredit;
  // 当前账单本期应还金额。
  final Money currentDue;
  // 当前账单最低还款金额。
  final Money minimumDue;
  // 当前账单还款日期。
  final DateTime? paymentDueDate;

  const CreditCardDetails({
    required this.creditLimit,
    required this.usedCredit,
    required this.availableCredit,
    required this.currentDue,
    required this.minimumDue,
    this.paymentDueDate,
  });
  // 是否已经设置还款日期。
  bool get hasPaymentDueDate => paymentDueDate != null;
  // 当前是否存在待还款金额。
  bool get hasOutstandingPayment => currentDue.amountMinor > 0;

  CreditCardDetails copyWith({
    Money? creditLimit,
    Money? usedCredit,
    Money? availableCredit,
    Money? currentDue,
    Money? minimumDue,
    DateTime? paymentDueDate,
  }) {
    return CreditCardDetails(
      creditLimit: creditLimit ?? this.creditLimit,
      usedCredit: usedCredit ?? this.usedCredit,
      availableCredit: availableCredit ?? this.availableCredit,
      currentDue: currentDue ?? this.currentDue,
      minimumDue: minimumDue ?? this.minimumDue,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
    );
  }

  @override
  String toString() {
    return 'CreditCardDetails('
        'creditLimit: $creditLimit, '
        'usedCredit: $usedCredit, '
        'availableCredit: $availableCredit, '
        'currentDue: $currentDue, '
        'minimumDue: $minimumDue, '
        'paymentDueDate: $paymentDueDate'
        ')';
  }
}
