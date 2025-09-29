import 'package:dio/dio.dart';
import 'api_client.dart' show determineBaseUrl;
import 'http_adapter_stub.dart' if (dart.library.io) 'http_adapter_io.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    final String baseUrl = determineBaseUrl();
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
      },
    ));

    // Align adapter behavior with ApiClient
    configureDioAdapter(dio);

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.delete<T>(path, queryParameters: queryParameters);
  }
}
