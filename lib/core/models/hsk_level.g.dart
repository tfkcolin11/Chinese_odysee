// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hsk_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HskLevel _$HskLevelFromJson(Map<String, dynamic> json) => HskLevel(
  hskLevelId: (json['hskLevelId'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$HskLevelToJson(HskLevel instance) => <String, dynamic>{
  'hskLevelId': instance.hskLevelId,
  'name': instance.name,
  'description': instance.description,
};
