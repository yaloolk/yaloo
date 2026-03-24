import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:yaloo/core/storage/secure_storage.dart';
import 'package:yaloo/core/config/env_config.dart';


class ApiClient {
  // ── 1. Singleton Setup ──
  // Private static instance
  static final ApiClient _instance = ApiClient._internal();

  // Factory constructor returns the same instance every time
  factory ApiClient() {
    return _instance;
  }

  late final Dio _dio;
  final SecureStorage _secureStorage = SecureStorage();

  // ── 2. Private Internal Constructor ──
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        // Automatically fetch URL from your EnvConfig
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── 3. Interceptors (Auth & Logging) ──
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage
          final token = await _secureStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            // This adds 'Bearer token' to EVERY request automatically
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint('🔵 REQUEST: ${options.method} ${options.path}');
            debugPrint('🔵 HEADERS: ${options.headers}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
            debugPrint('❌ ERROR MESSAGE: ${error.message}');
            debugPrint('❌ ERROR DATA: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ── 4. Standardized Methods ──

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      debugPrint('🌐 Making GET request to: ${_dio.options.baseUrl}$path');
      final response = await _dio.get(path, queryParameters: queryParameters);
      debugPrint('✅ Response received: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}');
      debugPrint('❌ Status Code: ${e.response?.statusCode}');
      debugPrint('❌ Response Data: ${e.response?.data}');
      debugPrint('❌ Request URL: ${e.requestOptions.uri}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unknown error: $e');
      rethrow;
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      // Note: We removed the manual Auth check here because the
      // interceptor (onRequest) handles it automatically for Multipart too!
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }


}