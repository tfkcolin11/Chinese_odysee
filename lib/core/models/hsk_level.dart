import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hsk_level.g.dart';

/// HSK Level model representing a Chinese proficiency level
@JsonSerializable()
class HskLevel extends Equatable {
  /// Unique identifier for the HSK level (1-6)
  final int hskLevelId;
  
  /// Name of the HSK level (e.g., "HSK Level 1")
  final String name;
  
  /// Description of the HSK level (optional)
  final String? description;

  /// Creates a new [HskLevel] instance
  const HskLevel({
    required this.hskLevelId,
    required this.name,
    this.description,
  });

  /// Creates an [HskLevel] from a JSON map
  factory HskLevel.fromJson(Map<String, dynamic> json) => _$HskLevelFromJson(json);

  /// Converts this [HskLevel] to a JSON map
  Map<String, dynamic> toJson() => _$HskLevelToJson(this);

  @override
  List<Object?> get props => [hskLevelId, name, description];
}
