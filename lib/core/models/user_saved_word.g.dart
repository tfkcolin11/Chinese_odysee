// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_saved_word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSavedWord _$UserSavedWordFromJson(Map<String, dynamic> json) =>
    UserSavedWord(
      savedWordId: json['savedWordId'] as String,
      userId: json['userId'] as String,
      conversationTurnId: json['conversationTurnId'] as String,
      wordCharacters: json['wordCharacters'] as String,
      wordPinyin: json['wordPinyin'] as String?,
      contextualMeaning: json['contextualMeaning'] as String,
      exampleUsage: json['exampleUsage'] as String,
      sourceHskLevel: (json['sourceHskLevel'] as num?)?.toInt(),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$UserSavedWordToJson(UserSavedWord instance) =>
    <String, dynamic>{
      'savedWordId': instance.savedWordId,
      'userId': instance.userId,
      'conversationTurnId': instance.conversationTurnId,
      'wordCharacters': instance.wordCharacters,
      'wordPinyin': instance.wordPinyin,
      'contextualMeaning': instance.contextualMeaning,
      'exampleUsage': instance.exampleUsage,
      'sourceHskLevel': instance.sourceHskLevel,
      'addedAt': instance.addedAt.toIso8601String(),
    };
