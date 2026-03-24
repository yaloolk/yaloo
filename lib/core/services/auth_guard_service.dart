// lib/core/services/auth_guard_service.dart

import 'package:flutter/foundation.dart';
import 'package:yaloo/core/network/api_client.dart';

class AuthGuardService {
  final ApiClient _apiClient = ApiClient();

  /// Determine where user should be routed
  Future<String> getInitialRoute({bool forceRefresh = false}) async {
    try {
      final response = await _apiClient.get('/accounts/me/');  // ✅ Changed
      final user = response.data;

      final userRole = user['user_role'] as String;
      final isComplete = user['is_complete'] as bool? ?? false;
      final verificationStatus = user['verification_status'] as String? ?? 'not_required';
      final hasVerifiedStay = user['has_verified_stay'] as bool? ?? false;

      if (kDebugMode) {
        debugPrint('🔐 Auth Guard Check:');
        debugPrint('  Role: $userRole');
        debugPrint('  Profile Complete: $isComplete');
        debugPrint('  Verification Status: $verificationStatus');
        debugPrint('  Has Verified Stay: $hasVerifiedStay');
      }

      // Profile not complete → Go to profile completion
      if (!isComplete) {
        return _getProfileCompletionRoute(userRole);
      }

      // Profile complete → Check role and verification
      return _getHomeRoute(userRole, verificationStatus, hasVerifiedStay);

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Auth guard error: $e');
      }
      return '/login';
    }
  }

  String _getProfileCompletionRoute(String role) {
    switch (role.toLowerCase()) {
      case 'tourist':
        return '/profileCompletion';
      case 'guide':
        return '/guideWelcome';
      case 'host':
        return '/hostProfileCompletion';
      default:
        return '/login';
    }
  }

  String _getHomeRoute(String role, String verificationStatus, bool hasVerifiedStay) {
    switch (role.toLowerCase()) {
      case 'tourist':
        return '/touristDashboard';

      case 'guide':
        if (verificationStatus == 'verified') {
          return '/guideDashboard';
        } else if (verificationStatus == 'pending') {
          return '/approvalPending';
        } else if (verificationStatus == 'rejected') {
          return '/approvalRejected';
        }
        return '/approvalPending';

      case 'host':
        if (verificationStatus == 'verified' && hasVerifiedStay) {
          return '/hostDashboard';
        } else if (verificationStatus == 'rejected') {
          return '/approvalRejected';
        }
        return '/approvalPending';

      default:
        return '/login';
    }
  }

  /// Check if user can access a route (for route guards)
  Future<bool> canAccessRoute(String route) async {
    try {
      final response = await _apiClient.get('/accounts/me/');  // ✅ Changed
      final user = response.data;

      final userRole = user['user_role'] as String;
      final isComplete = user['is_complete'] as bool? ?? false;
      final verificationStatus = user['verification_status'] as String? ?? 'not_required';

      // Tourist routes
      if (route.contains('tourist')) {
        return userRole == 'tourist' && isComplete;
      }

      // Guide routes
      if (route.contains('guide') && !route.contains('ProfileCompletion')) {
        return userRole == 'guide' &&
            isComplete &&
            verificationStatus == 'verified';
      }

      // Host routes
      if (route.contains('host') && !route.contains('ProfileCompletion')) {
        return userRole == 'host' &&
            isComplete &&
            verificationStatus == 'verified';
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}