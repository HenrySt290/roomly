class ApiConstants {
  ApiConstants._();

  // Base URL - Change based on environment
  static const String baseUrl = 'https://api.roomly.com';
  static const String baseApiUrl = '$baseUrl/api/v1';

  // Endpoints - Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';

  // Endpoints - Properties
  static const String properties = '/properties';
  static const String propertyDetails = '/properties/'; // + {id}
  static const String createProperty = '/properties';
  static const String updateProperty = '/properties/'; // + {id}
  static const String deleteProperty = '/properties/'; // + {id}
  static const String publishProperty = '/properties/'; // + {id}/publish
  static const String occupyProperty = '/properties/'; // + {id}/occupy
  static const String relistProperty = '/properties/'; // + {id}/relist
  static const String propertyViews = '/properties/'; // + {id}/views
  static const String propertyFavourites = '/properties/'; // + {id}/favourite
  static const String propertyReports = '/properties/'; // + {id}/report

  // Endpoints - Access Pass
  static const String accessPassPurchase = '/access-pass/purchase';
  static const String accessPassStatus = '/access-pass/status';
  static const String accessPassHistory = '/access-pass/history';

  // Endpoints - Reviews
  static const String reviews = '/reviews';
  static const String reviewDetails = '/reviews/'; // + {id}

  // Endpoints - Enquiries
  static const String enquiries = '/enquiries';
  static const String enquiryDetails = '/enquiries/'; // + {id}

  // Endpoints - Owner
  static const String ownerProfile = '/owner/profile';
  static const String ownerKyc = '/owner/kyc';
  static const String ownerListings = '/owner/listings';
  static const String ownerDashboard = '/owner/dashboard';

  // Endpoints - Tenant
  static const String tenantProfile = '/tenant/profile';
  static const String tenantDashboard = '/tenant/dashboard';

  // Endpoints - Admin
  static const String adminUsers = '/admin/users';
  static const String adminOwners = '/admin/owners';
  static const String adminListings = '/admin/listings';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminPayments = '/admin/payments';
  static const String adminAnalytics = '/admin/analytics';

  // Endpoints - Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/'; // + {id}/read
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Endpoints - Payment
  static const String paymentCreateOrder = '/payment/create-order';
  static const String paymentVerify = '/payment/verify';
  static const String paymentHistory = '/payment/history';
  static const String listingPayments = '/payment/listings';

  // Endpoints - Search & Filters
  static const String search = '/search';
  static const String cities = '/cities';
  static const String areas = '/areas';
  static const String amenities = '/amenities';

  // Timeout
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Razorpay Configuration
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
  static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET';
}

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Roomly';
  static const String appVersion = '1.0.0';
  
  // Pricing
  static const double listingFee = 9.0; // ₹9
  static const double accessPassPrice = 5.0; // ₹5
  static const int accessPassValidityHours = 24;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String hasAccessPassKey = 'has_access_pass';
  static const String accessPassExpiryKey = 'access_pass_expiry';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Upload
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageTypes = ['image/jpeg', 'image/png', 'image/webp'];
  static const int maxImagesPerListing = 10;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 2000;

  // Map Configuration
  static const double defaultLatitude = 28.6139; // Delhi
  static const double defaultLongitude = 77.2090;
  static const double defaultZoom = 12.0;

  // Cache Duration
  static const int cacheDurationMinutes = 30;
  static const int longCacheDurationHours = 24;
}
