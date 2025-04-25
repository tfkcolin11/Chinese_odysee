import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vocabulary.g.dart';

/// Vocabulary model representing a Chinese word or phrase
@JsonSerializable()
class Vocabulary extends Equatable {
  /// Unique identifier for the vocabulary item
  final String vocabularyId;
  
  /// HSK level this vocabulary item belongs to
  final int hskLevelId;
  
  /// Chinese characters for the vocabulary item
  final String characters;
  
  /// Pinyin pronunciation
  final String pinyin;
  
  /// English translation
  final String englishTranslation;
  
  /// Part of speech (optional)
  final String? partOfSpeech;
  
  /// URL to audio pronunciation (optional)
  final String? audioPronunciationUrl;

  /// Creates a new [Vocabulary] instance
  const Vocabulary({
    required this.vocabularyId,
    required this.hskLevelId,
    required this.characters,
    required this.pinyin,
    required this.englishTranslation,
    this.partOfSpeech,
    this.audioPronunciationUrl,
  });

  /// Creates a [Vocabulary] from a JSON map
  factory Vocabulary.fromJson(Map<String, dynamic> json) => _$VocabularyFromJson(json);

  /// Converts this [Vocabulary] to a JSON map
  Map<String, dynamic> toJson() => _$VocabularyToJson(this);

  @override
  List<Object?> get props => [
        vocabularyId,
        hskLevelId,
        characters,
        pinyin,
        englishTranslation,
        partOfSpeech,
        audioPronunciationUrl,
      ];
}
