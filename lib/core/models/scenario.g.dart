// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scenario _$ScenarioFromJson(Map<String, dynamic> json) => Scenario(
  scenarioId: json['scenarioId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  isPredefined: json['isPredefined'] as bool,
  suggestedHskLevel: (json['suggestedHskLevel'] as num?)?.toInt(),
  createdByUserId: json['createdByUserId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUsedAt:
      json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
);

Map<String, dynamic> _$ScenarioToJson(Scenario instance) => <String, dynamic>{
  'scenarioId': instance.scenarioId,
  'name': instance.name,
  'description': instance.description,
  'isPredefined': instance.isPredefined,
  'suggestedHskLevel': instance.suggestedHskLevel,
  'createdByUserId': instance.createdByUserId,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
};
