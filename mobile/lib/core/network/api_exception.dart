/// 统一的 API 异常。
///
/// 后端错误体（[V1.1 §40]）：
///     {"code": "UNAUTHORIZED", "message": "...", "details": {}}
///
/// 注意 [code] 是**业务错误码字符串**，成功响应里的 `code` 却是整数 200 ——
/// 同名不同义，是该契约自身的歧义。这里只承载失败侧的字符串码。
///
/// 业务判断一律用 [code]，不要匹配中文 [message]（[V1.0 §10] 的硬要求）。
class ApiException implements Exception {
  final String message;

  /// HTTP 状态码；网络层失败（连不上、超时）时为 null。
  final int? statusCode;

  /// 后端业务错误码，例如 UNAUTHORIZED / INVALID_REQUEST / DUPLICATE_TRANSACTION。
  final String? code;

  /// 后端附加信息，例如 422 的 {"errors": [...]}。
  final Map<String, dynamic>? details;

  const ApiException(this.message, {this.statusCode, this.code, this.details});

  /// 是否为「未登录 / 凭证失效」—— 前端据此触发登录态清理。
  bool get isUnauthorized =>
      statusCode == 401 || code == 'UNAUTHORIZED' || code == 'AUTH_REQUIRED';

  /// 是否为「网络层失败」，与后端返回的业务错误区分开，UI 文案不同。
  bool get isNetworkFailure => statusCode == null;

  @override
  String toString() => message;
}
