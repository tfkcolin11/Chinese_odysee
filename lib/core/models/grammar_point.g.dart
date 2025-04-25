// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrammarPoint _$GrammarPointFromJson(Map<String, dynamic> json) => GrammarPoint(
  grammarPointId: json['grammarPointId'] as String,
  hskLevelId: (json['hskLevelId'] as num).toInt(),
  name: json['name'] as String,
  descriptionHtml: json['descriptionHtml'] as String?,
  exampleSentenceChinese: json['exampleSentenceChinese'] as String?,
  exampleSentencePinyin: json['exampleSentencePinyin'] as String?,
  exampleSentenceTranslation: json['exampleSentenceTranslation'] as String?,
);

Map<String, dynamic> _$GrammarPointToJson(GrammarPoint instance) =>
    <String, dynamic>{
      'grammarPointId': instance.grammarPointId,
      'hskLevelId': instance.hskLevelId,
      'name': instance.name,
      'descriptionHtml': instance.descriptionHtml,
      'exampleSentenceChinese': instance.exampleSentenceChinese,
      'exampleSentencePinyin': instance.exampleSentencePinyin,
      'exampleSentenceTranslation': instance.exampleSentenceTranslation,
    };
