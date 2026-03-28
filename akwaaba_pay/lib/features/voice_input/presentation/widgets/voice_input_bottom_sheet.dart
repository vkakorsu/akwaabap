import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/voice_command.dart';
import '../providers/voice_input_provider.dart';
import 'mic_button.dart';

class VoiceInputBottomSheet extends ConsumerWidget {
  final void Function(VoiceCommand command) onConfirm;

  const VoiceInputBottomSheet({super.key, required this.onConfirm});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required void Function(VoiceCommand command) onConfirm,
  }) async {
    ref.read(voiceInputProvider.notifier).reset();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceInputBottomSheet(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceData = ref.watch(voiceInputProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _getTitle(voiceData.inputState),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          // Language selector pills
          _LanguageSelector(
            selected: selectedLang,
            onChanged: (lang) =>
                ref.read(selectedLanguageProvider.notifier).set(lang),
          ),
          const SizedBox(height: 24),
          // Main content based on state
          Flexible(
            child: SingleChildScrollView(
              child: _buildContent(context, ref, voiceData),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getTitle(VoiceInputState state) {
    switch (state) {
      case VoiceInputState.idle:
        return 'Tap to speak';
      case VoiceInputState.recording:
        return 'Listening...';
      case VoiceInputState.processing:
        return 'Processing...';
      case VoiceInputState.parsed:
        return 'Confirm transaction';
      case VoiceInputState.error:
        return 'Something went wrong';
    }
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    VoiceInputData data,
  ) {
    switch (data.inputState) {
      case VoiceInputState.idle:
      case VoiceInputState.recording:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.inputState == VoiceInputState.recording)
              _WaveformIndicator(),
            const SizedBox(height: 24),
            MicButton(
              isRecording: data.inputState == VoiceInputState.recording,
              onTap: () {
                if (data.inputState == VoiceInputState.idle) {
                  ref.read(voiceInputProvider.notifier).startRecording();
                } else {
                  ref
                      .read(voiceInputProvider.notifier)
                      .stopRecordingAndProcess();
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              data.inputState == VoiceInputState.recording
                  ? 'Tap to stop'
                  : 'Say something like:\n"me tɔn brodo GH₵5"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );

      case VoiceInputState.processing:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Transcribing your voice...'),
          ],
        );

      case VoiceInputState.parsed:
        return _ParsedResultCard(
          data: data,
          onConfirm: (command) {
            onConfirm(command);
            Navigator.of(context).pop();
          },
          onRetry: () => ref.read(voiceInputProvider.notifier).reset(),
          onEdit: (command) =>
              ref.read(voiceInputProvider.notifier).updateCommand(command),
        );

      case VoiceInputState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                data.errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(voiceInputProvider.notifier).reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        );
    }
  }
}

class _LanguageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: LanguageConstants.supportedLanguages.entries.map((entry) {
        final isSelected = entry.key == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (_) => onChanged(entry.key),
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: isSelected
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WaveformIndicator extends StatefulWidget {
  @override
  State<_WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<_WaveformIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final offset = (index - 3).abs() / 3;
            final height = 12.0 + (28.0 * (1 - offset) * _controller.value);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(
                  alpha: 0.6 + 0.4 * _controller.value,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ParsedResultCard extends StatelessWidget {
  final VoiceInputData data;
  final void Function(VoiceCommand) onConfirm;
  final VoidCallback onRetry;
  final void Function(VoiceCommand) onEdit;

  const _ParsedResultCard({
    required this.data,
    required this.onConfirm,
    required this.onRetry,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final command = data.command!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Transcription
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You said:',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  data.transcription ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Parsed result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: command.isValid
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.warning.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: command.type == TransactionType.sale
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        command.displayType,
                        style: TextStyle(
                          color: command.type == TransactionType.sale
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (command.amount != null)
                      Text(
                        CurrencyFormatter.format(command.amount!),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                  ],
                ),
                if (command.itemName != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${command.itemName}${command.quantity > 1 ? ' × ${command.quantity}' : ''}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
                if (command.personName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        command.personName!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.mic, size: 18),
                  label: const Text('Retry'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: command.isValid ? () => onConfirm(command) : null,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
