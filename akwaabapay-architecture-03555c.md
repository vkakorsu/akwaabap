# AkwaabaPay — Voice-First Bookkeeping App for Ghanaian Traders

A Flutter app (Android + iOS) enabling market women and small traders in Ghana to record sales via voice commands in Twi, Ga, or Fante, powered by GhanaNLP's ASR API, with local-first data storage.

---

## 1. Tech Stack

| Layer | Technology | Why |
|---|---|---|
| **Framework** | Flutter 3.x + Dart | Cross-platform, single codebase for Android & iOS |
| **State Management** | Riverpod 2.0 | Type-safe, testable, scales well for advanced devs |
| **Local DB** | Isar (or Drift/SQLite) | Fast embedded NoSQL DB, great offline support, reactive queries |
| **Speech-to-Text** | GhanaNLP Khaya ASR API | Only viable option for Twi/Ga/Fante transcription |
| **Text-to-Speech** | GhanaNLP TTS API | Voice feedback/confirmations in local languages |
| **Translation** | GhanaNLP Translation API | Translate between local languages and English for reports |
| **Audio Recording** | `record` package | Record audio in WAV/m4a for ASR upload |
| **NLP/Intent Parsing** | Custom Dart parser + regex | Parse transcribed text into structured sale/expense entries |
| **Charts/Reports** | `fl_chart` | Beautiful, customizable charts for sales dashboards |
| **DI** | `riverpod` (built-in) | Provider-based dependency injection |
| **Routing** | `go_router` | Declarative routing, deep linking support |
| **Theming/UI** | Custom Design System + Google Fonts | Warm, accessible, modern Material 3 design |
| **Localization** | `flutter_localizations` + ARB files | Twi, Ga, Fante, English UI strings |
| **Secure Storage** | `flutter_secure_storage` | API keys stored securely on device |
| **PDF Export** | `pdf` + `printing` packages | Generate printable sales reports |

---

## 2. GhanaNLP API Integration

GhanaNLP's Khaya API (hosted on Azure API Management) provides three key endpoints:

### Endpoints
- **ASR (Speech-to-Text)**: `POST /asr` — Send audio file, get transcription in Twi/Ga/Fante
- **Translation**: `POST /translate` — Translate between English ↔ Twi/Ga/Ewe/Fante
- **TTS (Text-to-Speech)**: `POST /tts` — Convert text to speech audio

### Auth
- Sign up at `translation.ghananlp.org` for an API key
- Pass key via `Ocp-Apim-Subscription-Key` header (Azure API Management standard)

### Integration Pattern
1. User taps mic → record audio (WAV, 16kHz mono)
2. Send audio to GhanaNLP ASR → get transcription in local language
3. Parse transcription with intent engine (e.g., "me tɔn brodo GH₵5" → Sale: bread, ₵5.00)
4. Optionally translate to English for reports
5. Confirm back to user via TTS in their language

---

## 3. Architecture (Clean Architecture + Feature-First)

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp, theme, router
│   ├── router.dart                 # GoRouter config
│   └── theme/
│       ├── app_theme.dart          # Material 3 theme data
│       ├── colors.dart             # Brand colors (warm Kente-inspired palette)
│       └── typography.dart         # Google Fonts config
├── core/
│   ├── constants/                  # App-wide constants
│   ├── errors/                     # Failure classes
│   ├── network/                    # HTTP client, interceptors
│   ├── utils/                      # Date, currency formatters
│   └── localization/               # ARB files, l10n setup
├── features/
│   ├── voice_input/
│   │   ├── data/
│   │   │   ├── datasources/        # GhanaNLP ASR API client
│   │   │   └── repositories/       # VoiceInputRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/           # Transcription, VoiceCommand
│   │   │   ├── repositories/       # Abstract VoiceInputRepository
│   │   │   └── usecases/           # TranscribeAudio, ParseCommand
│   │   └── presentation/
│   │       ├── providers/          # Riverpod providers
│   │       ├── widgets/            # MicButton, WaveformVisualizer
│   │       └── screens/            # VoiceInputScreen
│   ├── sales/
│   │   ├── data/                   # Isar models, local datasource
│   │   ├── domain/                 # Sale entity, SalesRepository, usecases
│   │   └── presentation/          # SalesListScreen, AddSaleScreen
│   ├── expenses/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── dashboard/
│   │   ├── domain/                 # Report generation usecases
│   │   └── presentation/          # DashboardScreen with charts
│   ├── settings/
│   │   └── presentation/          # Language picker, API key config
│   └── reports/
│       ├── domain/                 # PDF generation usecase
│       └── presentation/          # ReportsScreen, export options
└── main.dart
```

---

## 4. UI/UX Design Philosophy

### Design Principles
- **Voice-first**: Giant, pulsing mic button as the primary CTA on every key screen
- **Low-literacy friendly**: Minimal text, heavy use of icons, color coding, and audio feedback
- **Offline-ready**: All data stored locally; API calls queued when offline
- **Warm palette**: Kente cloth-inspired colors — gold (#D4A843), deep green (#1B5E20), warm brown (#5D4037), cream (#FFF8E1)
- **Large touch targets**: Minimum 56dp tap areas for market conditions (wet/dusty hands)

### Key Screens

1. **Home / Dashboard**
   - Daily sales total (big number, prominent)
   - Mini chart (last 7 days trend)
   - Giant floating mic button (bottom center)
   - Quick action cards: "Today's Sales", "Expenses", "Reports"
   - Greeting in selected language

2. **Voice Input (Bottom Sheet / Full Screen)**
   - Animated waveform while recording
   - Language selector pill (Twi | Ga | Fante)
   - Live transcription text appearing
   - Parsed result card: "Sale: Bread — GH₵5.00" with confirm/edit/cancel
   - Audio confirmation playback via TTS

3. **Sales List**
   - Grouped by day with daily totals
   - Color-coded categories (food=green, clothing=blue, etc.)
   - Swipe actions: edit, delete
   - Search/filter by date range

4. **Reports / Analytics**
   - Period selector (Today, Week, Month, Custom)
   - Bar chart (daily sales), Pie chart (categories)
   - Profit/Loss summary card
   - Export to PDF button

5. **Settings**
   - Language preference (Twi, Ga, Fante, English)
   - Business name & info
   - API key management
   - Data backup (export JSON)
   - Currency format

### Animations & Micro-interactions
- Mic button: Pulse animation when idle, ripple + waveform when recording
- Sale confirmed: Confetti/checkmark lottie animation
- Number counters: Animated count-up for daily totals
- Page transitions: Shared element transitions for sale cards

---

## 5. Voice Command Intent Parser

A custom Dart-based parser that handles structured and semi-structured voice input:

### Supported Patterns (Twi examples)
| Voice Input | Parsed Result |
|---|---|
| "me tɔn brodo GH₵5" | Sale: bread, ₵5.00 |
| "me tɔn shito bottles mmiɛnsa GH₵30" | Sale: shito × 3, ₵30.00 |
| "me gyee sika GH₵100 fi Ama" | Income: ₵100 from Ama |
| "me tuaa sika GH₵20 ma light" | Expense: electricity, ₵20.00 |

### Parser Strategy
1. Tokenize transcription
2. Identify transaction type keywords (tɔn=sell, gyee=received, tuaa=paid)
3. Extract amounts (regex for GH₵/₵ + number patterns)
4. Extract item names and quantities
5. Return structured `Transaction` object or ask for clarification via TTS

---

## 6. Key Flutter Packages

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  record: ^5.1.0
  http: ^1.2.0
  fl_chart: ^0.68.0
  flutter_secure_storage: ^9.2.0
  google_fonts: ^6.2.0
  pdf: ^3.11.0
  printing: ^5.13.0
  intl: ^0.19.0
  lottie: ^3.1.0
  path_provider: ^2.1.0
  permission_handler: ^11.3.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  isar_generator: ^3.1.0
  build_runner: ^2.4.0
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
```

---

## 7. Implementation Phases

### Phase 1 — Foundation (Week 1-2)
- [ ] Flutter project setup with folder structure
- [ ] Theme system (colors, typography, Material 3)
- [ ] Routing with go_router
- [ ] Riverpod setup
- [ ] Isar DB schema (Sale, Expense, Category models)
- [ ] Localization setup (English + Twi ARB files)

### Phase 2 — Core Voice Input (Week 3-4)
- [ ] Audio recording service (record package)
- [ ] GhanaNLP API client (ASR, TTS, Translation)
- [ ] Voice command intent parser
- [ ] Voice input bottom sheet UI with waveform
- [ ] Confirm/edit parsed transaction flow

### Phase 3 — Bookkeeping Features (Week 5-6)
- [ ] Sales CRUD with Isar
- [ ] Expenses CRUD
- [ ] Category management
- [ ] Sales list screen with grouping & search
- [ ] Edit/delete flows

### Phase 4 — Dashboard & Reports (Week 7-8)
- [ ] Dashboard with summary cards & charts
- [ ] Report generation (daily, weekly, monthly)
- [ ] PDF export
- [ ] Data backup/export as JSON

### Phase 5 — Polish & Launch (Week 9-10)
- [ ] Animations & micro-interactions
- [ ] Offline queue for API calls
- [ ] Error handling & edge cases
- [ ] Testing (unit + widget + integration)
- [ ] App store assets & submission

---

## 8. GhanaNLP API Setup Steps

1. Go to `https://translation.ghananlp.org/signup`
2. Create an account and subscribe to the ASR + TTS + Translation APIs
3. Get your subscription key from the developer portal
4. Store the key securely in the app via `flutter_secure_storage`
5. All API calls use header: `Ocp-Apim-Subscription-Key: <your-key>`
