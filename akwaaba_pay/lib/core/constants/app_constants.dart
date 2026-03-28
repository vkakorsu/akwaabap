class AppConstants {
  AppConstants._();

  static const String appName = 'AkwaabaPay';
  static const String appVersion = '1.0.0';

  // GhanaNLP API - each service has different base URL per OpenAPI specs
  static const String asrBaseUrl =
      'https://translation-api.ghananlp.org/asr/v1';
  static const String ttsBaseUrl =
      'https://translation-api.ghananlp.org/tts/v1';
  static const String translateBaseUrl =
      'https://translation-api.ghananlp.org/v1';

  static const String asrEndpoint = '/transcribe';
  static const String ttsEndpoint = '/synthesize';
  static const String translateEndpoint = '/translate';

  // API Header
  static const String apiKeyHeader = 'Ocp-Apim-Subscription-Key';

  // Supported languages
  static const String twi = 'tw';
  static const String ga = 'gaa';
  static const String fante = 'fat';
  static const String english = 'en';

  // Currency
  static const String currencySymbol = 'GH₵';
  static const String currencyCode = 'GHS';

  // Audio settings
  static const int sampleRate = 16000;
  static const int audioChannels = 1;

  // Secure storage keys
  static const String apiKeyStorageKey = 'ghana_nlp_api_key';
  static const String languageStorageKey = 'preferred_language';
  static const String businessNameKey = 'business_name';
  static const String onboardingCompleteKey = 'onboarding_complete';
}
