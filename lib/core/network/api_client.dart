import 'package:dio/dio.dart';
import 'package:roomly/core/constants/api_constants.dart';
import 'package:roomly/core/utils/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  static Dio? _legacyDio;

  // For legacy code that expects ApiClient.instance to be a Dio
  static Dio get instance {
    _legacyDio ??= Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseApiUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    return _legacyDio!;
  }

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseApiUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await SecureStorageService.getAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        // Handle 401 - Token expired
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshToken = await SecureStorageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await _dio.post('/auth/refresh-token',
                data: {'refresh_token': refreshToken},
              );
              final newToken = response.data['token'] ?? response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];

              if (newToken != null) {
                await SecureStorageService.saveAuthToken(newToken);
              }
              if (newRefreshToken != null) {
                await SecureStorageService.saveRefreshToken(newRefreshToken);
              }

              // Retry original request
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await _dio.fetch(
                  RequestOptions(
                    path: error.requestOptions.path,
                    method: error.requestOptions.method,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  ),
                );
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              // Refresh failed, clear tokens
              await SecureStorageService.clearAll();
            }
          }
        }

        final errorMessage = _handleError(error);
        return handler.reject(DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: errorMessage,
        ));
      },
    ));
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            return 'Bad request. Please check your input.';
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Access denied.';
          case 404:
            return 'Resource not found.';
          case 422:
            return 'Validation error. Please check your input.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'Something went wrong. Please try again.';
        }
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet.';
      case DioExceptionType.unknown:
      default:
        return 'Unknown error occurred.';
    }
  }

  Dio get dio => _dio;

  // Legacy single token setter
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // New contract expected by auth_repository_impl.dart (plural)
  Future<void> setAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await SecureStorageService.saveAuthToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await SecureStorageService.saveRefreshToken(refreshToken);
    }
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  Future<void> clearAuthTokens() async {
    await SecureStorageService.clearAll();
    _dio.options.headers.remove('Authorization');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final file = await MultipartFile.fromFile(filePath);
    final formData = FormData.fromMap({
      ...?data,
      'file': file,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }

  Future<Response> uploadImages(
    String path,
    List<String> filePaths, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final files = await Future.wait(
      filePaths.map((path) => MultipartFile.fromFile(path)),
    );

    final formData = FormData.fromMap({
      ...?data,
      'images': files,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }
}
