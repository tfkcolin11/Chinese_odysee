import 'package:equatable/equatable.dart';

/// Model representing vocabulary item for pre-learning
class VocabularyItem extends Equatable {
  /// Chinese characters
  final String characters;
  
  /// Pinyin pronunciation
  final String pinyin;
  
  /// English translation
  final String translation;

  /// Creates a new [VocabularyItem] instance
  const VocabularyItem({
    required this.characters,
    required this.pinyin,
    required this.translation,
  });

  /// Creates a [VocabularyItem] from a map
  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      characters: map['characters'] as String,
      pinyin: map['pinyin'] as String,
      translation: map['translation'] as String,
    );
  }

  /// Converts this [VocabularyItem] to a map
  Map<String, dynamic> toMap() {
    return {
      'characters': characters,
      'pinyin': pinyin,
      'translation': translation,
    };
  }

  @override
  List<Object?> get props => [characters, pinyin, translation];
}

/// Model representing grammar point for pre-learning
class GrammarPoint extends Equatable {
  /// Name of the grammar point
  final String name;
  
  /// Explanation of the grammar point
  final String explanation;
  
  /// Example sentence using the grammar point
  final String example;

  /// Creates a new [GrammarPoint] instance
  const GrammarPoint({
    required this.name,
    required this.explanation,
    required this.example,
  });

  /// Creates a [GrammarPoint] from a map
  factory GrammarPoint.fromMap(Map<String, dynamic> map) {
    return GrammarPoint(
      name: map['name'] as String,
      explanation: map['explanation'] as String,
      example: map['example'] as String,
    );
  }

  /// Converts this [GrammarPoint] to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'explanation': explanation,
      'example': example,
    };
  }

  @override
  List<Object?> get props => [name, explanation, example];
}

/// Model representing pre-learning content for a scenario
class PreLearningContent extends Equatable {
  /// ID of the scenario
  final String scenarioId;
  
  /// HSK level ID
  final int hskLevelId;
  
  /// List of vocabulary items
  final List<VocabularyItem> vocabulary;
  
  /// List of grammar points
  final List<GrammarPoint> grammarPoints;
  
  /// When the content was generated
  final DateTime generatedAt;

  /// Creates a new [PreLearningContent] instance
  const PreLearningContent({
    required this.scenarioId,
    required this.hskLevelId,
    required this.vocabulary,
    required this.grammarPoints,
    required this.generatedAt,
  });

  /// Creates a [PreLearningContent] from a map
  factory PreLearningContent.fromMap(Map<String, dynamic> map) {
    return PreLearningContent(
      scenarioId: map['scenarioId'] as String,
      hskLevelId: map['hskLevelId'] as int,
      vocabulary: (map['vocabulary'] as List)
          .map((item) => VocabularyItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      grammarPoints: (map['grammarPoints'] as List)
          .map((item) => GrammarPoint.fromMap(item as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(map['generatedAt'] as String),
    );
  }

  /// Converts this [PreLearningContent] to a map
  Map<String, dynamic> toMap() {
    return {
      'scenarioId': scenarioId,
      'hskLevelId': hskLevelId,
      'vocabulary': vocabulary.map((item) => item.toMap()).toList(),
      'grammarPoints': grammarPoints.map((item) => item.toMap()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        scenarioId,
        hskLevelId,
        vocabulary,
        grammarPoints,
        generatedAt,
      ];
}
