import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();

  // General
  static const String appName = 'Roomly';
  static const String appTagline = 'Find Your Perfect Room';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String save = 'Save';
  static const String submit = 'Submit';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String noData = 'No data available';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Please try again';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String phone = 'Phone Number';
  static const String name = 'Full Name';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String loginToContinue = 'Login to continue';
  static const String signUpNow = 'Sign Up Now';
  static const String verifyEmail = 'Verify Email';
  static const String verificationCode = 'Verification Code';
  static const String resendCode = 'Resend Code';
  static const String emailSent = 'Email sent successfully';
  static const String checkYourEmail = 'Check your email for verification code';

  // User Roles
  static const String tenant = 'Tenant';
  static const String owner = 'Property Owner';
  static const String admin = 'Admin';
  static const String selectRole = 'Select your role';
  static const String iAmTenant = 'I\'m looking for a room';
  static const String iAmOwner = 'I want to list my property';

  // Property
  static const String properties = 'Properties';
  static const String propertyDetails = 'Property Details';
  static const String addProperty = 'Add Property';
  static const String editProperty = 'Edit Property';
  static const String deleteProperty = 'Delete Property';
  static const String propertyTitle = 'Property Title';
  static const String description = 'Description';
  static const String rent = 'Rent';
  static const String securityDeposit = 'Security Deposit';
  static const String propertyType = 'Property Type';
  static const String roomType = 'Room Type';
  static const String location = 'Location';
  static const String address = 'Address';
  static const String city = 'City';
  static const String area = 'Area';
  static const String amenities = 'Amenities';
  static const String rules = 'Rules';
  static const String availableFrom = 'Available From';
  static const String furnished = 'Furnished';
  static const String attachedBathroom = 'Attached Bathroom';
  static const String parking = 'Parking';
  static const String wifi = 'WiFi';
  static const String petFriendly = 'Pet Friendly';
  static const String genderPreference = 'Gender Preference';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String any = 'Any';
  static const String uploadImages = 'Upload Images';
  static const String imageUploaded = 'Image uploaded';
  static const String maxImages = 'Maximum 10 images allowed';
  static const String publishProperty = 'Publish Property';
  static const String markOccupied = 'Mark as Occupied';
  static const String relistProperty = 'Relist Property';
  static const String propertyStatus = 'Property Status';
  static const String viewCount = 'Views';
  static const String favouriteCount = 'Favourites';

  // Access Pass
  static const String accessPass = 'Access Pass';
  static const String buyAccessPass = 'Buy Access Pass';
  static const String accessPassPrice = '₹5';
  static const String accessPassValidity = '24 Hours Validity';
  static const String accessPassDescription = 'Unlock complete property details including contact info, address, and gallery';
  static const String accessPassActive = 'Access Pass Active';
  static const String accessPassExpired = 'Access Pass Expired';
  static const String accessPassNotPurchased = 'Purchase Access Pass to view details';
  static const String remainingTime = 'Remaining Time';
  static const String hoursLeft = 'hours left';
  static const String unlockDetails = 'Unlock Details';
  static const String purchaseNow = 'Purchase Now';
  static const String passActivated = 'Pass Activated Successfully';
  static const String passExpired = 'Your pass has expired';

  // Payment
  static const String payment = 'Payment';
  static const String listingFee = 'Listing Fee';
  static const String listingFeePrice = '₹9';
  static const String payToListing = 'Pay ₹9 to publish listing';
  static const String paymentSuccess = 'Payment Successful';
  static const String paymentFailed = 'Payment Failed';
  static const String paymentPending = 'Payment Pending';
  static const String transactionId = 'Transaction ID';
  static const String paymentHistory = 'Payment History';
  static const String razorpayNotConfigured = 'Razorpay not configured';

  // Search & Filters
  static const String searchProperties = 'Search properties...';
  static const String searchByCity = 'Search by city or area';
  static const String sortBy = 'Sort By';
  static const String newest = 'Newest';
  static const String lowestRent = 'Lowest Rent';
  static const String highestRent = 'Highest Rent';
  static const String nearest = 'Nearest';
  static const String clearFilters = 'Clear Filters';
  static const String applyFilters = 'Apply Filters';
  static const String priceRange = 'Price Range';
  static const String propertyTypes = 'Property Types';
  static const String roomTypes = 'Room Types';
  static const String moreFilters = 'More Filters';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String myProfile = 'My Profile';
  static const String myListings = 'My Listings';
  static const String activeListings = 'Active Listings';
  static const String occupiedRooms = 'Occupied Rooms';
  static const String pendingListings = 'Pending Listings';
  static const String rejectedListings = 'Rejected Listings';
  static const String favourites = 'Favourites';
  static const String recentViews = 'Recent Views';
  static const String enquiries = 'Enquiries';
  static const String reviews = 'Reviews';
  static const String notifications = 'Notifications';
  static const String settings = 'Settings';

  // Home
  static const String welcome = 'Welcome to Roomly';
  static const String findYourRoom = 'Find your perfect room';
  static const String featuredProperties = 'Featured Properties';
  static const String recentlyAdded = 'Recently Added';
  static const String popularCities = 'Popular Cities';
  static const String whyRoomly = 'Why Roomly?';
  static const String testimonials = 'Testimonials';
  static const String faq = 'FAQ';

  // KYC
  static const String kyc = 'KYC Verification';
  static const String completeKyc = 'Complete KYC';
  static const String kycRequired = 'KYC verification required to list properties';
  static const String uploadDocuments = 'Upload Documents';
  static const String aadharCard = 'Aadhar Card';
  static const String panCard = 'PAN Card';
  static const String voterId = 'Voter ID';
  static const String passport = 'Passport';
  static const String drivingLicense = 'Driving License';
  static const String kycPending = 'KYC Pending Verification';
  static const String kycApproved = 'KYC Approved';
  static const String kycRejected = 'KYC Rejected';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidPhone = 'Invalid phone number';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String invalidAmount = 'Invalid amount';
  static const String selectOption = 'Please select an option';

  // Messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logged out successfully';
  static const String propertyCreated = 'Property created successfully';
  static const String propertyUpdated = 'Property updated successfully';
  static const String propertyDeleted = 'Property deleted successfully';
  static const String propertyPublished = 'Property published successfully';
  static const String favourited = 'Added to favourites';
  static const String unfavourited = 'Removed from favourites';
  static const String enquirySent = 'Enquiry sent successfully';
  static const String reviewSubmitted = 'Review submitted successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String noInternet = 'No internet connection';
  static const String sessionExpired = 'Session expired. Please login again';

  // Bottom Navigation
  static const String home = 'Home';
  static const String explore = 'Explore';
  static const String saved = 'Saved';
  static const String profile = 'Profile';
}

// Storage Keys and App Constants
class AppConstants {
  AppConstants._();
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String hasAccessPassKey = 'has_access_pass';
  static const String accessPassExpiryKey = 'access_pass_expiry';
  
  // Pricing
  static const double listingFee = 9.0; // ₹9
  static const double accessPassPrice = 5.0; // ₹5
  static const int accessPassValidityHours = 24;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Upload
  static const int maxImageSizeMB = 5;
  static const int maxImagesPerListing = 10;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 2000;
}
