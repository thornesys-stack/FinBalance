import 'auth_token.dart';
import 'auth_user.dart';

/// 一次成功登录 / 注册后的完整会话：令牌 + 身份。
class AuthSession {
  final AuthToken token;

  final AuthUser user;

  const AuthSession({required this.token, required this.user});

  /// 解析 `POST /auth/login` 或 `/auth/register` 的 `data` 负载。
  ///
  /// 形状（backend/app/services/auth.py 的 build_login_response）：
  /// ```json
  /// {
  ///   "user": { ... },
  ///   "access_token": "...",
  ///   "refresh_token": "...",
  ///   "expires_in": 1800,
  ///   "refresh_expires_in": 1209600
  /// }
  /// ```
  /// —— 令牌字段与 `user` **同级**，不是嵌套的 `{token: {...}}`。
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: AuthToken.fromJson(json),
      user: AuthUser.fromJson(
        json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }

  bool get isValid => token.hasAccessToken && token.hasRefreshToken;
}
