// lib/core/services/host_api_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:yaloo/core/storage/secure_storage.dart';

class HostApiService {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:8000/api';

  HostApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage().getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<T> _handleRequest<T>(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        String error;
        if (data is Map) {
          error = data['error']?.toString() ?? data['detail']?.toString() ?? 'Unknown error';
        } else {
          error = 'Server error: ${e.response!.statusCode}';
        }
        throw Exception(error);
      }
      throw Exception(e.message ?? 'Network error');
    }
  }

  // ══════════════════════════════════════════════════════════
  // HOST PROFILE
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getHostProfile() async {
    return _handleRequest(() => _dio.get('/accounts/host/profile/'));
  }

  Future<Map<String, dynamic>> updateHostProfile(Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.patch('/accounts/host/profile/update/', data: data));
  }

  Future<Map<String, dynamic>> updateProfilePicture(XFile photo) async {
    FormData formData;

    if (kIsWeb) {
      final bytes = await photo.readAsBytes();
      formData = FormData.fromMap({
        'profile_pic': MultipartFile.fromBytes(bytes, filename: photo.name),
      });
    } else {
      formData = FormData.fromMap({
        'profile_pic': await MultipartFile.fromFile(photo.path, filename: photo.name),
      });
    }

    return _handleRequest(() => _dio.post('/accounts/profile/picture/', data: formData));
  }

  // ══════════════════════════════════════════════════════════
  // DASHBOARD
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getHostDashboard() async {
    return _handleRequest(() => _dio.get('/accounts/host/dashboard/'));
  }

  // ══════════════════════════════════════════════════════════
  // STAYS MANAGEMENT
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> createStay({
    required Map<String, dynamic> stayData,
    List<XFile>? photos,
    List<XFile>? documents,
    List<String>? facilityIds,
  }) async {
    final formData = FormData.fromMap({
      ...stayData,
      if (facilityIds != null) 'facility_ids[]': facilityIds,
    });

    if (photos != null) {
      for (var photo in photos) {
        if (kIsWeb) {
          final bytes = await photo.readAsBytes();
          formData.files.add(MapEntry(
            'photos[]',
            MultipartFile.fromBytes(bytes, filename: photo.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'photos[]',
            await MultipartFile.fromFile(photo.path, filename: photo.name),
          ));
        }
      }
    }

    if (documents != null) {
      for (var doc in documents) {
        if (kIsWeb) {
          final bytes = await doc.readAsBytes();
          formData.files.add(MapEntry(
            'documents[]',
            MultipartFile.fromBytes(bytes, filename: doc.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'documents[]',
            await MultipartFile.fromFile(doc.path, filename: doc.name),
          ));
        }
      }
    }

    return _handleRequest(() => _dio.post('/accounts/stays/create/', data: formData));
  }

  Future<List<dynamic>> getHostStays() async {
    return _handleRequest(() => _dio.get('/accounts/host/stays/'));
  }

  Future<Map<String, dynamic>> getStayDetail(String stayId) async {
    return _handleRequest(() => _dio.get('/accounts/host/stays/$stayId/'));
  }

  Future<Map<String, dynamic>> updateStay(String stayId, Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.patch('/accounts/host/stays/$stayId/update/', data: data));
  }

  Future<Map<String, dynamic>> toggleStayActive(String stayId) async {
    return _handleRequest(() => _dio.post('/accounts/host/stays/$stayId/toggle/'));
  }

  Future<Map<String, dynamic>> deleteStay(String stayId) async {
    return _handleRequest(() => _dio.delete('/accounts/host/stays/$stayId/delete/'));
  }

  // ══════════════════════════════════════════════════════════
  // STAY PHOTOS
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> addStayPhotos(String stayId, List<XFile> photos) async {
    final formData = FormData();

    for (var photo in photos) {
      if (kIsWeb) {
        final bytes = await photo.readAsBytes();
        formData.files.add(MapEntry(
          'photos[]',
          MultipartFile.fromBytes(bytes, filename: photo.name),
        ));
      } else {
        formData.files.add(MapEntry(
          'photos[]',
          await MultipartFile.fromFile(photo.path, filename: photo.name),
        ));
      }
    }

    return _handleRequest(() => _dio.post('/accounts/host/stays/$stayId/photos/add/', data: formData));
  }

  Future<Map<String, dynamic>> deleteStayPhoto(String stayId, String photoId) async {
    return _handleRequest(() => _dio.delete('/accounts/host/stays/$stayId/photos/$photoId/'));
  }

  Future<Map<String, dynamic>> setCoverPhoto(String stayId, String photoId) async {
    return _handleRequest(() => _dio.post('/accounts/host/stays/$stayId/photos/$photoId/set-cover/'));
  }

  // ══════════════════════════════════════════════════════════
  // FACILITIES
  // ══════════════════════════════════════════════════════════

  Future<List<dynamic>> getAllFacilities() async {
    return _handleRequest(() => _dio.get('/accounts/facilities/'));
  }

  Future<Map<String, dynamic>> updateStayFacilities(
      String stayId, List<String> facilityIds) async {
    return _handleRequest(() => _dio.post(
      '/accounts/host/stays/$stayId/facilities/',
      data: {'facility_ids': facilityIds},
    ));
  }

  // ══════════════════════════════════════════════════════════
  // AVAILABILITY
  // ══════════════════════════════════════════════════════════

  Future<List<dynamic>> getStayAvailability(String stayId) async {
    return _handleRequest(() => _dio.get('/accounts/host/stays/$stayId/availability/'));
  }

  Future<Map<String, dynamic>> setStayAvailability(
      String stayId, Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.post(
      '/accounts/host/stays/$stayId/availability/set/',
      data: data,
    ));
  }

  Future<Map<String, dynamic>> updateSingleAvailability(
      String stayId, String availId, Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.patch(
      '/accounts/host/stays/$stayId/availability/$availId/',
      data: data,
    ));
  }

  Future<Map<String, dynamic>> deleteAvailability(String stayId, String availId) async {
    return _handleRequest(() => _dio.delete('/accounts/host/stays/$stayId/availability/$availId/delete/'));
  }

  // ══════════════════════════════════════════════════════════
  // LANGUAGES
  // ══════════════════════════════════════════════════════════

  Future<List<dynamic>> getAllLanguages() async {
    return _handleRequest(() => _dio.get('/accounts/languages/'));
  }

  Future<Map<String, dynamic>> addHostLanguage(String languageId, String proficiency) async {
    return _handleRequest(() => _dio.post(
      '/accounts/host/languages/add/',
      data: {'language_id': languageId, 'proficiency': proficiency},
    ));
  }

  Future<Map<String, dynamic>> updateHostLanguage(String languageId, String proficiency) async {
    return _handleRequest(() => _dio.patch(
      '/accounts/host/languages/$languageId/update/',
      data: {'proficiency': proficiency},
    ));
  }

  Future<Map<String, dynamic>> removeHostLanguage(String languageId) async {
    return _handleRequest(() => _dio.delete('/accounts/host/languages/$languageId/delete/'));
  }

  // ══════════════════════════════════════════════════════════
  // MASTER DATA
  // ══════════════════════════════════════════════════════════

  Future<List<dynamic>> getAllCities() async {
    return _handleRequest(() => _dio.get('/accounts/cities/'));
  }

  // ══════════════════════════════════════════════════════════
  // REVIEWS
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getHostReviews() async {
    return _handleRequest(() => _dio.get('/accounts/host/reviews/'));
  }
}