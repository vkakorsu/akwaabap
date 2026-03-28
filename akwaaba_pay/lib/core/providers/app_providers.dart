import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../network/ghana_nlp_client.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// API key provider
final apiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.read(secureStorageProvider);
  return storage.read(key: AppConstants.apiKeyStorageKey);
});

// GhanaNLP client provider
final ghanaNlpClientProvider = FutureProvider<GhanaNlpClient?>((ref) async {
  final apiKey = await ref.watch(apiKeyProvider.future);
  if (apiKey == null || apiKey.isEmpty) return null;
  return GhanaNlpClient(apiKey: apiKey);
});

// Selected language provider (Riverpod 3.x Notifier)
class SelectedLanguageNotifier extends Notifier<String> {
  @override
  String build() => AppConstants.twi;

  void set(String language) {
    state = language;
  }
}

final selectedLanguageProvider =
    NotifierProvider<SelectedLanguageNotifier, String>(
        SelectedLanguageNotifier.new);

// Business name provider
final businessNameProvider = FutureProvider<String>((ref) async {
  final storage = ref.read(secureStorageProvider);
  return await storage.read(key: AppConstants.businessNameKey) ?? 'My Business';
});
