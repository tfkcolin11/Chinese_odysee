// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  conversationId: json['conversationId'] as String,
  userId: json['userId'] as String,
  scenarioId: json['scenarioId'] as String,
  scenarioName: json['scenarioName'] as String,
  hskLevelPlayed: (json['hskLevelPlayed'] as num).toInt(),
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt:
      json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
  currentScore: (json['currentScore'] as num).toInt(),
  finalScore: (json['finalScore'] as num?)?.toInt(),
  outcomeStatus: $enumDecode(
    _$ConversationStatusEnumMap,
    json['outcomeStatus'],
  ),
  aiHiddenGoalDescription: json['aiHiddenGoalDescription'] as String?,
  savedInstanceDetails: json['savedInstanceDetails'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'scenarioId': instance.scenarioId,
      'scenarioName': instance.scenarioName,
      'hskLevelPlayed': instance.hskLevelPlayed,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'currentScore': instance.currentScore,
      'finalScore': instance.finalScore,
      'outcomeStatus': _$ConversationStatusEnumMap[instance.outcomeStatus]!,
      'aiHiddenGoalDescription': instance.aiHiddenGoalDescription,
      'savedInstanceDetails': instance.savedInstanceDetails,
    };

const _$ConversationStatusEnumMap = {
  ConversationStatus.pending: 'pending',
  ConversationStatus.achieved: 'achieved',
  ConversationStatus.failed: 'failed',
  ConversationStatus.abandoned: 'abandoned',
};
