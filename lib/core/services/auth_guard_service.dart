// lib/core/services/auth_guard_service.dart
//
// FIXES:
//   • Uses the fixed ApiClient (Supabase token always fresh)
//   • Added timeout guard — returns /login on connection failure
//   • Reduced consecutive API calls (single /accounts/me/ only)
//   • Logs the exact failure reason for debugging

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/network/api_client.dart';

class AuthGuardService {
  final ApiClient _apiClient = ApiClient();

  /// Determine where user should be routed after login.
  /// Returns a named route string.
  Future<String> getInitialRoute({bool forceRefresh = false}) async {
    // ── Fast-fail: if Supabase has no session, skip the API call entirely ──
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (kDebugMode) debugPrint('🔐 No Supabase session → /login');
      return '/login';
    }

    try {
      final response = await _apiClient.get('/accounts/me/');
      final user = response.data as Map<String, dynamic>;

      final userRole           = user['user_role']          as String?        ?? '';
      final isComplete         = user['is_complete']         as bool?          ?? false;
      final verificationStatus = user['verification_status'] as String?        ?? 'not_required';
      final hasVerifiedStay    = user['has_verified_stay']   as bool?          ?? false;

      if (kDebugMode) {
        debugPrint('🔐 Auth Guard:');
        debugPrint('   role=$userRole  complete=$isComplete');
        debugPrint('   verification=$verificationStatus  hasVerifiedStay=$hasVerifiedStay');
      }

      if (!isComplete) return _profileCompletionRoute(userRole);
      return _homeRoute(userRole, verificationStatus, hasVerifiedStay);

    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Auth guard DioException: ${e.type}');
        debugPrint('   status=${e.response?.statusCode}  msg=${e.message}');
      }
      // 401 → not logged in; timeout → let caller retry
      if (e.response?.statusCode == 401) return '/login';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return '/login'; // caller should show "server unreachable" UI
      }
      return '/login';
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Auth guard error: $e');
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