// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_mastery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMasteryGrammar _$UserMasteryGrammarFromJson(Map<String, dynamic> json) =>
    UserMasteryGrammar(
      userId: json['userId'] as String,
      grammarPointId: json['grammarPointId'] as String,
      masteryScore: (json['masteryScore'] as num).toDouble(),
      correctStreak: (json['correctStreak'] as num).toInt(),
      timesEncountered: (json['timesEncountered'] as num).toInt(),
      timesCorrect: (json['timesCorrect'] as num).toInt(),
      lastPracticedAt:
          json['lastPracticedAt'] == null
              ? null
              : DateTime.parse(json['lastPracticedAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );

Map<String, dynamic> _$UserMasteryGrammarToJson(UserMasteryGrammar instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'masteryScore': instance.masteryScore,
      'correctStreak': instance.correctStreak,
      'timesEncountered': instance.timesEncountered,
      'timesCorrect': instance.timesCorrect,
      'lastPracticedAt': instance.lastPracticedAt?.toIso8601String(),
      'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
      'grammarPointId': instance.grammarPointId,
    };

UserMasteryVocabulary _$UserMasteryVocabularyFromJson(
  Map<String, dynamic> json,
) => UserMasteryVocabulary(
  userId: json['userId'] as String,
  vocabularyId: json['vocabularyId'] as String,
  masteryScore: (json['masteryScore'] as num).toDouble(),
  correctStreak: (json['correctStreak'] as num).toInt(),
  timesEncountered: (json['timesEncountered'] as num).toInt(),
  timesCorrect: (json['timesCorrect'] as num).toInt(),
  lastPracticedAt:
      json['lastPracticedAt'] == null
          ? null
          : DateTime.parse(json['lastPracticedAt'] as String),
  lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
);

Map<String, dynamic> _$UserMasteryVocabularyToJson(
  UserMasteryVocabulary instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'masteryScore': instance.masteryScore,
  'correctStreak': instance.correctStreak,
  'timesEncountered': instance.timesEncountered,
  'timesCorrect': instance.timesCorrect,
  'lastPracticedAt': instance.lastPracticedAt?.toIso8601String(),
  'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
  'vocabularyId': instance.vocabularyId,
};
