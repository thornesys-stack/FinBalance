import 'auth_user.dart';

/// 冷启动恢复登录态的四种结果。
///
/// 为什么要区分 [offline] 与 [expired]：
///   这两者对用户的意义完全相反 ——
///   [expired] 必须回到登录页（凭证真的没了），
///   [offline] 必须放行进主界面（凭证还在，只是这次没连上后端）。
///   若把两者合并成"恢复失败"，用户在地铁里打开 App 就会被登出，
///   而他的凭证其实完好无损。
enum SessionRestoreStatus {
  /// 本地没有凭证，从未登录（或已登出）。
  none,

  /// 凭证有效，已拿到用户信息。
  online,

  /// 本地有凭证，但本次没能向后端确认（网络不可用 / 服务未启动）。
  /// 允许进入 App，数据页各自的错误态会接管。
  offline,

  /// 凭证已失效（refresh token 也换不回新令牌）。本地凭证已清除。
  expired,
}

class SessionRestoreResult {
  final SessionRestoreStatus status;

  final AuthUser? user;

  const SessionRestoreResult._(this.status, this.user);

  const SessionRestoreResult.none() : this._(SessionRestoreStatus.none, null);

  const SessionRestoreResult.offline()
    : this._(SessionRestoreStatus.offline, null);

  const SessionRestoreResult.expired()
    : this._(SessionRestoreStatus.expired, null);

  const SessionRestoreResult.online(AuthUser user)
    : this._(SessionRestoreStatus.online, user);

  bool get isAuthenticated =>
      status == SessionRestoreStatus.online ||
      status == SessionRestoreStatus.offline;
}
