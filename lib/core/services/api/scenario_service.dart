import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Type of scenarios to retrieve
enum ScenarioType {
  /// Predefined scenarios
  predefined,
  
  /// User-created scenarios
  user,
  
  /// All scenarios
  all
}

/// Service for scenario-related API operations
class ScenarioService {
  /// API service for making HTTP requests
  final ApiService _apiService;

  /// Creates a new [ScenarioService] instance
  ScenarioService(this._apiService);

  /// Gets scenarios, optionally filtered by type
  Future<List<Scenario>> getScenarios({ScenarioType type = ScenarioType.all}) async {
    try {
      final response = await _apiService.get(
        '/scenarios',
        queryParameters: {'type': type.name},
      );
      return (response.data as List)
          .map((item) => Scenario.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets a specific scenario by ID
  Future<Scenario> getScenario(String scenarioId) async {
    try {
      final response = await _apiService.get('/scenarios/$scenarioId');
      return Scenario.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new custom scenario
  Future<Scenario> createScenario({
    required String name,
    required String description,
    int? suggestedHskLevel,
  }) async {
    try {
      final response = await _apiService.post(
        '/scenarios',
        data: {
          'name': name,
          'description': description,
          'suggestedHskLevel': suggestedHskLevel,
        },
      );
      return Scenario.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
