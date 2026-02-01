// lib/core/services/api_service.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class DjangoApiService {
  static const String baseUrl = 'http://192.168.10.23:8000/api';

  /// Get current Supabase auth token
  Future<String?> _getAuthToken() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken;

      if (token != null) {
        print('✅ Got auth token: ${token.substring(0, 20)}...');
      } else {
        print('❌ No auth token found');
      }

      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  /// Test connection to Django server (no auth required)
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing Django server connection at: $baseUrl/accounts/health/');

      final response = await http.get(
        Uri.parse('$baseUrl/accounts/health/'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('📡 Health check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
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
    print('🌐 GET Request: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        print('❌ Error: ${response.body}');
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
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
    print('🌐 GET Request (List): $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        print('❌ Error: ${response.body}');
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
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
    print('🌐 POST Request: $url');
    print('📦 Data: ${json.encode(data)}');

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

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        print('❌ Error: ${response.body}');
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
      rethrow;
    }
  }

  /// Get all available interests
  Future<List<Map<String, dynamic>>> getAllInterests() async {
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
    print('🌐 POST Request: $url');

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

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Error: ${response.body}');
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
      rethrow;
    }
  }



  Future<List<Map<String, dynamic>>> getLanguages() async {
    return await getList('accounts/languages/');
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


  Future<Map<String, dynamic>> createStay(
      Map<String, dynamic> fields,
      List<XFile> photos,
      XFile? sltdaDoc
      ) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    var uri = Uri.parse('$baseUrl/accounts/stays/create/');
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
            filename: sltdaDoc.name
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
            'sltda_document',
            sltdaDoc.path
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
            filename: photo.name
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
            'photos',
            photo.path
        ));
      }
    }

    // 4. Send
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create stay: ${response.body}');
    }
  }
}