import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'http_adapter_stub.dart' if (dart.library.io) 'http_adapter_io.dart';

String determineBaseUrl() {
  // Web/desktop typically can reach 127.0.0.1
  // Android emulator maps host machine to 10.0.2.2
  if (kIsWeb) return 'http://127.0.0.1:9999';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:9999';
    default:
      return 'http://127.0.0.1:9999';
  }
}

class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? determineBaseUrl(),
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 10),
            headers: const {'content-type': 'application/json'},
          ),
        ) {
    // Ensure direct connection; avoid system proxy interference on local dev.
    configureDioAdapter(_dio);
  }

  Future<Map<String, dynamic>> health() async {
    final res = await _dio.get('/health');
    if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
    return {'raw': res.data};
  }
}

class AppServices {
  AppServices._() : api = ApiClient();
  static final AppServices I = AppServices._();
  final ApiClient api;
}
