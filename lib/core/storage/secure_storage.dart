// lib/core/storage/secure_storage.dart
//
// IMPORTANT NOTE:
//   The access_token stored here is NO LONGER used by ApiClient to
//   authenticate requests. ApiClient now reads the token directly from
//   Supabase.instance.client.auth.currentSession (always fresh).
//
//   SecureStorage is still used for:
//     • user_id, user_role, is_profile_complete  (fast local reads)
//     • refresh_token  (if needed for non-Supabase flows)
//
//   setAccessToken() is called at login for compatibility with any
//   code that still reads it, but it is NOT the source of truth for auth.

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _accessTokenKey       = 'access_token';
  static const String _refreshTokenKey      = 'refresh_token';
  static const String _userIdKey            = 'user_id';
  static const String _userRoleKey          = 'user_role';
  static const String _isProfileCompleteKey = 'is_profile_complete';

  // ── ACCESS TOKEN ──────────────────────────────────────────────────────────
  // Stored for reference only; ApiClient reads from Supabase directly.

  Future<void> setAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      if (kDebugMode) debugPrint('✅ Access token saved (reference copy)');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error saving access token: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error reading access token: $e');
      return null;
    }
  }

  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error deleting access token: $e');
    }
  }

  // ── REFRESH TOKEN ─────────────────────────────────────────────────────────

  Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error saving refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error reading refresh token: $e');
      return null;
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error deleting refresh token: $e');
    }
  }

  // ── USER DATA ─────────────────────────────────────────────────────────────

  Future<void> setUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (_) {}
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setUserRole(String role) async {
    try {
      await _storage.write(key: _userRoleKey, value: role);
    } catch (_) {}
  }

  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setProfileComplete(bool isComplete) async {
    try {
      await _storage.write(
          key: _isProfileCompleteKey, value: isComplete.toString());
    } catch (_) {}
  }

  Future<bool> isProfileComplete() async {
    try {
      final v = await _storage.read(key: _isProfileCompleteKey);
      return v == 'true';
    } catch (_) {
      return false;
    }
  }

  // ── SESSION ───────────────────────────────────────────────────────────────

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    String? userId,
    String? userRole,
    bool? isProfileComplete,
  }) async {
    await setAccessToken(accessToken);
    if (refreshToken     != null) await setRefreshToken(refreshToken);
    if (userId           != null) await setUserId(userId);
    if (userRole         != null) await setUserRole(userRole);
    if (isProfileComplete != null) await setProfileComplete(isProfileComplete);
    if (kDebugMode) debugPrint('✅ Session saved to SecureStorage');
  }

  Future<void> clearSession() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) debugPrint('✅ Session cleared');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error clearing session: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── DEBUG ─────────────────────────────────────────────────────────────────

  Future<void> debugPrintAll() async {
    if (!kDebugMode) return;
    debugPrint('=== SECURE STORAGE DEBUG ===');
    final at = await getAccessToken();
    final rt = await getRefreshToken();
    final uid = await getUserId();
    final role = await getUserRole();
    final pc = await isProfileComplete();
    debugPrint('Access Token (first 40): ${at?.substring(0, at.length.clamp(0, 40))}…');
    debugPrint('Refresh Token: ${rt != null ? '${rt.substring(0, rt.length.clamp(0, 20))}…' : 'null'}');
    debugPrint('User ID: $uid');
    debugPrint('User Role: $role');
    debugPrint('Profile Complete: $pc');
    debugPrint('=== END DEBUG ===');
  }

  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (_) {
      return {};
    }
  }
}