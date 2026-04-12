// lib/core/services/api_service.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../config/env_config.dart';

class DjangoApiService {
  final ApiClient _apiClient = ApiClient();

  // Use EnvConfig for base URL
  static String get baseUrl => EnvConfig.apiBaseUrl;

  Future<String?> _getAuthToken() async {
    try {
      // Get token from SecureStorage
      final token = await SecureStorage().getAccessToken();

      if (token != null) {
        if (kDebugMode) {
          debugPrint('✅ Got auth token: ${token.substring(0, 20)}...');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ No auth token found in SecureStorage');
        }
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting auth token: $e');
      }
      return null;
    }
  }

  /// Test connection to Django server (no auth required)
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Testing Django server connection at: $baseUrl/accounts/health/');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/accounts/health/'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (kDebugMode) {
        debugPrint('📡 Health check response: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Connection test failed: $e');
      }
      return false;
    }
  }

  /// Generic GET request (returns Map)
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getAuthToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = '$baseUrl/$endpoint';
    if (kDebugMode) {
      debugPrint('🌐 GET Request: $url');
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('📡 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        if (kDebugMode) {
          debugPrint('❌ Error: ${response.body}');
        }
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network Error: $e');
      }
      rethrow;
    }
  }

  /// Generic GET request that returns a List
  Future<List<Map<String, dynamic>>> getList(String endpoint) async {
    final token = await _getAuthToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = '$baseUrl/$endpoint';
    if (kDebugMode) {
      debugPrint('🌐 GET Request (List): $url');
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('📡 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        if (kDebugMode) {
          debugPrint('❌ Error: ${response.body}');
        }
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network Error: $e');
      }
      rethrow;
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getAuthToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = '$baseUrl/$endpoint';
    if (kDebugMode) {
      debugPrint('🌐 POST Request: $url');
      debugPrint('📦 Data: ${json.encode(data)}');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('📡 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        if (kDebugMode) {
          debugPrint('❌ Error: ${response.body}');
        }
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network Error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // SPECIFIC API ENDPOINTS - ALL UPDATED WITH /accounts/ PREFIX
  // ============================================================================

  /// Get all available interests (public endpoint, no auth required)
  Future<List<Map<String, dynamic>>> getAllInterests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/accounts/interests/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load interests');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting all interests: $e');
      }
      rethrow;
    }
  }

  /// Get user's selected interests
  Future<List<Map<String, dynamic>>> getUserInterests() async {
    return await getList('accounts/interests/user/');
  }

  /// Add user interests
  Future<List<Map<String, dynamic>>> addUserInterests(List<String> interestIds) async {
    final token = await _getAuthToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = '$baseUrl/accounts/interests/user/add/';
    if (kDebugMode) {
      debugPrint('🌐 POST Request: $url');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'interest_ids': interestIds}),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('📡 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        if (kDebugMode) {
          debugPrint('❌ Error: ${response.body}');
        }
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Network Error: $e');
      }
      rethrow;
    }
  }

  /// Get all languages
  Future<List<Map<String, dynamic>>> getLanguages() async {
    return await getList('accounts/languages/');
  }

  /// Get all cities
  Future<List<Map<String, dynamic>>> getCities() async {
    return await getList('accounts/cities/');
  }

  /// Test authentication with Django
  Future<Map<String, dynamic>> testAuth() async {
    return await get('accounts/test-auth/');
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('accounts/me/');
  }

  /// Complete tourist profile
  Future<Map<String, dynamic>> completeTouristProfile(Map<String, dynamic> data) async {
    return await post('accounts/profile/complete/tourist/', data);
  }

  /// Complete guide profile
  Future<Map<String, dynamic>> completeGuideProfile(Map<String, dynamic> data) async {
    return await post('accounts/profile/complete/guide/', data);
  }

  /// Complete host profile
  Future<Map<String, dynamic>> completeHostProfile(Map<String, dynamic> data) async {
    return await post('accounts/profile/complete/host/', data);
  }

  /// Skip profile completion (tourist only)
  Future<Map<String, dynamic>> skipProfileCompletion() async {
    return await post('accounts/profile/skip/', {});
  }

  /// Get verification status for guide/host
  Future<Map<String, dynamic>> getVerificationStatus() async {
    return await get('accounts/verification/status/');
  }

  /// Create a new stay (for hosts)
  Future<Map<String, dynamic>> createStay(
      Map<String, dynamic> fields,
      List<XFile> photos,
      XFile? sltdaDoc,
      ) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    var uri = Uri.parse('$baseUrl/accounts/host/stays/create/');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // 1. Add Fields
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // 2. Add SLTDA Document
    if (sltdaDoc != null) {
      // kIsWeb uses bytes, Mobile uses path
      if (kIsWeb) {
        var bytes = await sltdaDoc.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'sltda_document',
          bytes,
          filename: sltdaDoc.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'sltda_document',
          sltdaDoc.path,
        ));
      }
    }

    // 3. Add Photos
    for (var photo in photos) {
      if (kIsWeb) {
        var bytes = await photo.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'photos',
          bytes,
          filename: photo.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'photos',
          photo.path,
        ));
      }
    }

    // 4. Send
    if (kDebugMode) {
      debugPrint('🌐 Creating stay with ${photos.length} photos');
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (kDebugMode) {
      debugPrint('📡 Create Stay Response Status: ${response.statusCode}');
    }

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      if (kDebugMode) {
        debugPrint('❌ Error creating stay: ${response.body}');
      }
      throw Exception('Failed to create stay: ${response.body}');
    }
  }

  // ============================================================================
  // FUTURE ENDPOINTS (Add as needed)
  // ============================================================================

  /// Get list of stays (for browse/search)
  Future<List<Map<String, dynamic>>> getStays({
    String? city,
    int? minPrice,
    int? maxPrice,
  }) async {
    var endpoint = 'accounts/stays/';
    final queryParams = <String>[];

    if (city != null) queryParams.add('city=$city');
    if (minPrice != null) queryParams.add('min_price=$minPrice');
    if (maxPrice != null) queryParams.add('max_price=$maxPrice');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    return await getList(endpoint);
  }

  /// Get list of guides (for browse/search)
  Future<List<Map<String, dynamic>>> getGuides({
    String? city,
    List<String>? languages,
  }) async {
    var endpoint = 'accounts/guides/';
    final queryParams = <String>[];

    if (city != null) queryParams.add('city=$city');
    if (languages != null && languages.isNotEmpty) {
      queryParams.add('languages=${languages.join(',')}');
    }

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    return await getList(endpoint);
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await post('accounts/me/update/', data);
  }

  /// Update profile bio
  Future<Map<String, dynamic>> updateProfileBio(String bio) async {
    return await post('accounts/me/update/', {'profile_bio': bio});
  }

  /// Force server to invalidate Redis cache for current user
  Future<void> invalidateCache() async {
    try {
      // Hit the endpoint with a cache-bust header
      final token = await _getAuthToken();
      if (token == null) return;

      await http.get(
        Uri.parse('$baseUrl/accounts/me/').replace(
            queryParameters: {'nocache': DateTime.now().millisecondsSinceEpoch.toString()}
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache',
          'X-No-Cache': 'true',
        },
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

}