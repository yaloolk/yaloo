// lib/core/services/auth_guard_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/network/api_client.dart';

class AuthGuardService {
  final ApiClient _apiClient = ApiClient();

  Future<String> getInitialRoute({bool forceRefresh = false}) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return '/login';
    }

    try {
      final response = await _apiClient.get('/accounts/me/');
      final user = response.data as Map<String, dynamic>;

      final userRole           = user['user_role']          as String?        ?? '';
      final isComplete         = user['is_complete']         as bool?          ?? false;
      final verificationStatus = user['verification_status'] as String?        ?? 'not_required';
      final hasVerifiedStay    = user['has_verified_stay']   as bool?          ?? false;

      // Logic for existing profiles
      if (!isComplete) return _profileCompletionRoute(userRole);
      return _homeRoute(userRole, verificationStatus, hasVerifiedStay);

    } on DioException catch (e) {
      // ✅ FIX: Handle the "Profile Not Found" 404
      if (e.response?.statusCode == 404) {
        final errorMsg = e.response?.data['error']?.toString() ?? '';

        // Check user metadata from Supabase to know which completion screen to show
        final String roleFromMeta = session.user.userMetadata?['role'] ?? 'tourist';

        if (errorMsg.contains('Guide profile not found')) {
          return '/guideWelcome'; // Send to Guide completion flow
        } else if (errorMsg.contains('Host profile not found')) {
          return '/hostProfileCompletion';
        } else if (errorMsg.contains('Tourist profile not found')) {
          return '/profileCompletion';
        }
      }

      if (e.response?.statusCode == 401) return '/login';

      return '/login'; // Default fallback
    } catch (e) {
      return '/login';
    }
  }

  /// Guard individual routes. Returns true if user can access.
  Future<bool> canAccessRoute(String route) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final response = await _apiClient.get('/accounts/me/');
      final user = response.data as Map<String, dynamic>;

      final userRole           = user['user_role']          as String? ?? '';
      final isComplete         = user['is_complete']         as bool?   ?? false;
      final verificationStatus = user['verification_status'] as String? ?? 'not_required';

      if (route.contains('tourist')) {
        return userRole == 'tourist' && isComplete;
      }
      if (route.contains('guide') && !route.contains('ProfileCompletion')) {
        return userRole == 'guide' &&
            isComplete &&
            verificationStatus == 'verified';
      }
      if (route.contains('host') && !route.contains('ProfileCompletion')) {
        return userRole == 'host' &&
            isComplete &&
            verificationStatus == 'verified';
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _profileCompletionRoute(String role) {
    switch (role.toLowerCase()) {
      case 'tourist': return '/profileCompletion';
      case 'guide':   return '/guideWelcome';
      case 'host':    return '/hostProfileCompletion';
      default:        return '/login';
    }
  }

  String _homeRoute(
      String role, String verificationStatus, bool hasVerifiedStay) {
    switch (role.toLowerCase()) {
      case 'tourist':
        return '/touristDashboard';

      case 'guide':
        if (verificationStatus == 'verified')  return '/guideDashboard';
        if (verificationStatus == 'rejected')  return '/approvalRejected';
        return '/approvalPending';

      case 'host':
        if (verificationStatus == 'verified' && hasVerifiedStay) {
          return '/hostDashboard';
        }
        if (verificationStatus == 'rejected') return '/approvalRejected';
        return '/approvalPending';

      default:
        return '/login';
    }
  }
}