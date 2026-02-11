# Mrs Diary (MRS Diary)

Mrs Diary is a Flutter application built to track customer accounts and daily recharge/payment logs. It helps you record collections quickly and view status (Paid/Pending/Expired/Balance) at a glance.

## App Overview

- Authentication: Google Sign-In + Firebase Auth
- Data: Firebase Firestore (ownerId scoped)
- Notifications: Firebase Messaging + Local Notifications
- Security: App passcode lock (6-digit)
- UX: Light/Dark theme, Tamil fonts, responsive typography

## Key Features

- Old/New customer records (OldUser / NewUser)
- Daily payment entry and edits
- Pending, Paid, Balance, Expired status calculations
- Dashboard summary with quick tiles
- Village/Area filters and search
- Records & Reports: Monthly, Daily, All Transactions views
- Notes module (search, edit, delete)
- Astrology module (profiles, chart details, audio recording, gocharam parva entries)
- Profile settings (passcode, theme, language)

## UI and Design Highlights

- Gradient cards, modern list tiles, and clean sectioning
- Responsive text scaling (small to large screens)
- Tamil-first typography (TamilArima, TamilArima2)
- Consistent button styles with loading feedback
- Custom widgets for fields, cards, list tiles, and alerts

## Architecture

### 1) Presentation Layer (UI)

- Screens: `lib/scr/ui/`
- Major flows: Auth, Home, Dashboard, Users, Payments, Records, Notes, Settings, Astrology

### 2) State Management

- Provider: `VillageProvider`, `AppSettings`
- Firestore streams for live updates

### 3) Services / Helpers

- Auth: Google + Firebase Auth
- Firestore services: payments, dashboard, total counters, user CRUD
- Notifications: FCM + local notifications
- App settings: theme and language saved in shared preferences

### 4) Data Layer

Firestore collections used:

- `OldUser`, `NewUser`
- `PaymentRecords`
- `DashboardPaymentRecords`
- `Villages`
- `Notes`
- `AstrologyProfiles`

## Folder Structure (high level)

```
lib/
  main.dart
  scr/
    helpers/        # Firebase + business services
    models/         # Data models
    providers/      # Provider state
    ui/             # Screens
    widgets/        # Reusable UI components
```

## Tech Stack

- Flutter + Dart
- Firebase: Auth, Firestore, Storage, Messaging
- Provider, GetX (utility), SharedPreferences
- UI utilities: animations, loading, toasts, refresh, icons
- Media: image picker, audio record/playback

## Getting Started

### Prerequisites

- Flutter SDK (Dart >= 3.0)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator

### Install

```bash
git clone https://github.com/sanji185/mrs_dth_diary_v1.git
cd mrs_dth_diary_v1
flutter pub get
```

### Run

```bash
flutter run
```

## Firebase Setup

1. Create a Firebase project.
2. Add an Android app with package name `com.sms.mrs_dth_diary_v1`.
3. Copy `google-services.json` into `android/app/`.
4. Enable Authentication and Firestore in the Firebase console.

## Build and Release

Release APK:

```bash
flutter build apk --release
```

Release App Bundle (Play Store):

```bash
flutter build appbundle --release
```

Note: Android release signing is currently configured with debug keys. For production, update `key.properties` and set the release signing config.

## License

MIT License. See LICENSE.

## Contact

Open an issue for questions or follow https://github.com/sanji185.
