import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/repositories/base_repository.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';
import 'package:chinese_odysee/core/services/api/scenario_service.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';

/// Repository for scenario-related operations
class ScenarioRepository extends BaseRepository<Scenario> {
  /// Scenario service for API operations
  final ScenarioService _scenarioService;

  /// Creates a new [ScenarioRepository] instance
  ScenarioRepository({
    required ApiService apiService,
    required StorageService storageService,
    required ScenarioService scenarioService,
  }) : _scenarioService = scenarioService,
       super(
         apiService: apiService,
         storageService: storageService,
         tableName: 'Scenario',
       );

  @override
  Map<String, dynamic> toMap(Scenario model) {
    return {
      'scenarioId': model.scenarioId,
      'name': model.name,
      'description': model.description,
      'isPredefined': model.isPredefined ? 1 : 0,
      'suggestedHskLevel': model.suggestedHskLevel,
      'createdByUserId': model.createdByUserId,
      'createdAt': model.createdAt.toIso8601String(),
      'lastUsedAt': model.lastUsedAt?.toIso8601String(),
    };
  }

  @override
  Scenario fromMap(Map<String, dynamic> map) {
    return Scenario(
      scenarioId: map['scenarioId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      isPredefined: map['isPredefined'] == 1,
      suggestedHskLevel: map['suggestedHskLevel'] as int?,
      createdByUserId: map['createdByUserId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUsedAt: map['lastUsedAt'] != null
          ? DateTime.parse(map['lastUsedAt'] as String)
          : null,
    );
  }

  @override
  String get idField => 'scenarioId';

  @override
  String getIdValue(Scenario model) => model.scenarioId;

  @override
  Future<List<Scenario>> _getAllRemote() async {
    return await _scenarioService.getScenarios();
  }

  @override
  Future<Scenario?> _getByIdRemote(String id) async {
    return await _scenarioService.getScenario(id);
  }

  @override
  Future<Scenario> _createRemote(Scenario item) async {
    return await _scenarioService.createScenario(
      name: item.name,
      description: item.description,
      suggestedHskLevel: item.suggestedHskLevel,
    );
  }

  @override
  Future<Scenario> _updateRemote(Scenario item) async {
    // In a real app, this would call an API to update a scenario
    // For now, we'll throw an error since scenario updates are not supported
    throw UnimplementedError('Updating a scenario is not supported');
  }

  @override
  Future<bool> _deleteRemote(String id) async {
    // In a real app, this would call an API to delete a scenario
    // For now, we'll throw an error since scenario deletion is not supported
    throw UnimplementedError('Deleting a scenario is not supported');
  }

  /// Gets scenarios by type
  Future<List<Scenario>> getScenariosByType(ScenarioType type) async {
    try {
      if (isOfflineMode) {
        // In offline mode, get scenarios from local storage
        String? whereClause;
        List<dynamic>? whereArgs;

        if (type == ScenarioType.predefined) {
          whereClause = 'isPredefined = ? AND syncStatus != ?';
          whereArgs = [1, 'pending_delete'];
        } else if (type == ScenarioType.user) {
          whereClause = 'isPredefined = ? AND syncStatus != ?';
          whereArgs = [0, 'pending_delete'];
        } else {
          whereClause = 'syncStatus != ?';
          whereArgs = ['pending_delete'];
        }

        final maps = await storageService.query(
          tableName,
          where: whereClause,
          whereArgs: whereArgs,
        );

        return maps.map((map) => fromMap(map)).toList();
      } else {
        try {
          // Try to get scenarios from the API
          final scenarios = await _scenarioService.getScenarios(type: type);

          // Save scenarios to local storage
          await saveAllLocal(scenarios);

          return scenarios;
        } catch (e) {
          // If API call fails, fall back to local storage
          String? whereClause;
          List<dynamic>? whereArgs;

          if (type == ScenarioType.predefined) {
            whereClause = 'isPredefined = ? AND syncStatus != ?';
            whereArgs = [1, 'pending_delete'];
          } else if (type == ScenarioType.user) {
            whereClause = 'isPredefined = ? AND syncStatus != ?';
            whereArgs = [0, 'pending_delete'];
          } else {
            whereClause = 'syncStatus != ?';
            whereArgs = ['pending_delete'];
          }

          final maps = await storageService.query(
            tableName,
            where: whereClause,
            whereArgs: whereArgs,
          );

          return maps.map((map) => fromMap(map)).toList();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new scenario
  Future<Scenario> createScenario({
    required String name,
    required String description,
    int? suggestedHskLevel,
  }) async {
    try {
      // Create a new scenario object
      final scenario = Scenario(
        scenarioId: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        isPredefined: false,
        suggestedHskLevel: suggestedHskLevel,
        createdByUserId: 'local-user', // This would be the actual user ID in a real app
        createdAt: DateTime.now(),
      );

      // Create the scenario
      return await create(scenario);
    } catch (e) {
      rethrow;
    }
  }
}
