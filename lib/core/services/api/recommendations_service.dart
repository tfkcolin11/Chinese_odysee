import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Type of recommendations to retrieve
enum RecommendationType {
  /// Scenario recommendations
  scenario,
  
  /// Grammar recommendations
  grammar,
  
  /// Vocabulary recommendations
  vocabulary
}

/// Service for recommendations-related API operations
class RecommendationsService {
  /// API service for making HTTP requests
  final ApiService _apiService;

  /// Creates a new [RecommendationsService] instance
  RecommendationsService(this._apiService);

  /// Gets personalized learning recommendations
  Future<Map<String, dynamic>> getRecommendations({
    RecommendationType? type,
  }) async {
    try {
      final queryParams = type != null ? {'type': type.name} : null;
      
      final response = await _apiService.get(
        '/recommendations',
        queryParameters: queryParams,
      );
      
      final Map<String, dynamic> result = {};
      
      if (response.data['scenarios'] != null) {
        result['scenarios'] = (response.data['scenarios'] as List)
            .map((item) => Scenario.fromJson(item))
            .toList();
      }
      
      if (response.data['grammarPoints'] != null) {
        result['grammarPoints'] = (response.data['grammarPoints'] as List)
            .map((item) => GrammarPoint.fromJson(item))
            .toList();
      }
      
      if (response.data['vocabulary'] != null) {
        result['vocabulary'] = (response.data['vocabulary'] as List)
            .map((item) => Vocabulary.fromJson(item))
            .toList();
      }
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
