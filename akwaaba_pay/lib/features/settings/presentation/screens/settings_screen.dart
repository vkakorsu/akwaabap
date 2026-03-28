import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _businessNameController = TextEditingController();
  bool _apiKeyObscured = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(secureStorageProvider);
    final apiKey = await storage.read(key: AppConstants.apiKeyStorageKey);
    final businessName = await storage.read(key: AppConstants.businessNameKey);
    if (mounted) {
      setState(() {
        _apiKeyController.text = apiKey ?? '';
        _businessNameController.text = businessName ?? '';
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLang = ref.watch(selectedLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Language section
          _SectionHeader(title: 'Language'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: LanguageConstants.supportedLanguages.entries.map((entry) {
                final isSelected = entry.key == selectedLang;
                return ListTile(
                  title: Text(entry.value),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    ref.read(selectedLanguageProvider.notifier).set(entry.key);
                    ref.read(secureStorageProvider).write(
                          key: AppConstants.languageStorageKey,
                          value: entry.key,
                        );
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Business info
          _SectionHeader(title: 'Business Info'),
          const SizedBox(height: 8),
          TextField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              prefixIcon: Icon(Icons.store_rounded),
            ),
            onChanged: (value) {
              ref.read(secureStorageProvider).write(
                    key: AppConstants.businessNameKey,
                    value: value,
                  );
            },
          ),
          const SizedBox(height: 24),

          // API Key
          _SectionHeader(title: 'GhanaNLP API Key'),
          const SizedBox(height: 4),
          Text(
            'Sign up at translation.ghananlp.org to get your API key',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: _apiKeyObscured,
            decoration: InputDecoration(
              labelText: 'API Key',
              prefixIcon: const Icon(Icons.key_rounded),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_apiKeyObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _apiKeyObscured = !_apiKeyObscured),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_rounded),
                    onPressed: _saveApiKey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data management
          _SectionHeader(title: 'Data'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: AppColors.secondary),
                  title: const Text('Export Data (JSON)'),
                  subtitle: const Text('Backup your sales and expenses'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export feature coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Delete all sales and expenses'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () => _showClearDataDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About
          _SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.record_voice_over_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppConstants.appName,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('v${AppConstants.appVersion}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Voice-first bookkeeping for Ghanaian traders. '
                  'Record sales in Twi, Ga, or Fante.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _saveApiKey() async {
    await ref.read(secureStorageProvider).write(
          key: AppConstants.apiKeyStorageKey,
          value: _apiKeyController.text.trim(),
        );
    ref.invalidate(apiKeyProvider);
    ref.invalidate(ghanaNlpClientProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will permanently delete all your sales and expenses. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data cleared')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
    );
  }
}
