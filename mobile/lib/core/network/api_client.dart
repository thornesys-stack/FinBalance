import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/token_storage.dart';
import '../constants/api_endpoints.dart';
import 'api_exception.dart';

/// 刷新凭证的回调：返回 true 表示已拿到新 access token，可以重试原请求。
typedef TokenRefresher = Future<bool> Function();

/// 统一的 HTTP 出口 [架构 §49]。
///
/// 职责：
///   - 拼 URL / 注入 headers / JSON 编解码
///   - 注入 `Authorization: Bearer <access_token>`
///   - 收到 401 时**只重试一次**刷新，再失败即抛出
///   - 把后端的 `{code, message, details}` 错误体翻译成 [ApiException]
///
/// 所有 Feature Repository 共用同一个实例（[架构 §49]：不要重复创建 HTTP Client），
/// 这样 token 只需要维护一份，401 刷新也只发生一次。
///
/// ⚠️ 返回值语义：**原样返回解码后的响应体**，不做 envelope 解包。
///    成功体形如 `{code: 200, message: "success", data: {...}}`，
///    调用方用 [unwrap] 取 `data`。保留原始体是为了让需要读 `message`
///    的调用方（例如注册成功提示）仍能拿到完整信息。
class ApiClient {
  final http.Client _client;

  final TokenStorage _tokenStorage;

  /// 由 AuthController 在启动时装配。为 null 时不尝试刷新，
  /// 401 直接抛出 —— 未登录场景（登录/注册本身）就是这种状态。
  TokenRefresher? tokenRefresher;

  /// 内存中的 access token。
  ///
  /// 刻意不每次请求都读一次安全存储：FlutterSecureStorage 在部分平台是
  /// 平台通道调用，逐请求读取会给列表页带来可见卡顿。
  String? _accessToken;

  ApiClient({http.Client? client, TokenStorage? tokenStorage})
    : _client = client ?? http.Client(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  bool get hasAccessToken => (_accessToken ?? '').isNotEmpty;

  /// 从安全存储恢复登录态（App 启动时调用一次）。
  Future<void> restoreAccessToken() async {
    _accessToken = await _tokenStorage.getAccessToken();
  }

  void setAccessToken(String? token) {
    _accessToken = (token ?? '').isEmpty ? null : token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  // -------------------------------------------------------------------------
  // 请求
  // -------------------------------------------------------------------------

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _send(
      authenticated: authenticated,
      request:
          () => _client.get(
            _buildUri(path, queryParameters: queryParameters),
            headers: _headers(authenticated: authenticated),
          ),
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send(
      authenticated: authenticated,
      request:
          () => _client.post(
            _buildUri(path),
            headers: _headers(authenticated: authenticated),
            body: body == null ? null : jsonEncode(body),
          ),
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send(
      authenticated: authenticated,
      request:
          () => _client.put(
            _buildUri(path),
            headers: _headers(authenticated: authenticated),
            body: body == null ? null : jsonEncode(body),
          ),
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send(
      authenticated: authenticated,
      request:
          () => _client.patch(
            _buildUri(path),
            headers: _headers(authenticated: authenticated),
            body: body == null ? null : jsonEncode(body),
          ),
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send(
      authenticated: authenticated,
      request:
          () => _client.delete(
            _buildUri(path),
            headers: _headers(authenticated: authenticated),
            body: body == null ? null : jsonEncode(body),
          ),
    );
  }

  // -------------------------------------------------------------------------
  // 内部
  // -------------------------------------------------------------------------

  /// 发送请求；401 时最多刷新一次并重试。
  ///
  /// 为什么要在这里做而不是每个 Repository 各写一次：
  ///   access token 只有 30 分钟 TTL（后端 ACCESS_TTL），一次会话里必然过期。
  ///   放在出口层，业务代码不需要知道有 refresh 这回事。
  Future<dynamic> _send({
    required Future<http.Response> Function() request,
    required bool authenticated,
  }) async {
    http.Response response;

    try {
      response = await request();
    } on Exception catch (error) {
      // 连不上 / 超时 / DNS 失败：与「后端返回了错误」是两类问题，
      // statusCode 留空让 UI 能区分文案（"网络不可用" vs "后端拒绝"）。
      throw ApiException('网络请求失败，请检查网络或服务地址（$error）');
    }

    if (response.statusCode == 401 && authenticated && tokenRefresher != null) {
      final refreshed = await tokenRefresher!();
      if (refreshed) {
        try {
          response = await request();
        } on Exception catch (error) {
          throw ApiException('网络请求失败，请检查网络或服务地址（$error）');
        }
      }
    }

    return _handleResponse(response);
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: queryParameters);
  }

  Map<String, String> _headers({required bool authenticated}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _accessToken;

    if (authenticated && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic decodedBody;

    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    throw _toApiException(statusCode, decodedBody);
  }

  /// 把后端的错误体翻译成 [ApiException]。
  ///
  /// 取字段的优先级 message → detail → error，是**故意的**：
  ///   - V1.1 的后端错误体是 `{code, message, details}`
  ///   - 但 V1.0 Account 契约写的是 `{detail, code}`，两种都可能遇到
  ///   - 只认一种的后果是错误提示永远显示兜底文案，排查时看不到真正原因
  ApiException _toApiException(int statusCode, dynamic decodedBody) {
    String message = _defaultMessageFor(statusCode);
    String? code;
    Map<String, dynamic>? details;

    if (decodedBody is Map) {
      final map = Map<String, dynamic>.from(decodedBody);

      final rawCode = map['code'];
      if (rawCode is String && rawCode.isNotEmpty) {
        code = rawCode;
      }

      for (final key in const ['message', 'detail', 'error']) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          message = value;
          break;
        }
        // FastAPI 原生的 422 体把 `detail` 放成**数组**：
        //   {"detail":[{"loc":["body","email"],"msg":"value is not a valid email address...","type":"value_error"}]}
        // 只认字符串的话，这种情况会一路掉到兜底文案「参数校验失败」，
        // 真正的原因（哪个字段、为什么）全被吞掉 —— 用户只会看到一个
        // 既不指明字段也不说明理由的提示。
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is Map && first['msg'] is String) {
            message = '${first['msg']}（参数校验失败）';
            break;
          }
        }
      }

      final rawDetails = map['details'];
      if (rawDetails is Map) {
        details = Map<String, dynamic>.from(rawDetails);
      } else {
        // V1.1 用 `details`，FastAPI 原生用 `detail`。两者语义相同，
        // 统一挂到 `errors` 下，调用方只需要读一个键。
        final rawDetail = map['detail'];
        if (rawDetail is List) {
          details = {'errors': rawDetail};
        } else if (rawDetail is Map) {
          details = Map<String, dynamic>.from(rawDetail);
        }
      }
      // 兜底：`message` 已被上面取走的情况不会走到这里，
      // 但若 errors 里的元素没有 `msg`（或结构变化），仍给出可读信息。
      if (message == '参数校验失败') {
        final errors = details?['errors'];
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is Map && first['msg'] != null) {
            message = '${first['msg']}（参数校验失败）';
          }
        }
      }
    } else if (decodedBody is String && decodedBody.trim().isNotEmpty) {
      message = decodedBody;
    }

    return ApiException(
      message,
      statusCode: statusCode,
      code: code,
      details: details,
    );
  }

  String _defaultMessageFor(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数有误';
      case 401:
        return '登录状态已失效，请重新登录';
      case 403:
        return '没有权限执行该操作';
      case 404:
        return '请求的资源不存在';
      case 409:
        return '数据冲突，请稍后重试';
      case 422:
        return '参数校验失败';
      case 429:
        return '操作过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误';
      case 502:
      case 503:
        return '服务暂时不可用，请稍后重试';
      default:
        return '服务器请求失败（HTTP $statusCode）';
    }
  }

  // -------------------------------------------------------------------------
  // 响应体工具
  // -------------------------------------------------------------------------

  /// 取出统一响应外壳里的 `data`。
  ///
  /// 成功体：[V1.1 §6] `{code: 200, message: "success", data: {...}}`。
  /// 若后端某个接口直接返回裸对象（V1.0 Account 契约就是这样），
  /// 这里原样返回 —— 让前端在契约未收口期间不至于直接崩。
  static dynamic unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// [unwrap] 的 Map 版本；`data` 为 null 或不是对象时返回空 Map。
  static Map<String, dynamic> unwrapMap(dynamic body) {
    final data = unwrap(body);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return const <String, dynamic>{};
  }

  void dispose() {
    _client.close();
  }
}
