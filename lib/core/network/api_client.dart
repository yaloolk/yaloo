// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/config/env_config.dart';

class ApiClient {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  // ── Constructor ───────────────────────────────────────────────────────────
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        // ── onRequest: attach the FRESH Supabase token ──────────────────────
        onRequest: (options, handler) async {
          final token = await _getFreshToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('🔵 REQUEST: ${options.method} ${options.path}');
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
                '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },

        // ── onError: on 401, refresh session once and retry ─────────────────
        onError: (error, handler) async {
          if (kDebugMode) {
            debugPrint(
                '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
            debugPrint('❌ ERROR MESSAGE: ${error.message}');
            debugPrint('❌ ERROR DATA: ${error.response?.data}');
          }

          // On 401 → try refreshing the Supabase session once, then retry
          if (error.response?.statusCode == 401) {
            final retried = await _retryAfterRefresh(error.requestOptions);
            if (retried != null) {
              return handler.resolve(retried);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  // ── CORE FIX: Always get the fresh token from Supabase ────────────────────
  //
  // Supabase SDK keeps the session alive and auto-refreshes the JWT.
  // currentSession?.accessToken is ALWAYS the latest valid token.
  // SecureStorage is NOT used here — it can hold a stale token.
  Future<String?> _getFreshToken() async {
    try {
      // First try the live in-memory session
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
        return session.accessToken;
      }

      // No in-memory session → try refreshing
      final refreshed =
      await Supabase.instance.client.auth.refreshSession();
      return refreshed.session?.accessToken;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️  Could not retrieve Supabase token: $e');
      }
      return null;
    }
  }

  // ── Retry helper: refresh session then resend the failed request ──────────
  Future<Response?> _retryAfterRefresh(RequestOptions failed) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 401 received — refreshing Supabase session…');
      }
      final result =
      await Supabase.instance.client.auth.refreshSession();
      final newToken = result.session?.accessToken;
      if (newToken == null) return null;

      // Rebuild the original request with the new token
      final opts = Options(
        method: failed.method,
        headers: {
          ...failed.headers,
          'Authorization': 'Bearer $newToken',
        },
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      );
      final response = await _dio.request<dynamic>(
        failed.path,
        data: failed.data,
        queryParameters: failed.queryParameters,
        options: opts,
      );
      if (kDebugMode) {
        debugPrint('✅ Retry after refresh succeeded: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Retry after refresh failed: $e');
      }
      return null;
    }
  }

  // ── Public HTTP methods ───────────────────────────────────────────────────

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      debugPrint('🌐 GET: ${_dio.options.baseUrl}$path');
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      debugPrint('❌ DioException GET $path: ${e.type} ${e.response?.statusCode}');
      debugPrint('❌ Response: ${e.response?.data}');
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