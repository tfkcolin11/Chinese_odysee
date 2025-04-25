import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_saved_word.g.dart';

/// User Saved Word model representing a word saved by a user
@JsonSerializable()
class UserSavedWord extends Equatable {
  /// Unique identifier for the saved word
  final String savedWordId;
  
  /// ID of the user who saved this word
  final String userId;
  
  /// ID of the conversation turn where this word was saved
  final String conversationTurnId;
  
  /// Chinese characters for the word
  final String wordCharacters;
  
  /// Pinyin pronunciation (optional)
  final String? wordPinyin;
  
  /// Meaning of the word in the context it was used
  final String contextualMeaning;
  
  /// Example usage of the word
  final String exampleUsage;
  
  /// HSK level this word belongs to (optional)
  final int? sourceHskLevel;
  
  /// When this word was added
  final DateTime addedAt;

  /// Creates a new [UserSavedWord] instance
  const UserSavedWord({
    required this.savedWordId,
    required this.userId,
    required this.conversationTurnId,
    required this.wordCharacters,
    this.wordPinyin,
    required this.contextualMeaning,
    required this.exampleUsage,
    this.sourceHskLevel,
    required this.addedAt,
  });

  /// Creates a [UserSavedWord] from a JSON map
  factory UserSavedWord.fromJson(Map<String, dynamic> json) => _$UserSavedWordFromJson(json);

  /// Converts this [UserSavedWord] to a JSON map
  Map<String, dynamic> toJson() => _$UserSavedWordToJson(this);

  @override
  List<Object?> get props => [
        savedWordId,
        userId,
        conversationTurnId,
        wordCharacters,
        wordPinyin,
        contextualMeaning,
        exampleUsage,
        sourceHskLevel,
        addedAt,
      ];
}
