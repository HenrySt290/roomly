import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_strings.dart';

class SecureStorageService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  SecureStorageService._();

  // Auth Token
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(
      key: AppConstants.tokenKey,
      value: token,
    );
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: token,
    );
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // Access Pass
  static Future<void> saveAccessPassExpiry(DateTime expiry) async {
    await _storage.write(
      key: AppConstants.accessPassExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  static Future<DateTime?> getAccessPassExpiry() async {
    final expiryStr = await _storage.read(key: AppConstants.accessPassExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  static Future<void> deleteAccessPassExpiry() async {
    await _storage.delete(key: AppConstants.accessPassExpiryKey);
  }

  static Future<bool> hasActiveAccessPass() async {
    final expiry = await getAccessPassExpiry();
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  // User Data (JSON string)
  static Future<void> saveUserData(String userData) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: userData,
    );
  }

  static Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userKey);
  }

  static Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  // Clear all storage (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
