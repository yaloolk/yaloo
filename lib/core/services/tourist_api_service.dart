// tourist_api_service.dart


import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_exceptions.dart';

class TouristApiService {
  final ApiClient _client = ApiClient();

  Future<T> _handleRequest<T>(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } catch (e) {
      throw Exception(ApiErrorHandler.getFriendlyMessage(e));
    }
  }

  // Profile
  Future<Map<String, dynamic>> getProfile() async {
    return _handleRequest(() => _client.get('/accounts/me/'));
  }

  // Django returns {message, data:{...profile}} - unwrap data key
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final body = await _handleRequest(() => _client.patch('/accounts/profile/update/', data: data));
    return (body['data'] is Map<String, dynamic>)
        ? body['data'] as Map<String, dynamic>
        : body;
  }

  // Bio
  Future<void> updateBio(String bio) async {
    await _handleRequest(() => _client.post('/accounts/profile/bio/', data: {'profile_bio': bio}));
  }

  // Interests
  Future<List<dynamic>> getUserInterests() async {
    return _handleRequest(() => _client.get('/accounts/interests/user/'));
  }

  Future<List<dynamic>> getAllInterests() async {
    return _handleRequest(() => _client.get('/accounts/interests/'));
  }

  Future<void> updateUserInterests(List<String> interestIds) async {
    await _handleRequest(() => _client.post('/accounts/interests/user/add/',
        data: {'interest_ids': interestIds}));
  }

  // Stats
  Future<Map<String, dynamic>> getUserStats() async {
    return _handleRequest(() => _client.get('/accounts/stats/'));
  }

  // Gallery
  Future<List<dynamic>> getGallery() async {
    return _handleRequest(() => _client.get('/accounts/gallery/'));
  }

  Future<Map<String, dynamic>> uploadGalleryPhoto(dynamic file) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(file.path),
    });
    return _handleRequest(() => _client.post('/accounts/gallery/upload/', data: formData));
  }

  Future<void> deleteGalleryPhoto(String photoId) async {
    await _handleRequest(() => _client.delete('/accounts/gallery/$photoId/'));
  }

  // Profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(dynamic file) async {
    final formData = FormData.fromMap({
      'profile_pic': await MultipartFile.fromFile(file.path),
    });
    return _handleRequest(() => _client.post('/accounts/profile/picture/', data: formData));
  }
}