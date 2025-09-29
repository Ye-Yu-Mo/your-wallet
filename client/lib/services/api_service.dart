import 'package:dio/dio.dart';
import 'api_client.dart' show determineBaseUrl;
import 'http_adapter_stub.dart' if (dart.library.io) 'http_adapter_io.dart';

class ApiService {
  late Dio dio;
  String? _accessToken;
  String? _refreshToken;
  Future<void>? _refreshing;
  void Function(String access, String? refresh)? onTokenUpdate;
  void Function()? onAuthFailure;

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

    // Logging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // Auth attach + refresh
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final skip = options.extra['skipAuth'] == true;
        if (!skip && _accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        final isAuthPath = path.contains('/api/auth/login') || path.contains('/api/auth/refresh');
        final alreadyRetried = error.requestOptions.extra['retried'] == true;

        if (status == 401 && !isAuthPath && !alreadyRetried) {
          try {
            await _performRefresh();
            final req = error.requestOptions;
            req.extra['retried'] = true;
            // Authorization header will be reattached in onRequest
            final response = await dio.fetch(req);
            return handler.resolve(response);
          } catch (_) {
            // Refresh failed; fall through to original error
            if (onAuthFailure != null) {
              onAuthFailure!();
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  void setAuthToken(String token) {
    _accessToken = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _accessToken = null;
    dio.options.headers.remove('Authorization');
  }

  void setRefreshToken(String token) {
    _refreshToken = token;
  }

  void clearRefreshToken() {
    _refreshToken = null;
  }

  Future<void> _performRefresh() async {
    if (_refreshing != null) {
      return _refreshing!;
    }
    _refreshing = _refreshAccessToken();
    try {
      await _refreshing;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> _refreshAccessToken() async {
    final token = _refreshToken;
    if (token == null || token.isEmpty) {
      throw Exception('No refresh token');
    }
    final res = await dio.post(
      '/api/auth/refresh',
      data: {'refresh_token': token},
      options: Options(extra: {'skipAuth': true}),
    );
    final data = res.data is Map ? res.data as Map : <String, dynamic>{};
    final newAccess = data['token'] as String?;
    final newRefresh = data['refresh_token'] as String?;
    if (newAccess == null || newAccess.isEmpty) {
      throw Exception('Invalid refresh response');
    }
    setAuthToken(newAccess);
    if (newRefresh != null && newRefresh.isNotEmpty) {
      setRefreshToken(newRefresh);
    }
    // Notify listeners (e.g., AuthProvider) to persist
    if (onTokenUpdate != null) {
      onTokenUpdate!(newAccess, newRefresh);
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.delete<T>(path, queryParameters: queryParameters, options: options);
  }
}
