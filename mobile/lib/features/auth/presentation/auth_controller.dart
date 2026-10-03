import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../domain/auth_feature_flags.dart';
import '../domain/auth_user.dart';
import '../domain/session_restore_result.dart';

/// 登录态。
enum AuthStatus {
  /// 尚未完成冷启动检查 —— 此时不能决定显示登录页还是主界面。
  unknown,

  /// 已登录（含 [AuthStatus.unknown] 之外的"离线但凭证在"）。
  authenticated,

  /// 未登录，应显示登录页。
  unauthenticated,
}

/// 认证状态机。
///
/// 为什么需要一个 Controller 而不是让页面各自管状态：
///   登录态是**全局**的 —— 启动分流、401 自动登出、账户页的登出按钮
///   都要读同一份状态。分散在页面里会出现"退出登录后首页还在发请求"。
///
/// 依赖方向保持 [架构 §47]：
///   Page → AuthController → AuthRepository → ApiClient → Backend
class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  final ApiClient apiClient;

  AuthController({required this.repository, required this.apiClient}) {
    // 装配 401 自动刷新：ApiClient 在收到 401 时会回调这里。
    // 放在构造里而不是 bootstrap 里，是为了让登录之后的任何时候都生效。
    apiClient.tokenRefresher = _handleTokenRefresh;
  }

  AuthStatus _status = AuthStatus.unknown;

  AuthUser? _user;

  bool _submitting = false;

  bool _sendingCode = false;

  /// 短信重发间隔，来自后端 `resend_after`，失败时回落到默认值。
  int _smsResendSeconds = AuthFeatureFlags.defaultSmsResendSeconds;

  String? _errorMessage;

  /// 非错误类的**会话级**提示（例如"离线模式：未能连接到服务器"）。
  /// 账户页会读取它，所以只放跨页面仍然成立的信息。
  String? _notice;

  /// 非错误类的**页面级**提示，例如"该登录方式尚未接入后端"。
  ///
  /// 与 [notice] 分开是有意的：这两类信息都"不是错误"，但生命周期完全不同 ——
  /// [notice] 描述的是本次会话的状态（离线），切到别的页面依然成立；
  /// [infoMessage] 只是当前这一屏对一个按钮点击的解释，
  /// 出现在账户页上会很莫名其妙。
  String? _infoMessage;

  AuthStatus get status => _status;

  AuthUser? get user => _user;

  bool get isSubmitting => _submitting;

  /// 正在请求短信验证码。
  bool get isSendingCode => _sendingCode;

  /// 短信重发冷却秒数。
  int get smsResendSeconds => _smsResendSeconds;

  String? get errorMessage => _errorMessage;

  String? get notice => _notice;

  String? get infoMessage => _infoMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ---------------------------------------------------------------------------
  // 冷启动
  // ---------------------------------------------------------------------------

  /// 冷启动检查。由 AuthGate 在首帧后调用一次。
  Future<void> bootstrap() async {
    final result = await repository.restoreSession();

    _notice = null;

    switch (result.status) {
      case SessionRestoreStatus.online:
        _user = result.user;
        _status = AuthStatus.authenticated;

      case SessionRestoreStatus.offline:
        _user = null;
        _status = AuthStatus.authenticated;
        _notice = '当前离线，展示的是上次同步的数据';

      case SessionRestoreStatus.none:
      case SessionRestoreStatus.expired:
        _user = null;
        _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 账号登录 / 注册 / 登出
  // ---------------------------------------------------------------------------

  Future<bool> login({required String email, required String password}) async {
    return _run(() async {
      final session = await repository.login(
        email: email.trim(),
        password: password,
      );

      _user = session.user;
      _status = AuthStatus.authenticated;
      _notice = null;
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
    String locale = 'zh-CN',
    String timeZone = 'Asia/Shanghai',
    String baseCurrency = 'CNY',
  }) async {
    return _run(() async {
      final session = await repository.register(
        email: email.trim(),
        password: password,
        name: name?.trim(),
        locale: locale,
        timeZone: timeZone,
        baseCurrency: baseCurrency,
      );

      _user = session.user;
      _status = AuthStatus.authenticated;
      _notice = null;
    });
  }

  Future<void> logout() async {
    _submitting = true;
    _errorMessage = null;
    notifyListeners();

    await repository.logout();

    _user = null;
    _status = AuthStatus.unauthenticated;
    _notice = null;
    _submitting = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 手机号登录（后端尚未实现，见 AuthFeatureFlags.phoneLogin）
  // ---------------------------------------------------------------------------

  /// 请求短信验证码。成功返回 true，并把重发间隔写进 [smsResendSeconds]。
  ///
  /// 刻意**不**走 [_run]：它不改登录态，只影响验证码按钮，
  /// 若共用 `_submitting`，输入框会因为"正在发验证码"而整体禁用。
  Future<bool> sendSmsCode({
    required String countryCode,
    required String phone,
  }) async {
    if (!AuthFeatureFlags.phoneLogin) {
      _setInfoMessage(AuthFeatureFlags.phoneUnavailableMessage);
      return false;
    }

    _sendingCode = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      _smsResendSeconds = await repository.sendSmsCode(
        countryCode: countryCode,
        phone: phone,
      );

      return true;
    } on ApiException catch (error) {
      _errorMessage = _humanize(error);
      return false;
    } catch (error) {
      _errorMessage = '验证码发送失败，请稍后重试（$error）';
      return false;
    } finally {
      _sendingCode = false;
      notifyListeners();
    }
  }

  /// 验证码登录。
  Future<bool> loginWithPhoneCode({
    required String countryCode,
    required String phone,
    required String code,
  }) async {
    if (!AuthFeatureFlags.phoneLogin) {
      _setInfoMessage(AuthFeatureFlags.phoneUnavailableMessage);
      return false;
    }

    return _run(() async {
      final session = await repository.loginWithPhoneCode(
        countryCode: countryCode,
        phone: phone,
        code: code,
      );

      _user = session.user;
      _status = AuthStatus.authenticated;
      _notice = null;
    });
  }

  /// 手机号 + 密码登录。
  Future<bool> loginWithPhonePassword({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    if (!AuthFeatureFlags.phoneLogin) {
      _setInfoMessage(AuthFeatureFlags.phoneUnavailableMessage);
      return false;
    }

    return _run(() async {
      final session = await repository.loginWithPhonePassword(
        countryCode: countryCode,
        phone: phone,
        password: password,
      );

      _user = session.user;
      _status = AuthStatus.authenticated;
      _notice = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Google 登录（后端与 SDK 都尚未接入，见 AuthFeatureFlags.googleLogin）
  // ---------------------------------------------------------------------------

  /// Google 登录入口。
  ///
  /// 打开开关之前，这里只会给出**明确的原因**，不会发起任何请求 ——
  /// 一个点了没反应或者报 404 的按钮，比明说"还没接入"更让人困惑。
  Future<bool> signInWithGoogle() async {
    if (!AuthFeatureFlags.googleLogin) {
      _setInfoMessage(AuthFeatureFlags.googleUnavailableMessage);
      return false;
    }

    final idToken = await _obtainGoogleIdToken();

    if (idToken == null || idToken.isEmpty) {
      _setInfoMessage(AuthFeatureFlags.googleSdkMissingMessage);
      return false;
    }

    return _run(() async {
      final session = await repository.loginWithGoogle(idToken: idToken);

      _user = session.user;
      _status = AuthStatus.authenticated;
      _notice = null;
    });
  }

  /// 从 Google Sign-In SDK 取 id_token。
  ///
  /// 目前恒为 null：pubspec 里还没有 `google_sign_in`，也就没有任何地方
  /// 能产生 id_token。把这一步单独抽出来，是为了让"还差哪一块"在代码里
  /// 显式可见 —— 接入 SDK 时只需要改这一个方法。
  Future<String?> _obtainGoogleIdToken() async => null;

  // ---------------------------------------------------------------------------
  // 提示管理
  // ---------------------------------------------------------------------------

  /// 清除当前错误与页面级提示（用户再次输入时调用）。
  void clearError() {
    if (_errorMessage == null && _infoMessage == null) {
      return;
    }

    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void _setInfoMessage(String message) {
    _infoMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 内部
  // ---------------------------------------------------------------------------

  /// 统一的"提交一次认证请求"流程：置忙 → 执行 → 收错误 → 置闲 → 通知。
  Future<bool> _run(Future<void> Function() action) async {
    _submitting = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on ApiException catch (error) {
      _errorMessage = _humanize(error);
      return false;
    } catch (error) {
      _errorMessage = '操作失败，请稍后重试（$error）';
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// 把异常翻译成能直接显示给用户的文案。
  ///
  /// 后端的中文 `message` 已经是可展示的（"邮箱或密码不正确"），优先用它；
  /// 只有网络层失败（没有 statusCode）时才用本地兜底文案。
  String _humanize(ApiException error) {
    if (error.isNetworkFailure) {
      return '无法连接服务器，请检查后端是否已启动、地址是否可达';
    }
    return error.message;
  }

  /// ApiClient 在 401 时的回调。
  Future<bool> _handleTokenRefresh() async {
    final refreshed = await repository.refresh();

    if (!refreshed) {
      // 刷新失败 = 会话彻底失效。这里必须落到未登录态，
      // 否则界面会停在一个所有请求都 401 的"假登录"状态。
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = '登录状态已失效，请重新登录';
      notifyListeners();
    }

    return refreshed;
  }
}
