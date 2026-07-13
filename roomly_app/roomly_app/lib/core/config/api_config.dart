import 'package:flutter/foundation.dart';

/// App Environment Enumeration
enum AppEnvironment { dev, staging, production }

/// Centralized API Configuration Manager
/// Manages base URLs, timeouts, and feature flags based on environment
class ApiConfig {
  static AppEnvironment _currentEnvironment = AppEnvironment.dev;

  /// Set environment (call this in main() before runApp)
  static void setEnvironment(AppEnvironment env) {
    _currentEnvironment = env;
  }

  static AppEnvironment get currentEnvironment => _currentEnvironment;

  /// Base URL based on current environment
  static String get baseUrl {
    switch (_currentEnvironment) {
      case AppEnvironment.dev:
        return 'http://10.0.2.2:8000/api'; // Android Emulator localhost
      case AppEnvironment.staging:
        return 'https://staging-api.roomly.com/api';
      case AppEnvironment.production:
        return 'https://api.roomly.com/api';
    }
  }

  /// Razorpay Key ID based on environment
  static String get razorpayKeyId {
    switch (_currentEnvironment) {
      case AppEnvironment.dev:
      case AppEnvironment.staging:
        return 'rzp_test_YOUR_TEST_KEY_ID'; // Replace with actual test key
      case AppEnvironment.production:
        return 'rzp_live_YOUR_LIVE_KEY_ID'; // Replace with actual live key
    }
  }

  /// Firebase Messaging Sender ID
  static String get fcmSenderId {
    switch (_currentEnvironment) {
      case AppEnvironment.dev:
      case AppEnvironment.staging:
        return 'YOUR_TEST_SENDER_ID';
      case AppEnvironment.production:
        return 'YOUR_LIVE_SENDER_ID';
    }
  }

  /// Connection timeout in seconds
  static const int connectTimeout = 30;

  /// Receive timeout in seconds
  static const int receiveTimeout = 60;

  /// Maximum retry attempts for failed requests
  static const int maxRetryAttempts = 3;

  /// Check if running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Check if running in production
  static bool get isProduction => _currentEnvironment == AppEnvironment.production;

  /// Get headers with versioning
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': '1.0.0',
      'X-Platform': 'android',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Get multipart headers (for file uploads)
  static Map<String, String> getMultipartHeaders({String? token}) {
    final headers = {
      'Accept': 'application/json',
      'X-App-Version': '1.0.0',
      'X-Platform': 'android',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Note: Content-Type is set automatically by Dio for multipart
    return headers;
  }
}
