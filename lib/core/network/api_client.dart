// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:yaloo/core/storage/secure_storage.dart';

class ApiClient {
  final String baseUrl;
  late final Dio _dio;
  final SecureStorage _secureStorage = SecureStorage();

  ApiClient({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor to attach auth token to all requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage
          final token = await _secureStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            // Add Bearer token to headers
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('🔵 REQUEST: ${options.method} ${options.path}');
          print('🔵 HEADERS: ${options.headers}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('❌ ERROR MESSAGE: ${error.message}');
          print('❌ ERROR DATA: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      // For multipart requests, ensure Content-Type is set correctly
      if (options?.headers?['Content-Type'] == 'multipart/form-data') {
        // Get the auth token
        final token = await _secureStorage.getAccessToken();

        // Merge headers - keep multipart content type but add auth
        options = Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            ...?options?.headers,
          },
        );
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}