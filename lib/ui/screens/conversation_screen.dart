import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';
import 'package:chinese_odysee/utils/logger.dart';
import 'package:chinese_odysee/utils/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Screen for the conversation with the AI
class ConversationScreen extends ConsumerStatefulWidget {
  /// The initial AI turn
  final ConversationTurn initialTurn;

  /// The selected HSK level
  final HskLevel hskLevel;

  /// The selected scenario
  final Scenario scenario;

  /// Creates a new [ConversationScreen] instance
  const ConversationScreen({
    super.key,
    required this.initialTurn,
    required this.hskLevel,
    required this.scenario,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ConversationTurn> _turns = [];
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isSending = false;
  bool _ttsEnabled = true;
  InputMode _inputMode = InputMode.text;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _turns.add(widget.initialTurn);
    _initializeTts();
    _initializeSpeech();

    // Speak the initial AI message
    if (_ttsEnabled) {
      _speakText(widget.initialTurn.aiResponseText ?? '');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Add error listener
      _flutterTts.setErrorHandler((error) {
        Logger.error('TTS Error', error);
        // Disable TTS if there's an error
        setState(() {
          _ttsEnabled = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Text-to-speech is not available. It has been disabled.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    } catch (e) {
      Logger.error('Failed to initialize TTS', e);
      setState(() {
        _ttsEnabled = false;
      });
    }
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }

  Future<void> _speakText(String text) async {
    if (_ttsEnabled) {
      try {
        await _flutterTts.speak(text);
      } catch (e) {
        // If there's an error, disable TTS
        setState(() {
          _ttsEnabled = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to use text-to-speech: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      try {
        // Check microphone permission first
        bool permissionGranted = await PermissionHandler.checkMicrophonePermission(context);
        if (!permissionGranted) {
          // If permission not granted, switch to text input
          setState(() {
            _inputMode = InputMode.text;
          });
          return;
        }

        bool available = await _speech.initialize();
        if (available) {
          setState(() {
            _isListening = true;
            _recognizedText = '';
          });

          _speech.listen(
            onResult: (result) {
              setState(() {
                _recognizedText = result.recognizedWords;
              });
            },
            localeId: 'zh-CN',
          );

          // Add error listener
          _speech.errorListener = (error) {
            _handleSpeechError(error.errorMsg);
          };
        } else {
          Logger.warning('Speech recognition not available on this device');
          _handleSpeechError('Speech recognition not available on this device');
        }
      } catch (e) {
        Logger.error('Error initializing speech recognition', e);
        _handleSpeechError('Error initializing speech recognition: $e');
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();

      // Show dialog to confirm the recognized text
      if (_recognizedText.isNotEmpty) {
        _showRecognizedTextDialog();
      }
    }
  }

  void _handleSpeechError(String errorMessage) {
    Logger.error('Speech recognition error', errorMessage);

    setState(() {
      _isListening = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speech recognition error: $errorMessage'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Switch to Text',
            onPressed: () {
              setState(() {
                _inputMode = InputMode.text;
              });
            },
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  void _showRecognizedTextDialog() {
    final textController = TextEditingController(text: _recognizedText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Your Input'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please review and edit your input if necessary:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendMessage(textController.text, InputMode.voice);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text, InputMode mode) async {
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Create a user turn
      final userTurn = ConversationTurn(
        turnId: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: '',
        turnNumber: _turns.length,
        timestamp: DateTime.now(),
        speaker: Speaker.user,
        inputMode: mode,
        userValidatedTranscript: text,
      );

      // Add the user turn to the list
      setState(() {
        _turns.add(userTurn);
      });

      // Clear the text field
      _textController.clear();

      // Scroll to the bottom
      _scrollToBottom();

      // Submit the user turn to the API
      final conversationNotifier = ref.read(activeConversationProvider.notifier);
      final result = await conversationNotifier.submitUserTurn(
        inputText: text,
        inputMode: mode,
      );

      // Get the AI turn from the result
      final aiTurn = result['aiTurn'] as ConversationTurn;

      // Add the AI turn to the list
      setState(() {
        _turns.add(aiTurn);
        _isSending = false;
      });

      // Scroll to the bottom
      _scrollToBottom();

      // Speak the AI response
      if (_ttsEnabled) {
        _speakText(aiTurn.aiResponseText ?? '');
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(activeConversationProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.scenario.name,
        actions: [
          // TTS toggle button
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                _ttsEnabled = !_ttsEnabled;
              });

              if (!_ttsEnabled) {
                _flutterTts.stop();
              }
            },
            tooltip: _ttsEnabled ? 'Disable TTS' : 'Enable TTS',
          ),
          // End conversation button
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _showEndConversationDialog,
            tooltip: 'End Conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Conversation info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'HSK Level: ${widget.hskLevel.name}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (conversation.hasValue && conversation.value != null)
                  Text(
                    'Score: ${conversation.value!.currentScore}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Conversation messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _turns.length,
              itemBuilder: (context, index) {
                final turn = _turns[index];
                return _buildMessageBubble(turn);
              },
            ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ConversationTurn turn) {
    final isUser = turn.speaker == Speaker.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser
                  ? turn.userValidatedTranscript ?? ''
                  : turn.aiResponseText ?? '',
              style: TextStyle(
                color: isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUser
                  ? 'You (${turn.inputMode?.name ?? 'text'})'
                  : 'AI',
              style: TextStyle(
                fontSize: 12,
                color: isUser
                    ? Theme.of(context).colorScheme.onPrimary.withAlpha(179) // ~0.7 opacity
                    : Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(179), // ~0.7 opacity
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // ~0.1 opacity
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Input mode toggle button
          IconButton(
            icon: Icon(_inputMode == InputMode.text
                ? Icons.keyboard
                : Icons.mic),
            onPressed: () {
              setState(() {
                _inputMode = _inputMode == InputMode.text
                    ? InputMode.voice
                    : InputMode.text;
              });
            },
            tooltip: _inputMode == InputMode.text
                ? 'Switch to Voice Input'
                : 'Switch to Text Input',
          ),

          // Text input field (visible in text mode)
          if (_inputMode == InputMode.text)
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (text) => _sendMessage(text, InputMode.text),
              ),
            ),

          // Voice input button (visible in voice mode)
          if (_inputMode == InputMode.voice)
            Expanded(
              child: GestureDetector(
                onTap: _listen,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isListening
                          ? Colors.red
                          : Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isListening
                              ? _recognizedText.isEmpty
                                  ? 'Listening...'
                                  : _recognizedText
                              : 'Tap to speak',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Send button (visible in text mode)
          if (_inputMode == InputMode.text)
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _isSending
                  ? null
                  : () => _sendMessage(_textController.text, InputMode.text),
            ),
        ],
      ),
    );
  }

  void _showEndConversationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Conversation'),
        content: const Text(
          'Are you sure you want to end this conversation? '
          'You can save it before ending.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSaveConversationDialog();
            },
            child: const Text('Save & End'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endConversation(save: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Without Saving'),
          ),
        ],
      ),
    );
  }

  void _showSaveConversationDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Give this conversation a name to help you remember it:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Conversation Name',
                hintText: 'e.g., Restaurant Practice 1',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endConversation(
                save: true,
                savedInstanceName: nameController.text,
              );
            },
            child: const Text('Save & End'),
          ),
        ],
      ),
    );
  }

  Future<void> _endConversation({
    required bool save,
    String? savedInstanceName,
  }) async {
    try {
      final conversationNotifier = ref.read(activeConversationProvider.notifier);

      // Save the conversation if requested
      if (save && savedInstanceName != null) {
        await conversationNotifier.saveConversation(
          savedInstanceName: savedInstanceName,
        );
      }

      // End the conversation
      await conversationNotifier.endConversation();

      // Navigate back to the scenario selection screen
      if (mounted) {
        Navigator.popUntil(
          context,
          (route) => route.isFirst || route.settings.name == '/scenario_selection',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end conversation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
