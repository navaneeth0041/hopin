# HopIn: Share the Ride, Split the Fare

A Flutter-based auto-sharing application for college students.

---

## Team Information

**Team B6**

| Name | Roll No |
|------|---------|
| Aditi S | AM.SC.U4CSE23104 |
| Rohit Prasanth | AM.SC.U4CSE23148 |
| Jodhil Lal | AM.SC.U4CSE23124 |
| Navaneeth B | AM.SC.U4CSE23138 |

---

## Prerequisites

- Flutter SDK (v3.0 or higher)
- Dart SDK (v2.17 or higher)
- Android Studio / VS Code
- Git

**Verify Installation:**
```bash
flutter --version
dart --version
```

---

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/navaneeth0041/hopin
cd hopin
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the Application

```bash
flutter run
```

---

## Running the App

**On Connected Device/Emulator:**
```bash
flutter run
```

**Check Available Devices:**
```bash
flutter devices
```

**Run on Specific Device:**
```bash
flutter run -d <device_id>
```

---

## Building APK (Optional)

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

## Project Dependencies

**Main packages used:**
- `provider` - State management
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Backend services
- `image_picker` - Profile images
- `shared_preferences` - Local storage

All dependencies are listed in `pubspec.yaml`

---

## Troubleshooting

**If build fails:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## Minimum Device Requirements

- Android 9.0+ (API 28) with 2GB RAM
- iOS 13.0+ with 2GB RAM
- Active internet connection
- GPS enabled

---

**Course:** 23CSE311 Software Engineering  
**Institution:** Amrita School of Computing  
**Date:** November 2024
