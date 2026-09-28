class ApiContracts {
  ApiContracts._();
  // CONFIRMED: 当前后端已有的首页概览接口。
  static const homeOverview = '/api/v1/home/overview';
  // PLANNED: 后续账户体系使用。
  static const accountsOverview = '/api/v1/accounts/overview';
  // PLANNED: 后续交易体系使用。
  static const transactions = '/api/v1/transactions';
  // PLANNED: 后续风险反馈使用。
  static const transactionRiskFeedback =
      '/api/v1/transactions/{transactionId}/risk-feedback';
  // PLANNED: 后续消息中心使用。
  static const notifications = '/api/v1/notifications';
}