# Flutter Android Development - Quick Start Guide

## ✅ Current Status

- **Flutter SDK**: Installed at `/mnt/oss/flutter` (v3.24.0)
- **Dart SDK**: v3.5.0 (included with Flutter)
- **Sample Project**: Created at `/workspace/my_flutter_app`
- **Git Repo**: Initialized at `/workspace`

## 🚀 Quick Commands

### Setup Environment
```bash
export PATH="$PATH:/mnt/oss/flutter/bin"
export PUB_CACHE="/tmp/pub_cache"
```

### Verify Installation
```bash
flutter --version
dart --version
```

### Work with the Sample Project
```bash
cd /workspace/my_flutter_app

# Get dependencies (requires Android SDK)
flutter pub get

# Analyze code
flutter analyze

# Build APK (requires Android SDK)
flutter build apk --release
```

## ⚠️ Important Notes

1. **Memory Limitations**: The environment has only ~1GB RAM. Flutter commands may be killed if they exceed memory limits.

2. **Android SDK Required**: To actually build/run Android apps, you need to install Android SDK command-line tools:
   ```bash
   # Download Android command-line tools
   mkdir -p /mnt/oss/android-sdk/cmdline-tools
   cd /mnt/oss/android-sdk/cmdline-tools
   wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
   unzip commandlinetools-linux-11076708_latest.zip
   mv cmdline-tools latest
   
   # Setup environment
   export ANDROID_HOME=/mnt/oss/android-sdk
   export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   
   # Accept licenses and install components
   yes | sdkmanager --licenses
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   
   # Verify
   flutter doctor
   ```

3. **iOS Development**: Not available in this Linux environment. iOS builds require macOS with Xcode.

## 📁 Project Structure

```
/workspace/
├── my_flutter_app/       # Sample Flutter project
│   ├── lib/
│   │   └── main.dart     # App entry point
│   ├── pubspec.yaml      # Dependencies
│   └── README.md
├── FLUTTER_SETUP_GUIDE.md
├── WORKFLOW_GUIDE.md
├── STATUS.md
└── QUICKSTART.md         # This file
```

## 🔧 Troubleshooting

### Command killed (exit code 137)
This means out of memory. Try:
- Closing other applications
- Using `PUB_CACHE` on `/tmp` instead of home directory
- Running commands during low-usage periods

### Git safe directory warnings
Already configured. If you see more warnings:
```bash
git config --global --add safe.directory /mnt/oss/flutter
```

## 📚 Next Steps

1. Install Android SDK (see above)
2. Run `flutter doctor` to verify setup
3. Create an Android emulator or connect a device
4. Run `flutter run` to test the app
5. Start building your features!

For detailed guides, see:
- `FLUTTER_SETUP_GUIDE.md` - Complete setup instructions
- `WORKFLOW_GUIDE.md` - Daily development workflow
- `STATUS.md` - Current environment status
