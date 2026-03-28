import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GhanaNlpClient {
  final String apiKey;
  final http.Client _httpClient;

  GhanaNlpClient({required this.apiKey, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Transcribe audio file to text using GhanaNLP ASR
  Future<String> transcribeAudio({
    required String audioFilePath,
    required String language,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.asrBaseUrl}${AppConstants.asrEndpoint}',
      ).replace(queryParameters: {'language': language});

      // Read audio file as bytes
      final file = File(audioFilePath);
      final bytes = await file.readAsBytes();

      final response = await _httpClient.post(
        uri,
        headers: {
          AppConstants.apiKeyHeader: apiKey,
          'Content-Type': 'audio/wav',
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        // Return raw response body (API returns plain text)
        return response.body.trim();
      } else {
        throw GhanaNlpException(
          'ASR failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is GhanaNlpException) rethrow;
      throw GhanaNlpException('ASR request failed: $e');
    }
  }

  /// Translate text between languages
  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.translateBaseUrl}${AppConstants.translateEndpoint}',
      );
      final response = await _httpClient.post(
        uri,
        headers: {
          AppConstants.apiKeyHeader: apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'in': text, 'lang': '$from-$to'}),
      );

      if (response.statusCode == 200) {
        // API returns plain string or JSON
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('json')) {
          final body = jsonDecode(response.body);
          return body['text'] ?? body['translation'] ?? response.body;
        }
        return response.body; // Plain text translation
      } else {
        throw GhanaNlpException(
          'Translation failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is GhanaNlpException) rethrow;
      throw GhanaNlpException('Translation request failed: $e');
    }
  }

  /// Convert text to speech
  Future<Uint8List> textToSpeech({
    required String text,
    required String language,
    String? speakerId,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.ttsBaseUrl}${AppConstants.ttsEndpoint}',
      );
      final response = await _httpClient.post(
        uri,
        headers: {
          AppConstants.apiKeyHeader: apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'language': language,
          'speaker_id': speakerId ?? '${language}_speaker_4',
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw GhanaNlpException(
          'TTS failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is GhanaNlpException) rethrow;
      throw GhanaNlpException('TTS request failed: $e');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class GhanaNlpException implements Exception {
  final String message;
  GhanaNlpException(this.message);

  @override
  String toString() => 'GhanaNlpException: $message';
}
