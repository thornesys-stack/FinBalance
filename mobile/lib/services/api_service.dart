import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiService {
  // 基础请求头
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  // 首页
  /// 获取首页财务概览
  Future<Map<String, dynamic>> getHomeOverview() async {
    return get('/api/v1/home/overview');
  }
  // GET 请求
  Future<Map<String, dynamic>> get(
    String endpoint,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$endpoint',
    );

    final response = await http.get(
      uri,
      headers: _headers,
    );

    return _handleResponse(response);
  }
  // POST 请求
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$endpoint',
    );

    final response = await http.post(
      uri,
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }
  // PUT 请求
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$endpoint',
    );

    final response = await http.put(
      uri,
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }
  // DELETE 请求
  Future<Map<String, dynamic>> delete(
    String endpoint,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$endpoint',
    );

    final response = await http.delete(
      uri,
      headers: _headers,
    );

    return _handleResponse(response);
  }
  // 统一处理服务器响应
  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return {
          'code': response.statusCode,
          'message': 'success',
          'data': null,
        };
      }

      throw Exception(
        '服务器请求失败：${response.statusCode}',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        '服务器返回的数据不是有效的 JSON',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'code': response.statusCode,
        'message': 'success',
        'data': decoded,
      };
    }

    String message = '请求失败';

    if (decoded is Map<String, dynamic>) {
      final serverMessage = decoded['message'];

      if (serverMessage != null) {
        message = serverMessage.toString();
      }
    }

    throw Exception(
      '$message（HTTP ${response.statusCode}）',
    );
  }
}