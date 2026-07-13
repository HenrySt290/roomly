# 🏠 Roomly - Android App

Professional Flutter-based Android application for the Roomly room rental marketplace.

## 📋 Project Overview

Roomly is a two-sided rental marketplace where:
- **Property Owners** list rooms for ₹9 listing fee
- **Tenants** purchase ₹5 Access Pass (24-hour validity) to unlock complete property details

## 🏗️ Architecture

Clean Architecture with three main layers:

```
lib/
├── core/                    # Core utilities, constants, theme, network
│   ├── constants/          # API endpoints, app strings, constants
│   ├── errors/             # Error handling and failures
│   ├── network/            # API client, interceptors
│   ├── theme/              # Colors, text styles, themes
│   └── utils/              # Helpers, extensions, validators
├── data/                    # Data layer
│   ├── models/             # Data models (JSON serialization)
│   ├── repositories/       # Repository implementations
│   └── sources/            # Local & remote data sources
├── domain/                  # Business logic layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business use cases
├── presentation/            # UI layer
│   ├── providers/          # State management (Riverpod)
│   ├── screens/            # UI screens
│   └── widgets/            # Reusable widgets
└── features/                # Feature modules
    ├── auth/               # Authentication feature
    ├── properties/         # Property management
    ├── access_pass/        # Access pass purchases
    ├── payment/            # Payment integration
    ├── profile/            # User profiles
    ├── search/             # Search & filters
    └── notifications/      # Notifications
```

## 🚀 Features

### Authentication
- Login/Register with email & phone
- JWT token authentication
- Role selection (Tenant/Owner)
- Email verification
- Password reset

### Property Management (Owner)
- Create/Edit property listings
- Upload multiple images
- Set amenities, rules, preferences
- Pay ₹9 listing fee via Razorpay
- Mark as occupied/relist
- View analytics (views, favorites)

### Property Discovery (Tenant)
- Browse listings with teaser info
- Advanced search & filters
- Purchase ₹5 Access Pass (24hr validity)
- Unlock full property details
- Contact owners (phone/WhatsApp)
- Save favorites
- Leave reviews

### Payment Integration
- Razorpay payment gateway
- Listing fee (₹9)
- Access Pass (₹5)
- Payment history

### Access Pass System
- 24-hour validity
- Unlimited property viewing
- Auto-expiry tracking
- Purchase history

## 🛠️ Tech Stack

- **Framework**: Flutter 3.24+
- **Language**: Dart 3.5+
- **State Management**: Riverpod 2.x
- **Networking**: Dio + Retrofit
- **Local Storage**: Hive
- **Secure Storage**: flutter_secure_storage
- **Payments**: Razorpay Flutter
- **Maps**: flutter_map + OpenStreetMap
- **Forms**: flutter_form_builder
- **Validation**: form_builder_validators
- **UI**: Material 3, Google Fonts, Shimmer
- **Images**: cached_network_image, image_picker

## 📦 Dependencies

See `pubspec.yaml` for complete list.

Key packages:
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  dio: ^5.4.0
  retrofit: ^4.0.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  razorpay_flutter: ^1.3.7
  flutter_map: ^6.1.0
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.1
  flutter_form_builder: ^9.2.1
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK 3.24+
- Android Studio / VS Code
- Android SDK (API 34+)
- Razorpay Account (for payments)

### Installation

1. **Clone & Navigate**
```bash
cd /workspace/roomly_app
```

2. **Get Dependencies**
```bash
export PATH="$PATH:/mnt/oss/flutter/bin"
export PUB_CACHE="/tmp/pub_cache"
flutter pub get
```

3. **Configure Environment**
Update `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'YOUR_API_URL';
static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET';
```

4. **Run Development Build**
```bash
flutter run --debug
```

5. **Build Release APK**
```bash
flutter build apk --release
```

## 📱 Screen Flow

### Tenant Flow
```
Splash → Onboarding → Login/Register → Home → Search → 
Property List → Property Teaser → Buy Access Pass → 
Full Details → Contact Owner → Visit → Review
```

### Owner Flow
```
Splash → Onboarding → Login/Register → KYC → 
Dashboard → Add Property → Upload Images → 
Pay Listing Fee → Published → Manage Enquiries → 
Mark Occupied → Relist
```

## 🔐 Security

- JWT Token Authentication
- Secure token storage
- HTTPS only
- Input validation
- XSS/CSRF protection
- Rate limiting ready

## 🎨 Design System

- **Primary Color**: #6C63FF (Purple)
- **Secondary Color**: #00D9A0 (Teal)
- **Font**: Poppins (Google Fonts)
- **Theme**: Material 3
- **Border Radius**: 12px (cards), 16px (buttons)
- **Elevation**: 2-8dp

## 📝 Development Guidelines

1. **Code Style**: Follow Dart style guide
2. **State Management**: Use Riverpod providers
3. **Error Handling**: Implement in repository layer
4. **Testing**: Write unit tests for use cases
5. **Documentation**: Document public APIs

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Generate docs
flutter doc
```

## 📤 Deployment

### Build APK
```bash
flutter build apk --release --split-per-abi
```

### Build App Bundle
```bash
flutter build appbundle --release
```

### Version Management
Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+build_number
```

## 🐛 Known Limitations

- iOS builds require macOS (not supported in current env)
- Push notifications need Firebase setup
- Real-time chat not implemented (V2)
- Video tours not implemented (V2)

## 📚 Documentation

- [API Constants](lib/core/constants/api_constants.dart)
- [App Strings](lib/core/constants/app_strings.dart)
- [Theme Setup](lib/core/theme/)
- [Entity Models](lib/domain/entities/)

## 🚀 Roadmap (V2)

- [ ] AI Property Recommendations
- [ ] In-app Chat
- [ ] WhatsApp Automation
- [ ] Subscription Plans
- [ ] Referral Program
- [ ] Featured Listings
- [ ] Fraud Detection AI
- [ ] Mobile Apps (iOS)
- [ ] Virtual Tours

## 📄 License

Private Commercial SaaS  
Copyright © Roomly - All Rights Reserved

---

**Built with ❤️ using Flutter**
