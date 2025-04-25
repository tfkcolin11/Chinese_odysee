import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation.g.dart';

/// Enum representing the status of a conversation
enum ConversationStatus {
  /// Conversation is still in progress
  pending,
  
  /// Conversation goal was achieved
  achieved,
  
  /// Conversation goal was not achieved
  failed,
  
  /// Conversation was abandoned
  abandoned
}

/// Conversation model representing a game session
@JsonSerializable()
class Conversation extends Equatable {
  /// Unique identifier for the conversation
  final String conversationId;
  
  /// ID of the user participating in the conversation
  final String userId;
  
  /// ID of the scenario being used
  final String scenarioId;
  
  /// Name of the scenario (denormalized for convenience)
  final String scenarioName;
  
  /// HSK level selected for this conversation
  final int hskLevelPlayed;
  
  /// When the conversation started
  final DateTime startedAt;
  
  /// When the conversation ended (optional)
  final DateTime? endedAt;
  
  /// Current score in the conversation
  final int currentScore;
  
  /// Final score (optional, only set when conversation ends)
  final int? finalScore;
  
  /// Status of the conversation
  final ConversationStatus outcomeStatus;
  
  /// Hidden goal description (internal to the AI)
  final String? aiHiddenGoalDescription;
  
  /// Details for saved instances (optional)
  final Map<String, dynamic>? savedInstanceDetails;

  /// Creates a new [Conversation] instance
  const Conversation({
    required this.conversationId,
    required this.userId,
    required this.scenarioId,
    required this.scenarioName,
    required this.hskLevelPlayed,
    required this.startedAt,
    this.endedAt,
    required this.currentScore,
    this.finalScore,
    required this.outcomeStatus,
    this.aiHiddenGoalDescription,
    this.savedInstanceDetails,
  });

  /// Creates a [Conversation] from a JSON map
  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  /// Converts this [Conversation] to a JSON map
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  /// Creates a copy of this [Conversation] with the given fields replaced
  Conversation copyWith({
    String? conversationId,
    String? userId,
    String? scenarioId,
    String? scenarioName,
    int? hskLevelPlayed,
    DateTime? startedAt,
    DateTime? endedAt,
    int? currentScore,
    int? finalScore,
    ConversationStatus? outcomeStatus,
    String? aiHiddenGoalDescription,
    Map<String, dynamic>? savedInstanceDetails,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      scenarioId: scenarioId ?? this.scenarioId,
      scenarioName: scenarioName ?? this.scenarioName,
      hskLevelPlayed: hskLevelPlayed ?? this.hskLevelPlayed,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      currentScore: currentScore ?? this.currentScore,
      finalScore: finalScore ?? this.finalScore,
      outcomeStatus: outcomeStatus ?? this.outcomeStatus,
      aiHiddenGoalDescription: aiHiddenGoalDescription ?? this.aiHiddenGoalDescription,
      savedInstanceDetails: savedInstanceDetails ?? this.savedInstanceDetails,
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        userId,
        scenarioId,
        scenarioName,
        hskLevelPlayed,
        startedAt,
        endedAt,
        currentScore,
        finalScore,
        outcomeStatus,
        aiHiddenGoalDescription,
        savedInstanceDetails,
      ];
}
