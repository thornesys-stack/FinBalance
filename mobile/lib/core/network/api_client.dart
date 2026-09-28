import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters,
    );

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    final response = await _client.post(
      uri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        statusCode: response.statusCode,
        message: '服务器返回了无法解析的数据。',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? (decoded['detail'] ?? decoded['message'] ?? decoded['error'])
          : null;

      throw ApiException(
        statusCode: response.statusCode,
        message: message?.toString() ?? '请求失败。',
        details: decoded,
      );
    }

    if (decoded is Map<String, dynamic>) return decoded;

    throw ApiException(
      statusCode: response.statusCode,
      message: '服务器返回的数据结构不是 JSON 对象。',
      details: decoded,
    );
  }

  void dispose() => _client.close();
}
