import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grammar_point.g.dart';

/// Grammar Point model representing a Chinese grammar concept
@JsonSerializable()
class GrammarPoint extends Equatable {
  /// Unique identifier for the grammar point
  final String grammarPointId;
  
  /// HSK level this grammar point belongs to
  final int hskLevelId;
  
  /// Name of the grammar point
  final String name;
  
  /// HTML description of the grammar point (optional)
  final String? descriptionHtml;
  
  /// Example sentence in Chinese (optional)
  final String? exampleSentenceChinese;
  
  /// Example sentence in Pinyin (optional)
  final String? exampleSentencePinyin;
  
  /// Example sentence translation (optional)
  final String? exampleSentenceTranslation;

  /// Creates a new [GrammarPoint] instance
  const GrammarPoint({
    required this.grammarPointId,
    required this.hskLevelId,
    required this.name,
    this.descriptionHtml,
    this.exampleSentenceChinese,
    this.exampleSentencePinyin,
    this.exampleSentenceTranslation,
  });

  /// Creates a [GrammarPoint] from a JSON map
  factory GrammarPoint.fromJson(Map<String, dynamic> json) => _$GrammarPointFromJson(json);

  /// Converts this [GrammarPoint] to a JSON map
  Map<String, dynamic> toJson() => _$GrammarPointToJson(this);

  @override
  List<Object?> get props => [
        grammarPointId,
        hskLevelId,
        name,
        descriptionHtml,
        exampleSentenceChinese,
        exampleSentencePinyin,
        exampleSentenceTranslation,
      ];
}
