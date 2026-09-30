class ApiEndpoints {
  const ApiEndpoints._();

  // 后端 FastAPI 服务地址
  static const String baseUrl = 'http://127.0.0.1:8000';
  // Home
  static const String homeOverview = '/api/home/overview';
  // Account
  static const String currentUser = '/api/user';

  static const String accounts = '/api/accounts';

  static const String assetSummary = '/api/accounts/summary';
  // Transaction
  static const String transactions = '/api/transactions';

  static const String transactionSummary =
      '/api/transactions/summary';
  // Analysis
  static const String analysis = '/api/analysis';
  // AI
  static const String aiChat = '/api/ai/chat';
}