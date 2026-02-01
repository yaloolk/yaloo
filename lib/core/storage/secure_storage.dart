// lib/core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create a singleton instance
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  // Initialize flutter_secure_storage
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _isProfileCompleteKey = 'is_profile_complete';

  // ==================== ACCESS TOKEN ====================

  /// Save the JWT access token
  Future<void> setAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      print('✅ Access token saved to SecureStorage');
    } catch (e) {
      print('❌ Error saving access token: $e');
      rethrow;
    }
  }

  /// Get the JWT access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null) {
        print('✅ Access token retrieved from SecureStorage');
      } else {
        print('⚠️ No access token found in SecureStorage');
      }
      return token;
    } catch (e) {
      print('❌ Error reading access token: $e');
      return null;
    }
  }

  /// Delete the access token
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      print('✅ Access token deleted from SecureStorage');
    } catch (e) {
      print('❌ Error deleting access token: $e');
    }
  }

  // ==================== REFRESH TOKEN ====================

  /// Save the refresh token
  Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      print('✅ Refresh token saved to SecureStorage');
    } catch (e) {
      print('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('❌ Error reading refresh token: $e');
      return null;
    }
  }

  /// Delete the refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
      print('✅ Refresh token deleted from SecureStorage');
    } catch (e) {
      print('❌ Error deleting refresh token: $e');
    }
  }

  // ==================== USER DATA ====================

  /// Save user ID
  Future<void> setUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      print('❌ Error saving user ID: $e');
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('❌ Error reading user ID: $e');
      return null;
    }
  }

  /// Save user role
  Future<void> setUserRole(String role) async {
    try {
      await _storage.write(key: _userRoleKey, value: role);
    } catch (e) {
      print('❌ Error saving user role: $e');
    }
  }

  /// Get user role
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (e) {
      print('❌ Error reading user role: $e');
      return null;
    }
  }

  /// Save profile completion status
  Future<void> setProfileComplete(bool isComplete) async {
    try {
      await _storage.write(
        key: _isProfileCompleteKey,
        value: isComplete.toString(),
      );
    } catch (e) {
      print('❌ Error saving profile completion status: $e');
    }
  }

  /// Get profile completion status
  Future<bool> isProfileComplete() async {
    try {
      final value = await _storage.read(key: _isProfileCompleteKey);
      return value == 'true';
    } catch (e) {
      print('❌ Error reading profile completion status: $e');
      return false;
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Save complete session data
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    String? userId,
    String? userRole,
    bool? isProfileComplete,
  }) async {
    await setAccessToken(accessToken);
    if (refreshToken != null) await setRefreshToken(refreshToken);
    if (userId != null) await setUserId(userId);
    if (userRole != null) await setUserRole(userRole);
    if (isProfileComplete != null) await setProfileComplete(isProfileComplete);
    print('✅ Complete session saved to SecureStorage');
  }

  /// Clear all session data (logout)
  Future<void> clearSession() async {
    try {
      await _storage.deleteAll();
      print('✅ All session data cleared from SecureStorage');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  /// Check if user is logged in (has valid access token)
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== DEBUG METHODS ====================

  /// Print all stored values (for debugging only)
  Future<void> debugPrintAll() async {
    print('=== SECURE STORAGE DEBUG ===');
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final userId = await getUserId();
    final userRole = await getUserRole();
    final profileComplete = await isProfileComplete();

    print('Access Token: ${accessToken?.substring(0, 50)}...');
    print('Refresh Token: ${refreshToken?.substring(0, 50) ?? 'null'}...');
    print('User ID: $userId');
    print('User Role: $userRole');
    print('Profile Complete: $profileComplete');
    print('=== END DEBUG ===');
  }

  /// Read all keys and values (for debugging)
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('❌ Error reading all values: $e');
      return {};
    }
  }
}