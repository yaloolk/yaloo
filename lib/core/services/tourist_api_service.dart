// tourist_api_service.dart  (FIXED)
//
// ROOT CAUSE: ApiClient base URL = http://127.0.0.1:8000/api
// Old service used /api/me/ etc -> resolved to /api/api/me/ (double prefix).
// ALL paths must be /accounts/... matching Django urls.py exactly.

import 'package:dio/dio.dart';
import '../network/api_client.dart';

class TouristApiService {
  final ApiClient _client = ApiClient();

  // Profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get('/accounts/me/');
    return response.data as Map<String, dynamic>;
  }

  // Django returns {message, data:{...profile}} - unwrap data key
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.patch('/accounts/profile/update/', data: data);
    final body = response.data as Map<String, dynamic>;
    return (body['data'] is Map<String, dynamic>)
        ? body['data'] as Map<String, dynamic>
        : body;
  }

  Future<void> updateBio(String bio) async {
    await _client.post('/accounts/profile/bio/', data: {'profile_bio': bio});
  }

  // Interests
  Future<List<dynamic>> getUserInterests() async {
    final response = await _client.get('/accounts/interests/user/');
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getAllInterests() async {
    final response = await _client.get('/accounts/interests/');
    return response.data as List<dynamic>;
  }

  Future<void> updateUserInterests(List<String> interestIds) async {
    await _client.post('/accounts/interests/user/add/',
        data: {'interest_ids': interestIds});
  }

  // Stats
  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _client.get('/accounts/stats/');
    return response.data as Map<String, dynamic>;
  }

  // Gallery
  Future<List<dynamic>> getGallery() async {
    final response = await _client.get('/accounts/gallery/');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> uploadGalleryPhoto(dynamic file) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(file.path),
    });
    final response = await _client.post('/accounts/gallery/upload/', data: formData);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteGalleryPhoto(String photoId) async {
    await _client.delete('/accounts/gallery/$photoId/');
  }

  // Profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(dynamic file) async {
    final formData = FormData.fromMap({
      'profile_pic': await MultipartFile.fromFile(file.path),
    });
    final response = await _client.post('/accounts/profile/picture/', data: formData);
    return response.data as Map<String, dynamic>;
  }
}