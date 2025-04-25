import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Utility class for handling permissions
class PermissionHandler {
  /// Checks and requests microphone permission
  static Future<bool> checkMicrophonePermission(BuildContext context) async {
    final SpeechToText speech = SpeechToText();
    bool available = await speech.initialize(
      onStatus: (status) {},
      onError: (error) {
        _showPermissionDialog(context, 'Microphone Permission',
            'This app needs microphone access to enable voice input. Please grant permission in your device settings.');
      },
    );

    if (!available) {
      // Check if it's a permission issue or if speech recognition is not available
      bool permissionStatus = await speech.hasPermission;
      if (!permissionStatus) {
        _showPermissionDialog(context, 'Microphone Permission',
            'This app needs microphone access to enable voice input. Please grant permission in your device settings.');
      }
      return false;
    }

    return true;
  }

  static void _showPermissionDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
