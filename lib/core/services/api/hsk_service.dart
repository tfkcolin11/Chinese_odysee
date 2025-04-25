import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Service for HSK-related API operations
class HskService {
  /// API service for making HTTP requests
  final ApiService _apiService;

  /// Creates a new [HskService] instance
  HskService(this._apiService);

  /// Gets all available HSK levels
  Future<List<HskLevel>> getHskLevels() async {
    try {
      final response = await _apiService.get('/hsk-levels');
      return (response.data as List)
          .map((item) => HskLevel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets grammar points, optionally filtered by HSK level
  Future<List<GrammarPoint>> getGrammarPoints({int? hskLevelId}) async {
    try {
      final response = await _apiService.get(
        '/grammar-points',
        queryParameters: hskLevelId != null ? {'hskLevelId': hskLevelId} : null,
      );
      return (response.data as List)
          .map((item) => GrammarPoint.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets vocabulary, optionally filtered by HSK level
  Future<List<Vocabulary>> getVocabulary({
    int? hskLevelId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
      };
      
      if (hskLevelId != null) {
        queryParams['hskLevelId'] = hskLevelId;
      }
      
      final response = await _apiService.get(
        '/vocabulary',
        queryParameters: queryParams,
      );
      
      return (response.data['items'] as List)
          .map((item) => Vocabulary.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
