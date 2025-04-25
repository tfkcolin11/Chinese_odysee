// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_turn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationTurn _$ConversationTurnFromJson(Map<String, dynamic> json) =>
    ConversationTurn(
      turnId: json['turnId'] as String,
      conversationId: json['conversationId'] as String,
      turnNumber: (json['turnNumber'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      speaker: $enumDecode(_$SpeakerEnumMap, json['speaker']),
      inputMode: $enumDecodeNullable(_$InputModeEnumMap, json['inputMode']),
      userRawInput: json['userRawInput'] as String?,
      userValidatedTranscript: json['userValidatedTranscript'] as String?,
      aiResponseText: json['aiResponseText'] as String?,
      grammarPointsUsedCorrectlyIds:
          (json['grammarPointsUsedCorrectlyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      vocabularyUsedCorrectlyIds:
          (json['vocabularyUsedCorrectlyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      identifiedErrors:
          (json['identifiedErrors'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
      scoreChange: (json['scoreChange'] as num?)?.toInt(),
      flaggedNewWordId: json['flaggedNewWordId'] as String?,
    );

Map<String, dynamic> _$ConversationTurnToJson(ConversationTurn instance) =>
    <String, dynamic>{
      'turnId': instance.turnId,
      'conversationId': instance.conversationId,
      'turnNumber': instance.turnNumber,
      'timestamp': instance.timestamp.toIso8601String(),
      'speaker': _$SpeakerEnumMap[instance.speaker]!,
      'inputMode': _$InputModeEnumMap[instance.inputMode],
      'userRawInput': instance.userRawInput,
      'userValidatedTranscript': instance.userValidatedTranscript,
      'aiResponseText': instance.aiResponseText,
      'grammarPointsUsedCorrectlyIds': instance.grammarPointsUsedCorrectlyIds,
      'vocabularyUsedCorrectlyIds': instance.vocabularyUsedCorrectlyIds,
      'identifiedErrors': instance.identifiedErrors,
      'scoreChange': instance.scoreChange,
      'flaggedNewWordId': instance.flaggedNewWordId,
    };

const _$SpeakerEnumMap = {Speaker.user: 'user', Speaker.ai: 'ai'};

const _$InputModeEnumMap = {InputMode.text: 'text', InputMode.voice: 'voice'};
