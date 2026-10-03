import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

/// Auth 模块的 HTTP 出口。
///
/// 只做两件事：拼参数、取 `data`。**不做**任何 JSON→Domain 的映射
/// （那是 [AuthRepository] 的职责），也不碰 token 存储。
///
/// 关于 `authenticated` 参数：
///   - login / register / refresh 必须为 false：
///     这三者本身就是「还没有有效 access token」时才调用的。
///     若带上过期的旧 token，ApiClient 会先触发一次刷新，
///     刷新又失败，等于每次登录多打两个无谓的请求。
///   - me / logout 必须为 true。
class AuthRemoteDatasource {
  final ApiClient apiClient;

  AuthRemoteDatasource({required this.apiClient});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.authLogin,
      authenticated: false,
      body: {'email': email, 'password': password},
    );

    return ApiClient.unwrapMap(response);
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
    String locale = 'zh-CN',
    String timeZone = 'Asia/Shanghai',
    String baseCurrency = 'CNY',
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.authRegister,
      authenticated: false,
      body: {
        'email': email,
        'password': password,
        // name 选填：后端是 str | None，传 null 与不传等价，
        // 但显式传 null 更贴近契约（避免"少传字段"的歧义）。
        'name': name,
        'locale': locale,
        'time_zone': timeZone,
        'base_currency': baseCurrency,
      },
    );

    return ApiClient.unwrapMap(response);
  }

  /// 用 refresh token 换新令牌对（后端会轮换 refresh token）。
  ///
  /// 调用方是 [AuthRepository.refresh]，它的失败路径必须自己兜住 ——
  /// 本方法在 refresh token 失效时抛 [ApiException]（401 UNAUTHORIZED）。
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await apiClient.post(
      ApiEndpoints.authRefresh,
      authenticated: false,
      body: {'refresh_token': refreshToken},
    );

    return ApiClient.unwrapMap(response);
  }

  Future<Map<String, dynamic>> me() async {
    final response = await apiClient.get(ApiEndpoints.authMe);

    return ApiClient.unwrapMap(response);
  }

  Future<void> logout() async {
    await apiClient.post(ApiEndpoints.authLogout);
  }

  // ---------------------------------------------------------------------------
  // 手机号 / Google 登录
  //
  // ⚠️ 这三个方法对应的后端端点**尚不存在**（见 ApiEndpoints 里的说明与
  //    AuthFeatureFlags）。代码先按建议契约写好，是为了后端补齐之后
  //    前端一行都不用改。未接入时调用方（AuthController）会提前拦下，
  //    不会真的发到这里。
  // ---------------------------------------------------------------------------

  /// 请求短信验证码。
  ///
  /// 期望响应 data：`{expires_in: 300, resend_after: 60}`
  Future<Map<String, dynamic>> sendSmsCode({
    required String countryCode,
    required String phone,
    String purpose = 'login',
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.authSmsSend,
      authenticated: false,
      body: {'country_code': countryCode, 'phone': phone, 'purpose': purpose},
    );

    return ApiClient.unwrapMap(response);
  }

  /// 手机号登录。[code] 与 [password] 二选一。
  Future<Map<String, dynamic>> loginWithPhone({
    required String countryCode,
    required String phone,
    String? code,
    String? password,
  }) async {
    // 两个都传或都不传都是调用方的 bug，尽早炸掉比让后端返回 422 更好排查。
    assert(
      (code == null) != (password == null),
      'sms code and password are mutually exclusive',
    );

    final response = await apiClient.post(
      ApiEndpoints.authPhoneLogin,
      authenticated: false,
      body: {
        'country_code': countryCode,
        'phone': phone,
        if (code != null) 'code': code,
        if (password != null) 'password': password,
      },
    );

    return ApiClient.unwrapMap(response);
  }

  /// Google 登录：把 SDK 拿到的 id_token 交给后端校验。
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final response = await apiClient.post(
      ApiEndpoints.authGoogleLogin,
      authenticated: false,
      body: {'id_token': idToken},
    );

    return ApiClient.unwrapMap(response);
  }
}
