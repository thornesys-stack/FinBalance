import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _androidBaseUrl = 'http://10.0.2.2:8000';
  static const String _desktopBaseUrl = 'http://127.0.0.1:8000';

  static String get baseUrl {
    if (kIsWeb) return _desktopBaseUrl;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidBaseUrl;
      default:
        return _desktopBaseUrl;
    }
  }

  static const String apiPrefix = '/api/v1';
}
