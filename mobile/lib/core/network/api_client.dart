import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(
      path,
      queryParameters: queryParameters,
    );

    final response = await _client.get(
      uri,
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path);

    final response = await _client.post(
      uri,
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path);

    final response = await _client.put(
      uri,
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(
    String path,
  ) async {
    final uri = _buildUri(path);

    final response = await _client.delete(
      uri,
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri.parse(
      'http://127.0.0.1:8000$path',
    );

    if (queryParameters == null ||
        queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: queryParameters,
    );
  }

  Map<String, String> get _headers {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  dynamic _handleResponse(
    http.Response response,
  ) {
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

    String message = '服务器请求失败';

    if (decodedBody is Map<String, dynamic>) {
      final detail = decodedBody['detail'];

      if (detail is String) {
        message = detail;
      }
    }

    throw ApiException(
      message,
      statusCode: statusCode,
    );
  }

  void dispose() {
    _client.close();
  }
}