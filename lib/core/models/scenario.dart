import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scenario.g.dart';

/// Scenario model representing a conversation scenario
@JsonSerializable()
class Scenario extends Equatable {
  /// Unique identifier for the scenario
  final String scenarioId;
  
  /// Name of the scenario
  final String name;
  
  /// Description of the scenario
  final String description;
  
  /// Whether this is a predefined scenario
  final bool isPredefined;
  
  /// Suggested HSK level for this scenario (optional)
  final int? suggestedHskLevel;
  
  /// ID of the user who created this scenario (null if predefined)
  final String? createdByUserId;
  
  /// When the scenario was created
  final DateTime createdAt;
  
  /// When the scenario was last used (optional)
  final DateTime? lastUsedAt;

  /// Creates a new [Scenario] instance
  const Scenario({
    required this.scenarioId,
    required this.name,
    required this.description,
    required this.isPredefined,
    this.suggestedHskLevel,
    this.createdByUserId,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Creates a [Scenario] from a JSON map
  factory Scenario.fromJson(Map<String, dynamic> json) => _$ScenarioFromJson(json);

  /// Converts this [Scenario] to a JSON map
  Map<String, dynamic> toJson() => _$ScenarioToJson(this);

  @override
  List<Object?> get props => [
        scenarioId,
        name,
        description,
        isPredefined,
        suggestedHskLevel,
        createdByUserId,
        createdAt,
        lastUsedAt,
      ];
}
