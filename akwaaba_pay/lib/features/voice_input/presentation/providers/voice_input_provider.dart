import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/services/audio_recording_service.dart';
import '../../domain/entities/voice_command.dart';
import '../../domain/services/voice_command_parser.dart';

enum VoiceInputState { idle, recording, processing, parsed, error }

class VoiceInputNotifier extends Notifier<VoiceInputData> {
  final AudioRecordingService _recorder = AudioRecordingService();
  final VoiceCommandParser _parser = VoiceCommandParser();

  @override
  VoiceInputData build() => VoiceInputData.initial();

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      state = state.copyWith(
        inputState: VoiceInputState.error,
        errorMessage: 'Microphone permission denied',
      );
      return;
    }

    await _recorder.startRecording();
    state = state.copyWith(inputState: VoiceInputState.recording);
  }

  Future<void> stopRecordingAndProcess() async {
    state = state.copyWith(inputState: VoiceInputState.processing);

    try {
      final path = await _recorder.stopRecording();
      if (path == null) {
        state = state.copyWith(
          inputState: VoiceInputState.error,
          errorMessage: 'No recording found',
        );
        return;
      }

      final client = await ref.read(ghanaNlpClientProvider.future);
      if (client == null) {
        state = state.copyWith(
          inputState: VoiceInputState.error,
          errorMessage: 'Please set your GhanaNLP API key in Settings',
        );
        return;
      }

      final language = ref.read(selectedLanguageProvider);

      final transcription = await client.transcribeAudio(
        audioFilePath: path,
        language: language,
      );

      if (transcription.isEmpty) {
        state = state.copyWith(
          inputState: VoiceInputState.error,
          errorMessage: 'Could not understand the audio. Please try again.',
        );
        return;
      }

      final command = _parser.parse(transcription, language);

      state = state.copyWith(
        inputState: VoiceInputState.parsed,
        transcription: transcription,
        command: command,
      );
    } catch (e) {
      state = state.copyWith(
        inputState: VoiceInputState.error,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void updateCommand(VoiceCommand command) {
    state = state.copyWith(command: command);
  }

  void reset() {
    state = VoiceInputData.initial();
  }
}

class VoiceInputData {
  final VoiceInputState inputState;
  final String? transcription;
  final VoiceCommand? command;
  final String? errorMessage;

  const VoiceInputData({
    required this.inputState,
    this.transcription,
    this.command,
    this.errorMessage,
  });

  factory VoiceInputData.initial() =>
      const VoiceInputData(inputState: VoiceInputState.idle);

  VoiceInputData copyWith({
    VoiceInputState? inputState,
    String? transcription,
    VoiceCommand? command,
    String? errorMessage,
  }) {
    return VoiceInputData(
      inputState: inputState ?? this.inputState,
      transcription: transcription ?? this.transcription,
      command: command ?? this.command,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final voiceInputProvider =
    NotifierProvider<VoiceInputNotifier, VoiceInputData>(
        VoiceInputNotifier.new);
