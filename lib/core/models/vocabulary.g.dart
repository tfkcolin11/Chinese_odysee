// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vocabulary _$VocabularyFromJson(Map<String, dynamic> json) => Vocabulary(
  vocabularyId: json['vocabularyId'] as String,
  hskLevelId: (json['hskLevelId'] as num).toInt(),
  characters: json['characters'] as String,
  pinyin: json['pinyin'] as String,
  englishTranslation: json['englishTranslation'] as String,
  partOfSpeech: json['partOfSpeech'] as String?,
  audioPronunciationUrl: json['audioPronunciationUrl'] as String?,
);

Map<String, dynamic> _$VocabularyToJson(Vocabulary instance) =>
    <String, dynamic>{
      'vocabularyId': instance.vocabularyId,
      'hskLevelId': instance.hskLevelId,
      'characters': instance.characters,
      'pinyin': instance.pinyin,
      'englishTranslation': instance.englishTranslation,
      'partOfSpeech': instance.partOfSpeech,
      'audioPronunciationUrl': instance.audioPronunciationUrl,
    };
