import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_mastery.g.dart';

/// Base class for user mastery models
abstract class UserMastery extends Equatable {
  /// ID of the user
  final String userId;
  
  /// Mastery score (0.0 to 1.0)
  final double masteryScore;
  
  /// Number of consecutive correct uses
  final int correctStreak;
  
  /// Number of times encountered
  final int timesEncountered;
  
  /// Number of times used correctly
  final int timesCorrect;
  
  /// When this item was last practiced
  final DateTime? lastPracticedAt;
  
  /// When this mastery record was last updated
  final DateTime lastUpdatedAt;

  /// Creates a new [UserMastery] instance
  const UserMastery({
    required this.userId,
    required this.masteryScore,
    required this.correctStreak,
    required this.timesEncountered,
    required this.timesCorrect,
    this.lastPracticedAt,
    required this.lastUpdatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        masteryScore,
        correctStreak,
        timesEncountered,
        timesCorrect,
        lastPracticedAt,
        lastUpdatedAt,
      ];
}

/// User mastery for grammar points
@JsonSerializable()
class UserMasteryGrammar extends UserMastery {
  /// ID of the grammar point
  final String grammarPointId;

  /// Creates a new [UserMasteryGrammar] instance
  const UserMasteryGrammar({
    required super.userId,
    required this.grammarPointId,
    required super.masteryScore,
    required super.correctStreak,
    required super.timesEncountered,
    required super.timesCorrect,
    super.lastPracticedAt,
    required super.lastUpdatedAt,
  });

  /// Creates a [UserMasteryGrammar] from a JSON map
  factory UserMasteryGrammar.fromJson(Map<String, dynamic> json) => _$UserMasteryGrammarFromJson(json);

  /// Converts this [UserMasteryGrammar] to a JSON map
  Map<String, dynamic> toJson() => _$UserMasteryGrammarToJson(this);

  @override
  List<Object?> get props => [...super.props, grammarPointId];
}

/// User mastery for vocabulary
@JsonSerializable()
class UserMasteryVocabulary extends UserMastery {
  /// ID of the vocabulary item
  final String vocabularyId;

  /// Creates a new [UserMasteryVocabulary] instance
  const UserMasteryVocabulary({
    required super.userId,
    required this.vocabularyId,
    required super.masteryScore,
    required super.correctStreak,
    required super.timesEncountered,
    required super.timesCorrect,
    super.lastPracticedAt,
    required super.lastUpdatedAt,
  });

  /// Creates a [UserMasteryVocabulary] from a JSON map
  factory UserMasteryVocabulary.fromJson(Map<String, dynamic> json) => _$UserMasteryVocabularyFromJson(json);

  /// Converts this [UserMasteryVocabulary] to a JSON map
  Map<String, dynamic> toJson() => _$UserMasteryVocabularyToJson(this);

  @override
  List<Object?> get props => [...super.props, vocabularyId];
}
