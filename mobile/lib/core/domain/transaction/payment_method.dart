// FinBalance 支付方式。
// PaymentMethod 用于描述交易发生时使用的支付渠道。
enum PaymentMethod {
  // 现金。
  cash,
  // 银行卡。
  bankCard,
  // 信用卡。
  creditCard,
  // 借记卡。
  debitCard,
  // 微信支付。
  wechatPay,
  // 支付宝。
  alipay,
  // Apple Pay。
  applePay,
  // Google Pay。
  googlePay,
  // 银行转账。
  bankTransfer,
  // 其他支付方式。
  other,
  // 未知或暂未识别。
  unknown,
}
