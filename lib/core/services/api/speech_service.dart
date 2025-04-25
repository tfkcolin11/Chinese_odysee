import 'dart:convert';
import 'dart:typed_data';

import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Service for speech-related API operations
class SpeechService {
  /// API service for making HTTP requests
  final ApiService _apiService;

  /// Creates a new [SpeechService] instance
  SpeechService(this._apiService);

  /// Converts speech to text
  Future<Map<String, dynamic>> speechToText({
    required Uint8List audioData,
    required String languageCode,
  }) async {
    try {
      final response = await _apiService.post(
        '/stt',
        data: {
          'audioContent': base64Encode(audioData),
          'languageCode': languageCode,
        },
      );
      
      return {
        'transcript': response.data['transcript'],
        'confidence': response.data['confidence'],
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Converts text to speech
  Future<String> textToSpeech({
    required String text,
    required String languageCode,
    String? voiceName,
  }) async {
    try {
      final data = {
        'text': text,
        'languageCode': languageCode,
      };
      
      if (voiceName != null) {
        data['voiceName'] = voiceName;
      }
      
      final response = await _apiService.post('/tts', data: data);
      return response.data['audioUrl'];
    } catch (e) {
      rethrow;
    }
  }
}
