# 🏠 Roomly - Complete Testing & Installation Guide

This document provides a comprehensive, step-by-step guide on how to configure, install, run, and test the **Roomly Room Rental Marketplace** application. It covers both local testing (using emulator or physical devices) and standard QA verification pipelines.

---

## 📋 Table of Contents
1. [🛠️ Prerequisites & Installation](#1-prerequisites--installation)
2. [⚙️ Local Environment Configuration](#2-local-environment-configuration)
3. [🚀 Compiling & Running the App](#3-compiling--running-the-app)
4. [🧪 Running Automatic Tests](#4-running-automatic-tests)
5. [📱 Step-by-Step Functional Testing Guide](#5-step-by-step-functional-testing-guide)
6. [🔧 Troubleshooting common issues](#6-troubleshooting)

---

## 🛠️ 1. Prerequisites & Installation

To run and test the Roomly mobile app, you need to set up your local development machine with the Flutter SDK and Android toolchain.

### A. Install Flutter SDK
1.  **Download Flutter:** Download Flutter version `3.24.0` (stable) or later from the [Official Flutter Website](https://docs.flutter.dev/get-started/install).
2.  **Extract SDK:** Extract the zip/tar package to an installation folder (e.g., `C:\src\flutter` on Windows or `/Development/flutter` on macOS/Linux).
3.  **Update Path Variables:** Add the flutter bin folder to your system environment variables path:
    *   **Mac/Linux:** Add `export PATH="$PATH:/Development/flutter/bin"` to your `~/.zshrc` or `~/.bashrc` file.
    *   **Windows:** Edit user environment variables and append `C:\src\flutter\bin` to the `Path` variable.
4.  **Verify installation:** Open a terminal and run:
    ```bash
    flutter --version
    ```

### B. Install Android Studio & Android SDK
1.  **Download Android Studio:** Download and install [Android Studio](https://developer.android.com/studio).
2.  **Install SDK Components:** Open Android Studio, navigate to SDK Manager, and install:
    *   **Android SDK Platform-Tools**
    *   **Android SDK Build-Tools**
    *   **SDK Platform (Android 34 or higher)**
3.  **Setup Environment Variables:** Ensure `ANDROID_HOME` is set up pointing to your SDK path (e.g. `%LOCALAPPDATA%\Android\Sdk` on Windows or `~/Library/Android/sdk` on macOS).

### C. Connect your Testing Device
*   **Option A: Physical Device (Recommended):**
    1.  On your Android phone, go to **Settings** -> **About Phone** -> Tap **Build Number** 7 times to enable *Developer Options*.
    2.  Go to **Developer Options** and enable **USB Debugging**.
    3.  Connect your phone to your computer via USB, accept the prompt on the screen, and run:
        ```bash
        flutter devices
        ```
*   **Option B: Android Emulator:**
    1.  Open Android Studio, go to **Virtual Device Manager (AVD)**, and click **Create Device**.
    2.  Choose a device (e.g., Pixel 7), download an Android System Image (API 34), and click **Finish**.
    3.  Launch the emulator.

---

## ⚙️ 2. Local Environment Configuration

Before launching the app, you need to configure the networking configuration and payment gateway properties.

### A. Point App to the Backend Server
The app communicates with the Laravel REST API backend. Open `/lib/core/config/api_config.dart` and configure your API URL based on your workspace setup:

*   **For Android Emulator:** Use the special gateway IP `10.0.2.2` which tunnels back to your computer's localhost:
    ```dart
    // Inside lib/core/config/api_config.dart
    static const String _devBaseUrl = 'http://10.0.2.2:8000/api/v1';
    ```
*   **For Physical Android Device:** Find your computer's local IP address (e.g., `192.168.1.50`) and make sure both your phone and computer are on the exact same Wi-Fi router network:
    ```dart
    static const String _devBaseUrl = 'http://192.168.1.50:8000/api/v1';
    ```
*   **For Staging/Production Servers:**
    ```dart
    static const String _stagingBaseUrl = 'https://staging-api.roomly.com/api/v1';
    ```

### B. Configure Razorpay Sandbox Key
To test payments (without using real money), use Razorpay's Test environment:
1.  Log in to your [Razorpay Dashboard](https://dashboard.razorpay.com/) (create a free account if you don't have one).
2.  Switch to **Test Mode** (toggle on the left sidebar).
3.  Go to **Settings** -> **API Keys** -> click **Generate Test Key**.
4.  Copy your **Key ID** (starts with `rzp_test_...`).
5.  Open `lib/core/config/api_config.dart` and update the key:
    ```dart
    static const String _devRazorpayKey = 'rzp_test_YOUR_KEY_HERE';
    ```

---

## 🚀 3. Compiling & Running the App

Once configured, fetch dependencies and run the application in Debug Mode.

### Step 1: Install Dependencies
Open your terminal in the workspace root (`/home/user/roomly`) and run:
```bash
flutter pub get
```

### Step 2: Run Static Code Analysis
Make sure there are absolutely zero linting errors or compilation failures in the workspace:
```bash
flutter analyze
```

### Step 3: Launch Roomly App
*   Launch on your connected emulator or USB device:
    ```bash
    flutter run
    ```
*   To compile a direct, installable **Debug APK** file to send to QA or colleagues:
    ```bash
    flutter build apk --debug
    ```
    *(The output file will be written to `build/app/outputs/flutter-apk/app-debug.apk`)*.

---

## 🧪 4. Running Automatic Tests

Roomly is built with a pre-configured unit testing suite targeting Clean Architecture contracts and parsing repositories.

To execute all unit tests, run:
```bash
flutter test
```

The test runner will automatically mock API clients, serialize and parse JSON models, verify auth sessions, and test the property filtering engines.

---

## 📱 5. Step-by-Step Functional Testing Guide

Once you launch the app, follow this guided workflow to verify all key business logic flows of the Roomly application.

### Test Case 1: Tenant Registration & Login
1.  **Register:** Launch the app, tap **Sign Up** at the bottom of the Login Screen.
2.  **Role Selector:** On the Registration Screen, choose **Tenant** role.
3.  **Fill Form:** Enter your name, email, phone number, and a strong password. Tap **Create Account**.
4.  **Auto-Auth:** Verify that once the backend returns success, you are automatically redirected to the **Property List (Home) Screen**.
5.  **Log out:** Go to the Profile tab, tap **Logout**, and verify you are returned to the Login Screen.
6.  **Login:** Enter your registered credentials and verify you log back in successfully.

### Test Case 2: Browsing & Filtering Listings (Tenant Flow)
1.  **Browse:** Scroll down the list of properties on the Home screen.
2.  **Teaser Check:** Select any property. Since you do not have an active pass, verify that:
    *   The property description is truncated (first 100 characters only).
    *   The exact address, map, and owner contact buttons are hidden behind a lock.
    *   A prominent **Unlock Full Details** block containing a "Buy Access Pass - ₹5" button is visible.
3.  **Search:** Tap the search bar on top, search for a city (e.g., "Bangalore"), and verify listings filter accordingly.
4.  **Map Toggle:** Tap the **Map Icon** in the top right corner and verify markers appear indicating listing rent tags.

### Test Case 3: Purchasing ₹5 Access Pass (Micropayments)
1.  **Initiate Purchase:** Open any property details teaser screen and click **Buy Access Pass - ₹5**.
2.  **Razorpay Screen:** Verify the Razorpay SDK checkout overlay slides open showing the correct amount (**₹5.00** / 500 Paise).
3.  **Simulate Payment:**
    *   Select **Netbanking** or **UPI**.
    *   Choose **Success** to simulate a valid payment.
4.  **Verify Unlock:** Once completed, verify:
    *   A "Payment Successful" dialog displays the transaction details and 24-hour expiration time.
    *   You are returned to the property details screen, and **all locked information is now fully visible** (exact address, interactive local map with marker, description, and owner contact details).
5.  **Test Communications:** Click **WhatsApp** or **Call**. Verify that your device attempts to launch WhatsApp or the local phone dialer.

### Test Case 4: Owner Listing Submission & Payments
1.  **Create Owner Account:** Register a new user as an **Owner** on the Sign-Up screen.
2.  **My Listings Dashboard:** Tap the **My Listings** tab at the bottom navigation bar.
3.  **Add Form:** Tap the **+** icon in the top-right corner to open the **Add Property Screen**.
4.  **Fill Fields:** Upload placeholder photos, add title, description, rent, deposit, and select configuration values.
5.  **Map Geolocation:** Click **Pick on Map**, tap any location on the interactive map selector, and click back. Verify latitude and longitude are calculated.
6.  **Pay Listing Fee:** Click **Submit for Approval (₹9)**. Verify the Razorpay overlay opens showing **₹9.00**. Simulate a successful transaction.
7.  **Approval Queue:** Verify the listing is sent successfully and displays in your dashboard with a `Pending Approval` badge.

---

## 🔧 6. Troubleshooting

### Q: Connection Refused / Connection Timeout error
*   **Cause:** The Android emulator or physical device cannot reach your local Laravel development server.
*   **Fix:**
    1.  Ensure your Laravel server is running and listening on all interfaces: `php artisan serve --host=0.0.0.0 --port=8000`.
    2.  Check that your computer and phone are connected to the exact same Wi-Fi network.
    3.  Make sure you updated `api_config.dart` with your machine's correct local IP address.

### Q: Razorpay checkout screen closes instantly or fails to open
*   **Cause:** Invalid Key ID or mismatched currency package dependencies.
*   **Fix:** Ensure you pasted your exact Razorpay Test Key ID inside `lib/core/config/api_config.dart` and that it begins with `rzp_test_`.

### Q: Emulator command killed with exit code 137 (OOM)
*   **Cause:** Out of memory error on constrained environments (often occurs on machines with <2GB RAM).
*   **Fix:** Export the temporary pub cache environment variable in your terminal session before launching:
    ```bash
    export PUB_CACHE="/tmp/pub_cache"
    ```
