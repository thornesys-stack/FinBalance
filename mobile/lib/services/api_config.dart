class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';
  // API 接口路径
  static const String apiPrefix = '/api/v1';
  // API 接口
  // 首页
  static const String homeOverview =
      '$apiPrefix/home/overview';

  // 账单
  static const String bills =
      '$apiPrefix/bills';

  // 分析
  static const String analysisOverview =
      '$apiPrefix/analysis/overview';

  // AI
  static const String aiInsight =
      '$apiPrefix/ai/insight';

  static const String aiChat =
      '$apiPrefix/ai/chat';

  // 用户
  static const String profile =
      '$apiPrefix/user/profile';

  static const String settings =
      '$apiPrefix/user/settings';
  // 完整 URL
  static String get homeOverviewUrl =>
      '$baseUrl$homeOverview';

  static String get billsUrl =>
      '$baseUrl$bills';

  static String get analysisOverviewUrl =>
      '$baseUrl$analysisOverview';

  static String get aiInsightUrl =>
      '$baseUrl$aiInsight';

  static String get aiChatUrl =>
      '$baseUrl$aiChat';

  static String get profileUrl =>
      '$baseUrl$profile';

  static String get settingsUrl =>
      '$baseUrl$settings';
}