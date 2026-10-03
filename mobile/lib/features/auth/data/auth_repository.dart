import '../../../core/auth/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/auth_feature_flags.dart';
import '../domain/auth_session.dart';
import '../domain/auth_user.dart';
import '../domain/session_restore_result.dart';
import 'auth_remote_datasource.dart';

/// Auth 的数据层 [架构 §47 §48]。
///
/// 职责边界：
///   - 把 `data` 负载映射成 Domain Model（AuthSession / AuthUser）
///   - 把令牌写进 / 读出安全存储，并同步 [ApiClient] 的内存令牌
///   - 把「凭证失效」翻译成 Domain 层的结果，而不是把 ApiException 抛给 Controller
///
/// 它**不**持有 UI 状态（那属于 AuthController），也不判断业务文案。
class AuthRepository {
  final AuthRemoteDatasource datasource;

  final ApiClient apiClient;

  final TokenStorage tokenStorage;

  factory AuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage}) {
    // 必须让 datasource 与 repository 共用**同一个** ApiClient 实例：
    // 令牌与 401 刷新都挂在 ApiClient 上，两个实例会导致
    // "登录成功但后续请求不带 Authorization" 这类难查的问题。
    final resolvedClient = apiClient ?? ApiClient();

    return AuthRepository._(
      apiClient: resolvedClient,
      tokenStorage: tokenStorage ?? TokenStorage(),
      datasource: AuthRemoteDatasource(apiClient: resolvedClient),
    );
  }

  AuthRepository._({
    required this.apiClient,
    required this.tokenStorage,
    required this.datasource,
  });

  // ---------------------------------------------------------------------------
  // 登录 / 注册 / 登出
  // ---------------------------------------------------------------------------

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await datasource.login(email: email, password: password);
    final session = AuthSession.fromJson(data);

    await _persist(session);

    return session;
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    String? name,
    String locale = 'zh-CN',
    String timeZone = 'Asia/Shanghai',
    String baseCurrency = 'CNY',
  }) async {
    final data = await datasource.register(
      email: email,
      password: password,
      name: name,
      locale: locale,
      timeZone: timeZone,
      baseCurrency: baseCurrency,
    );
    final session = AuthSession.fromJson(data);

    await _persist(session);

    return session;
  }

  /// 登出。
  ///
  /// 先尽力通知后端吊销 refresh token，再清本地 —— 顺序不能反：
  /// 反了的话请求会因为本地 token 已清而变成匿名调用，后端收不到 user_id，
  /// 那条 refresh token 会一直留在库里直到过期。
  /// 但后端调用失败**不能**阻塞登出（离线时也要能登出），所以吞掉异常。
  Future<void> logout() async {
    try {
      await datasource.logout();
    } on ApiException {
      // 忽略：本地清理才是登出的实质。
    } catch (_) {
      // 忽略：同上。
    } finally {
      await clearSession();
    }
  }

  // ---------------------------------------------------------------------------
  // 会话恢复 / 刷新
  // ---------------------------------------------------------------------------

  /// 冷启动恢复登录态。
  Future<SessionRestoreResult> restoreSession() async {
    final stored = await tokenStorage.readTokens();

    if (stored.accessToken.isEmpty && stored.refreshToken.isEmpty) {
      apiClient.clearAccessToken();
      return const SessionRestoreResult.none();
    }

    apiClient.setAccessToken(stored.accessToken);

    try {
      final user = await fetchCurrentUser();
      return SessionRestoreResult.online(user);
    } on ApiException catch (error) {
      if (!error.isUnauthorized) {
        // 网络层失败：凭证大概率仍然有效，不能登出用户。
        return const SessionRestoreResult.offline();
      }
    }

    // access token 过期 —— 这正是 30 分钟 TTL 的日常路径。
    final refreshed = await refresh();

    if (!refreshed) {
      return const SessionRestoreResult.expired();
    }

    try {
      final user = await fetchCurrentUser();
      return SessionRestoreResult.online(user);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await clearSession();
        return const SessionRestoreResult.expired();
      }
      return const SessionRestoreResult.offline();
    }
  }

  /// 取当前登录身份。
  Future<AuthUser> fetchCurrentUser() async {
    final data = await datasource.me();
    return AuthUser.fromJson(data);
  }

  /// 用 refresh token 换新令牌对。
  ///
  /// 返回值语义：**true 表示已拿到并保存了新令牌**，false 表示
  /// refresh token 无效 / 已过期 / 网络不可用 —— 三种情况调用方都
  /// 不需要（也无法）区分，统一按"需要重新登录"处理。
  ///
  /// 本方法供 [ApiClient.tokenRefresher] 使用，因此**绝不抛异常**：
  /// 它是在其他请求的 401 分支里被调用的，一抛就把原始错误盖掉了。
  Future<bool> refresh() async {
    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final data = await datasource.refresh(refreshToken);
      final session = AuthSession.fromJson(data);

      if (!session.token.hasAccessToken) {
        return false;
      }

      await _persist(session);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 清除本地会话。
  Future<void> clearSession() async {
    apiClient.clearAccessToken();
    await tokenStorage.clearTokens();
  }

  // ---------------------------------------------------------------------------
  // 手机号 / Google 登录
  //
  // 与 [login] / [register] 完全同构：拿到 data → 映射成 AuthSession →
  // 落盘 + 同步内存令牌。差别只在请求参数。
  // ---------------------------------------------------------------------------

  /// 请求短信验证码，返回重发冷却秒数。
  ///
  /// 后端没给 `resend_after` 时回落到 [AuthFeatureFlags.defaultSmsResendSeconds]，
  /// 而不是返回 0 —— 返回 0 会让倒计时直接跳过，"重发"按钮立刻又可点，
  /// 等于没有冷却。
  Future<int> sendSmsCode({
    required String countryCode,
    required String phone,
  }) async {
    final data = await datasource.sendSmsCode(
      countryCode: countryCode,
      phone: phone,
    );

    final resendAfter = data['resend_after'];

    if (resendAfter is num) {
      return resendAfter.toInt();
    }

    if (resendAfter is String) {
      return int.tryParse(resendAfter) ??
          AuthFeatureFlags.defaultSmsResendSeconds;
    }

    return AuthFeatureFlags.defaultSmsResendSeconds;
  }

  /// 验证码登录。
  Future<AuthSession> loginWithPhoneCode({
    required String countryCode,
    required String phone,
    required String code,
  }) async {
    final data = await datasource.loginWithPhone(
      countryCode: countryCode,
      phone: phone,
      code: code,
    );

    final session = AuthSession.fromJson(data);

    await _persist(session);

    return session;
  }

  /// 手机号 + 密码登录。
  Future<AuthSession> loginWithPhonePassword({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    final data = await datasource.loginWithPhone(
      countryCode: countryCode,
      phone: phone,
      password: password,
    );

    final session = AuthSession.fromJson(data);

    await _persist(session);

    return session;
  }

  /// Google 登录。
  Future<AuthSession> loginWithGoogle({required String idToken}) async {
    final data = await datasource.loginWithGoogle(idToken);

    final session = AuthSession.fromJson(data);

    await _persist(session);

    return session;
  }

  // ---------------------------------------------------------------------------
  // 内部
  // ---------------------------------------------------------------------------

  /// 落盘 + 同步内存令牌。
  ///
  /// 两处都要写：安全存储负责跨启动，内存副本负责本次会话 ——
  /// 少了前者，冷启动要重新登录；少了后者，登录后的第一个请求仍不带
  /// Authorization 头，表现是"刚登录就 401"。
  Future<void> _persist(AuthSession session) async {
    apiClient.setAccessToken(session.token.accessToken);

    await tokenStorage.saveTokens(
      accessToken: session.token.accessToken,
      refreshToken: session.token.refreshToken,
    );
  }
}
