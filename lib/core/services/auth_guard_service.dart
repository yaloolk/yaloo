// lib/core/services/auth_guard_service.dart

import 'package:flutter/foundation.dart';
import 'package:yaloo/core/services/api_service.dart';

class AuthGuardService {
  final DjangoApiService _apiService = DjangoApiService();

  /// Determine where user should be routed
  Future<String> getInitialRoute() async {
    try {
      final user = await _apiService.getCurrentUser();
      final userRole = user['user_role'] as String;
      final isComplete = user['is_complete'] as bool? ?? false;
      final verificationStatus = user['verification_status'] as String? ?? 'not_required';
      final hasVerifiedStay = user['has_verified_stay'] as bool? ?? false;

      if (kDebugMode) {
        debugPrint('🔐 Auth Guard Check:');
      }
      if (kDebugMode) {
        debugPrint('  Role: $userRole');
      }
      if (kDebugMode) {
        debugPrint('  Profile Complete: $isComplete');
      }
      if (kDebugMode) {
        debugPrint('  Verification Status: $verificationStatus');
      }
      if (kDebugMode) {
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
      // Tourists don't need verification
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
      // NEW LOGIC:
      // Host must be verified AND have at least one verified stay
        if (verificationStatus == 'verified' && hasVerifiedStay) {
          return '/hostDashboard';
        }
        // If host is verified but NO stay is verified, show pending
        // Or if host is pending, show pending
        else if (verificationStatus == 'rejected') {
          return '/approvalRejected';
        }
        // Default catch-all for pending profile OR pending stay
        return '/approvalPending';

      default:
        return '/login';
    }
  }

  /// Check if user can access a route (for route guards)
  Future<bool> canAccessRoute(String route) async {
    try {
      final user = await _apiService.getCurrentUser();
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