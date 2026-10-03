/// 令牌对。对应后端 `TokenPairOut`（backend/app/api/auth.py）。
///
/// JSON 形状（snake_case，[V1.1 §41]）：
/// ```json
/// {
///   "access_token": "...",
///   "refresh_token": "...",
///   "token_type": "bearer",
///   "expires_in": 1800,
///   "refresh_expires_in": 1209600
/// }
/// ```
class AuthToken {
  final String accessToken;

  final String refreshToken;

  final String tokenType;

  /// access token 有效秒数。后端 ACCESS_TTL = 30 分钟。
  final int expiresIn;

  /// refresh token 有效秒数。后端 REFRESH_TTL = 14 天。
  final int refreshExpiresIn;

  /// 本地记录令牌的获得时间，用于推算过期时刻。
  ///
  /// 为什么需要：后端只给 "expires_in"（相对秒数），不给绝对时间。
  /// 有了获得时间才能算出 [accessTokenExpiresAt]，UI 才能做
  /// "还有多久需要重新登录" 这类提示，调试时也能一眼看出是否过期。
  final DateTime obtainedAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.obtainedAt,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      expiresIn: _asInt(json['expires_in']),
      refreshExpiresIn: _asInt(json['refresh_expires_in']),
      obtainedAt: DateTime.now(),
    );
  }

  DateTime get accessTokenExpiresAt =>
      obtainedAt.add(Duration(seconds: expiresIn));

  DateTime get refreshTokenExpiresAt =>
      obtainedAt.add(Duration(seconds: refreshExpiresIn));

  bool get hasAccessToken => accessToken.isNotEmpty;

  bool get hasRefreshToken => refreshToken.isNotEmpty;

  /// Pydantic 有时把整数序列化成 double（例如 1800.0），
  /// 直接 `as int` 会抛类型异常 —— 这里统一收口。
  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  String toString() => 'AuthToken(expiresIn: ${expiresIn}s)';
}
