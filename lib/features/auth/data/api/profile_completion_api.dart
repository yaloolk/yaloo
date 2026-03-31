// lib/features/auth/data/api/profile_completion_api.dart

import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:yaloo/core/storage/secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ProfileCompletionApi {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  ProfileCompletionApi({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  // ==================== TOURIST PROFILE ====================

  Future<Map<String, dynamic>> completeTouristProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    required String country,
    String? bio,
    String? passportNumber,
    String? travelStyle,
    String? preferredLanguageId,
    List<String>? interestIds,
  }) async {
    try {
      final response = await _apiClient.post(
        '/accounts/profile/complete/tourist/',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'country': country,
          'bio': bio,
          'passport_number': passportNumber,
          'travel_style': travelStyle,
          'preferred_language': preferredLanguageId,
          'interest_ids': interestIds ?? [],
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> skipProfileCompletion() async {
    try {
      final response = await _apiClient.post('/accounts/profile/skip/');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GUIDE PROFILE ====================

  Future<Map<String, dynamic>> completeGuideProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    required String country,
    required String cityId,
    int? experienceYears,
    String? education,
    double? ratePerHour,
    List<String>? languageIds,
    required XFile governmentId,
    required XFile profilePhoto,
    XFile? license,
  }) async {
    try {
      // Create form data for multipart upload
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'country': country,
        'city_id': cityId,
        'experience_years': experienceYears,
        'education': education ?? '',
        'rate_per_hour': ratePerHour ?? 0.0,

        // Add language IDs as array
        if (languageIds != null)
          for (int i = 0; i < languageIds.length; i++)
            'language_ids[$i]': languageIds[i],

        // Upload files - works for both web and mobile
        'government_id': await _createMultipartFile(governmentId),
        'profile_photo': await _createMultipartFile(profilePhoto),

        // Optional license
        if (license != null)
          'license': await _createMultipartFile(license),
      });

      final response = await _apiClient.post(
        '/accounts/profile/complete/guide/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== HOST PROFILE ====================

  Future<Map<String, dynamic>> completeHostProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required XFile profilePhoto,
    required XFile governmentId,
    XFile? otherDoc,
  }) async {
    try {
      // ── build multipart FormData ──
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'gender': gender,

        // ── files (Using the helper method for Web/Mobile compatibility) ──
        'profile_photo': await _createMultipartFile(profilePhoto),
        'government_id': await _createMultipartFile(governmentId),

        // ── optional document ──
        if (otherDoc != null)
          'other_doc': await _createMultipartFile(otherDoc),
      });

      // ── POST ──
      // Use _apiClient (with underscore) and the correct Django endpoint
      final response = await _apiClient.post(
        '/accounts/profile/complete/host/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            // Auth token is added automatically by _apiClient interceptor
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== VERIFICATION STATUS ====================

  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final response = await _apiClient.get('/accounts/verification/status/');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== HELPER ENDPOINTS ====================

  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await _apiClient.get('/accounts/languages/');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final response = await _apiClient.get('/accounts/cities/');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getInterests() async {
    try {
      final response = await _apiClient.get('/accounts/interests/');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Creates a MultipartFile that works on both web and mobile
  Future<MultipartFile> _createMultipartFile(XFile file) async {
    if (kIsWeb) {
      // Web implementation
      final bytes = await file.readAsBytes();
      return MultipartFile.fromBytes(
        bytes,
        filename: file.name,
        contentType: MediaType('image', _getFileExtension(file.name)),
      );
    } else {
      // Mobile implementation
      return MultipartFile.fromFile(
        file.path,
        filename: file.name,
        contentType: MediaType('image', _getFileExtension(file.name)),
      );
    }
  }

  String _getFileExtension(String path) {
    final extension = path.split('.').last.toLowerCase();
    // Map common extensions to MIME types
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'pdf':
        return 'pdf';
      default:
        return 'jpeg'; // Default fallback
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data.containsKey('error')) {
          return Exception(data['error']);
        }
        return Exception('Server error: ${error.response?.statusCode}');
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('Unexpected error: $error');
  }
}