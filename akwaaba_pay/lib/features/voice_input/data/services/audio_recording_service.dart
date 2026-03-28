import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      _currentPath =
          '${dir.path}/voice_recording_${DateTime.now().millisecondsSinceEpoch}.mp3';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentPath!,
      );
    }
  }

  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      final path = await _recorder.stop();
      return path;
    }
    return null;
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
