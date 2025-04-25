import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation_turn.g.dart';

/// Enum representing the speaker in a conversation turn
enum Speaker {
  /// The user
  user,
  
  /// The AI
  ai
}

/// Enum representing the input mode for a user turn
enum InputMode {
  /// Text input
  text,
  
  /// Voice input
  voice
}

/// Conversation Turn model representing a single message in a conversation
@JsonSerializable()
class ConversationTurn extends Equatable {
  /// Unique identifier for the turn
  final String turnId;
  
  /// ID of the conversation this turn belongs to
  final String conversationId;
  
  /// Sequential number of this turn in the conversation
  final int turnNumber;
  
  /// When this turn occurred
  final DateTime timestamp;
  
  /// Who is speaking in this turn
  final Speaker speaker;
  
  /// Input mode (only relevant for user turns)
  final InputMode? inputMode;
  
  /// Raw input from the user (before validation)
  final String? userRawInput;
  
  /// Validated text from the user
  final String? userValidatedTranscript;
  
  /// AI's response text
  final String? aiResponseText;
  
  /// IDs of grammar points used correctly
  final List<String>? grammarPointsUsedCorrectlyIds;
  
  /// IDs of vocabulary used correctly
  final List<String>? vocabularyUsedCorrectlyIds;
  
  /// Errors identified in this turn
  final List<Map<String, dynamic>>? identifiedErrors;
  
  /// Change in score resulting from this turn
  final int? scoreChange;
  
  /// ID of a new word flagged in this turn
  final String? flaggedNewWordId;

  /// Creates a new [ConversationTurn] instance
  const ConversationTurn({
    required this.turnId,
    required this.conversationId,
    required this.turnNumber,
    required this.timestamp,
    required this.speaker,
    this.inputMode,
    this.userRawInput,
    this.userValidatedTranscript,
    this.aiResponseText,
    this.grammarPointsUsedCorrectlyIds,
    this.vocabularyUsedCorrectlyIds,
    this.identifiedErrors,
    this.scoreChange,
    this.flaggedNewWordId,
  });

  /// Creates a [ConversationTurn] from a JSON map
  factory ConversationTurn.fromJson(Map<String, dynamic> json) => _$ConversationTurnFromJson(json);

  /// Converts this [ConversationTurn] to a JSON map
  Map<String, dynamic> toJson() => _$ConversationTurnToJson(this);

  @override
  List<Object?> get props => [
        turnId,
        conversationId,
        turnNumber,
        timestamp,
        speaker,
        inputMode,
        userRawInput,
        userValidatedTranscript,
        aiResponseText,
        grammarPointsUsedCorrectlyIds,
        vocabularyUsedCorrectlyIds,
        identifiedErrors,
        scoreChange,
        flaggedNewWordId,
      ];
}
