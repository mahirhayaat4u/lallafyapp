import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';

/// Dio HTTP Client — Singleton
///
/// 💡 React Native / Web equivalent: This is exactly like your Axios `client`
/// from frontend/src/api/client.ts — with the same interceptor pattern for
/// automatic token refresh on 401 responses.
///
/// Key difference from web:
/// - Web uses httpOnly cookies (browser handles them automatically)
/// - Mobile uses Bearer tokens stored in flutter_secure_storage
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Track if a refresh is already in-flight (mirrors isRefreshing in client.ts)
  bool _isRefreshing = false;
  final List<({Completer<void> completer})> _failedQueue = [];

  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Request Interceptor: Attach Bearer token ──
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // ── Response Interceptor: Auto-refresh on 401 ──
          // Mirrors the Axios interceptor logic from client.ts
          if (error.response?.statusCode == 401 &&
              !_isLoginOrRefreshRoute(error.requestOptions.path) &&
              error.requestOptions.extra['_retry'] != true) {
            try {
              await _handleTokenRefresh(error.requestOptions);
              // Retry the original request with new token
              final retryResponse = await _dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (e) {
              // Refresh failed — clear tokens, user must re-login
              await clearTokens();
              return handler.reject(error);
            }
          }

          // Parse error response for readable messages
          final apiException = _parseError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );

    // Debug logging in development (minimal — no full body dumps)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// Singleton accessor
  factory DioClient() {
    _instance ??= DioClient._();
    return _instance!;
  }

  /// The raw Dio instance (for advanced use)
  Dio get dio => _dio;

  // ─── HTTP Methods ──────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return _dio.patch<T>(path, data: data, options: options);
  }

  // ─── Token Management ─────────────────────────────────────

  /// Save tokens after login/register
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(
        key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  /// Check if user has stored tokens
  Future<bool> hasTokens() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return token != null;
  }

  // ─── Private Helpers ──────────────────────────────────────

  bool _isLoginOrRefreshRoute(String path) {
    return path.contains('/auth/login') || path.contains('/auth/refresh');
  }

  /// Handle token refresh — queues concurrent requests (mirrors client.ts logic)
  Future<void> _handleTokenRefresh(RequestOptions originalRequest) async {
    if (_isRefreshing) {
      // Another refresh is in-flight — wait for it
      final completer = Completer<void>();
      _failedQueue.add((completer: completer));
      return completer.future;
    }

    _isRefreshing = true;
    originalRequest.extra['_retry'] = true;

    try {
      final refreshToken =
          await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) throw Exception('No refresh token');

      // Call refresh endpoint with refresh token in body
      final response = await Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      )).post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final tokens = response.data['data']['tokens'];
      await saveTokens(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );

      // Update the original request's auth header
      originalRequest.headers['Authorization'] =
          'Bearer ${tokens['accessToken']}';

      // Resolve all queued requests
      for (final item in _failedQueue) {
        item.completer.complete();
      }
    } catch (e) {
      // Reject all queued requests
      for (final item in _failedQueue) {
        item.completer.completeError(e);
      }
      rethrow;
    } finally {
      _isRefreshing = false;
      _failedQueue.clear();
    }
  }

  /// Parse Dio error into readable ApiException
  /// Mirrors the error parsing in the web Axios interceptor
  ApiException _parseError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'Connection timed out. Please try again.',
        statusCode: null,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'No internet connection. Please check your network.',
        statusCode: null,
      );
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      String msg = data['message'] ?? 'Something went wrong';

      // Extract detailed validation errors (mirrors web interceptor logic)
      List<ValidationError>? validationErrors;
      if (data['errors'] is List) {
        validationErrors = (data['errors'] as List)
            .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
            .toList();
        if (validationErrors.isNotEmpty) {
          msg = validationErrors.map((e) => e.message).join(', ');
        }
      }

      return ApiException(
        message: msg,
        statusCode: error.response?.statusCode,
        errors: validationErrors,
      );
    }

    return ApiException(
      message: 'Something went wrong',
      statusCode: error.response?.statusCode,
    );
  }
}
