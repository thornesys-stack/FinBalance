/// 全部后端接口路径的单一出口 [架构 §49]。
///
/// 规则：
///   - 这里只保存 **不含 `/api/v1` 前缀** 的路径片段；
///     `/api/v1` 由本文件统一拼接（[V1.0 §5]：不要在每个 Repository 里重复写）。
///   - 路径一律 snake_case 中的 kebab（`account-connections`），
///     与后端 FastAPI 的路由前缀逐字一致（[V1.1 §48] 端点总表）。
class ApiEndpoints {
  const ApiEndpoints._();

  /// API 版本前缀 [V1.1 §5]。
  static const String apiPrefix = '/api/v1';

  /// 后端 FastAPI 服务地址。
  ///
  /// 默认值是当前联调用的局域网地址；可用 --dart-define 覆盖，避免把
  /// 环境地址写死在源码里（[V1.0 §2]：地址不要散落在 Repository 中）：
  ///
  ///     flutter run --dart-define=FINBALANCE_API_BASE_URL=http://10.0.2.2:8000
  ///
  /// 各运行环境的对应值：
  ///   Windows / Web / iOS 模拟器 → http://127.0.0.1:8000
  ///   Android 模拟器             → http://10.0.2.2:8000
  ///   真机                       → http://<开发机局域网 IP>:8000
  static const String baseUrl = String.fromEnvironment(
    'FINBALANCE_API_BASE_URL',
    defaultValue: 'http://192.168.43.131:8000',
  );

  // ---------------------------------------------------------------------------
  // Auth —— /api/v1/auth/*
  // 后端实现见 backend/app/api/auth.py。
  // ⚠️ 这些端点**不在** [V1.1 §48] 的端点总表里（那里只有 login/refresh/logout），
  //    register 与 me 是后端为「最小可用认证」补的，Auth Contract 尚未定稿。
  // ---------------------------------------------------------------------------

  static const String authRegister = '$apiPrefix/auth/register';
  static const String authLogin = '$apiPrefix/auth/login';
  static const String authRefresh = '$apiPrefix/auth/refresh';
  static const String authLogout = '$apiPrefix/auth/logout';

  /// 当前登录身份。App 启动恢复会话时用它换取用户信息。
  static const String authMe = '$apiPrefix/auth/me';

  // ---------------------------------------------------------------------------
  // 手机号 / Google 登录 —— **后端尚未实现，这里是前端预留的命名**
  //
  // 现状（已核对 backend/app/api/auth.py 与契约文档）：
  //   - 后端只有邮箱 + 密码，LoginRequest 的注释明确写了手机号/验证码/第三方
  //     登录「均未实现（需第三方）」；
  //   - FinBalance_Account_API_V1.md 的待决清单里有「[ ] 手机号登录 API」，
  //     正文也写着「手机号登录、验证码…还需要单独定义」。
  //
  // 因此这三个常量指向的端点在当前后端上会 404。前端行为由
  // `AuthFeatureFlags`（lib/features/auth/domain/auth_feature_flags.dart）
  // 统一控制：开关关闭时不会发起请求，只给出明确提示，不会假装可用。
  // 后端补齐后把对应开关置 true 即可，不需要改动任何调用代码。
  // ---------------------------------------------------------------------------

  /// 发送短信验证码。
  ///
  /// 建议 body：`{country_code: "+86", phone: "13800000000", purpose: "login"}`
  /// 建议响应 data：`{expires_in: 300, resend_after: 60}`
  static const String authSmsSend = '$apiPrefix/auth/sms/send';

  /// 手机号登录。
  ///
  /// 建议 body 二选一（互斥，后端按存在的字段判定登录方式）：
  ///   - `{country_code, phone, code}`     —— 验证码登录
  ///   - `{country_code, phone, password}` —— 密码登录
  /// 响应与 `/auth/login` 保持一致：完整 TokenPairOut。
  static const String authPhoneLogin = '$apiPrefix/auth/login/phone';

  /// Google 登录。
  ///
  /// 建议 body：`{id_token: "<Google ID Token>"}`；后端校验签名与 audience 后
  /// 按 email 关联或新建用户，返回与 `/auth/login` 一致的 TokenPairOut。
  static const String authGoogleLogin = '$apiPrefix/auth/google';

  // ---------------------------------------------------------------------------
  // Home —— /api/v1/home/overview
  // ---------------------------------------------------------------------------

  static const String homeOverview = '$apiPrefix/home/overview';

  // ---------------------------------------------------------------------------
  // Accounts —— /api/v1/accounts*
  // ---------------------------------------------------------------------------

  static const String accounts = '$apiPrefix/accounts';

  /// 总资产 / 总负债 / 净资产 [V1.1 §21]。
  static const String accountOverview = '$apiPrefix/accounts/overview';

  static const String accountConnections = '$apiPrefix/account-connections';

  // ---------------------------------------------------------------------------
  // Transactions —— 后端路径是 /api/v1/bills（[V1.1 §48] 冻结）
  // ---------------------------------------------------------------------------

  static const String bills = '$apiPrefix/bills';

  static const String billImport = '$apiPrefix/bills/import';

  // ---------------------------------------------------------------------------
  // Analysis —— /api/v1/analysis/overview
  // ---------------------------------------------------------------------------

  static const String analysisOverview = '$apiPrefix/analysis/overview';

  // ---------------------------------------------------------------------------
  // AI —— /api/v1/ai/*
  // ---------------------------------------------------------------------------

  static const String aiInsight = '$apiPrefix/ai/insight';
  static const String aiQuestions = '$apiPrefix/ai/questions';
  static const String aiChat = '$apiPrefix/ai/chat';

  // ---------------------------------------------------------------------------
  // User —— /api/v1/user
  // ---------------------------------------------------------------------------

  static const String userProfile = '$apiPrefix/user';
  static const String userData = '$apiPrefix/user/data';
}
