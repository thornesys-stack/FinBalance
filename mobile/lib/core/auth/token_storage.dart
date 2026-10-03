import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 令牌对（access + refresh）。
class StoredTokens {
  final String accessToken;
  final String refreshToken;

  const StoredTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  bool get isEmpty => accessToken.isEmpty && refreshToken.isEmpty;
}

/// 登录凭证的本地持久化。
///
/// 为什么用 Keychain / Keystore（flutter_secure_storage）而不是 SharedPreferences：
///   refresh token 有效期 14 天，等价于长期口令；明文落在
///   应用私有目录里在 root / 越狱设备上可读。[架构 §26] 要求
///   「敏感金融数据 → Local / Secure Storage」，凭证属于最敏感的一类。
///
/// 所有方法都吞掉底层异常：部分平台（尤其是 Web 与某些 Android 机型）
/// 安全存储会抛 PlatformException。此时**降级为未登录**比崩掉进程合理 ——
/// 用户重新登录一次即可，而不是整个 App 打不开。
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (_) {
      // 写失败不抛出：内存里已经有 token，本次会话仍可用，
      // 只是下次冷启动需要重新登录。
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<StoredTokens> readTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();

    return StoredTokens(
      accessToken: access ?? '',
      refreshToken: refresh ?? '',
    );
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (_) {
      // 同上：清理失败也不能阻塞登出流程。
    }
  }

  /// 是否存在登录状态。
  ///
  /// 注意只检查 access token：refresh token 单独存在没有意义
  /// （access 过期时刷新流程会自己处理），而 access 存在但 refresh 缺失的
  /// 情况反而应该让用户重新登录。
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
