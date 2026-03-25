// lib/features/tourist/services/tourist_public_profile_service.dart

import 'dart:convert';
import 'package:yaloo/core/network/api_client.dart';         // your existing ApiClient
import 'package:yaloo/features/tourist/models/tourist_public_profile_model.dart';

class TouristPublicProfileService {
  final _api = ApiClient();

  /// Fetches the public profile of a tourist by their user ID.
  /// Endpoint: GET /accounts/tourist/<userId>/public-profile/
  Future<TouristPublicProfileModel> fetchProfile(String userId) async {
    final response = await _api.get('/accounts/tourist/$userId/public-profile/');

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return TouristPublicProfileModel.fromJson(data);
    }

    throw Exception('Failed to load tourist profile (${response.statusCode})');
  }
}