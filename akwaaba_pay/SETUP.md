# AkwaabaPay — Setup Guide

A voice-first bookkeeping app for Ghanaian traders. Record sales and expenses in Twi, Ga, or Fante using GhanaNLP's speech recognition.

## Quick Start

### Prerequisites

- **Flutter 3.11+** (check with `flutter --version`)
- **Dart SDK 3.11+** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- A physical Android/iOS device or emulator for testing voice features

---

## 1. Clone & Navigate

```bash
cd ~/Desktop/akwaabapay/akwaaba_pay
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Generate Drift Database Code

Drift requires code generation for the database models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> **Note:** Run this whenever you modify `lib/core/database/app_database.dart`

---

## 4. Configure GhanaNLP API Key

1. Sign up at [GhanaNLP](https://ghananlp.org) to get your API key
2. Launch the app
3. Go to **Settings** → enter your API key
4. The app stores it securely using `flutter_secure_storage`

---

## 5. Run the App

### Android

```bash
flutter run
```

### iOS (macOS only)

```bash
cd ios
pod install
cd ..
flutter run
```

---

## Project Structure

```
lib/
├── app/
│   ├── app.dart           # Main app widget with theme & router
│   └── app_shell.dart     # Bottom nav + voice input handling
├── core/
│   ├── constants/         # App constants, API endpoints, languages
│   ├── database/          # Drift database (Sales, Expenses, Categories)
│   ├── network/           # GhanaNLP API client
│   ├── providers/         # Global Riverpod providers
│   ├── theme/             # Colors, typography, app theme
│   └── utils/             # Formatters (currency, date)
└── features/
    ├── dashboard/         # Home screen with charts & summary
    ├── expenses/          # Expense list + providers
    ├── reports/           # Sales reports with pie charts
    ├── sales/             # Sales list + date filtering
    ├── settings/          # API key, language, business name
    └── voice_input/       # Audio recording, ASR, command parsing
```

---

## Key Features

| Feature | How It Works |
|---------|--------------|
| **Voice Recording** | Tap mic → speak in Twi/Ga/Fante → confirm |
| **GhanaNLP ASR** | Audio uploaded to `translation.ghananlp.org/asr` |
| **Command Parsing** | Regex extracts item, price, quantity from transcription |
| **Offline Storage** | Drift SQLite database works without internet |
| **Date Filtering** | Sales list supports Today, 7 days, 30 days, This Month |
| **Visual Reports** | Category breakdown charts using `fl_chart` |

---

## Supported Languages

| Language | Code | Example Voice Command |
|----------|------|----------------------|
| Twi | `tw` | "Me tɔn brodo GH₵5" |
| Ga | `gaa` | "Mi fe fufu GHS 10" |
| Fante | `fat` | "Mepɛn bianoo GH₵3" |
| English | `en` | "Sold rice for 20 cedis" |

---

## Troubleshooting

### `flutter analyze` shows errors about `Sale`, `Expense` types

Run the build generator:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Microphone permission denied

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record voice commands</string>
```

### GhanaNLP API errors

1. Verify your API key in **Settings**
2. Check internet connection
3. Ensure audio file is WAV format, 16kHz, mono

---

## Build for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

---

## Tech Stack Summary

| Component | Package |
|-----------|---------|
| State Management | `flutter_riverpod: ^3.3.1` |
| Database | `drift: ^2.24.0`, `drift_flutter: ^0.2.4` |
| Routing | `go_router: ^17.1.0` |
| HTTP Client | `http: ^1.6.0` |
| Charts | `fl_chart: ^1.2.0` |
| Audio Recording | `record: ^5.2.0` |
| Secure Storage | `flutter_secure_storage: ^9.2.4` |
| Fonts | `google_fonts: ^6.2.1` |

---

## License

MIT License — Built for Ghanaian traders 🇬🇭
