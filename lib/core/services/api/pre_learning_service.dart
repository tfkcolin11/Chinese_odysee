import 'dart:convert';
import 'package:chinese_odysee/core/models/pre_learning_content.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Service for pre-learning content operations
class PreLearningService {
  /// API service for remote operations
  final ApiService _apiService;

  /// Creates a new [PreLearningService] instance
  PreLearningService(this._apiService);

  /// Gets pre-learning content for a scenario and HSK level
  /// 
  /// This will either retrieve cached content or generate new content
  /// 
  /// Throws an exception if:
  /// - The user doesn't have access to this feature
  /// - The user has exceeded their daily limit
  /// - The scenario doesn't exist
  /// - There's a server error
  Future<PreLearningContent> getPreLearningContent({
    required String scenarioId,
    required int hskLevelId,
  }) async {
    try {
      final response = await _apiService.get(
        '/scenarios/$scenarioId/pre-learning',
        queryParameters: {
          'hskLevelId': hskLevelId.toString(),
        },
      );

      return PreLearningContent.fromMap(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      // Handle specific error codes
      if (e is ApiException) {
        if (e.statusCode == 402) {
          throw const PreLearningException(
            'This feature requires a premium subscription',
            PreLearningErrorType.premiumRequired,
          );
        } else if (e.statusCode == 429) {
          throw const PreLearningException(
            'You have reached your daily limit for pre-learning generations',
            PreLearningErrorType.limitExceeded,
          );
        } else if (e.statusCode == 404) {
          throw const PreLearningException(
            'Scenario not found',
            PreLearningErrorType.scenarioNotFound,
          );
        }
      }
      
      // Generic error
      throw PreLearningException(
        'Failed to get pre-learning content: ${e.toString()}',
        PreLearningErrorType.unknown,
      );
    }
  }
}

/// Types of pre-learning errors
enum PreLearningErrorType {
  /// Premium subscription required
  premiumRequired,
  
  /// Daily limit exceeded
  limitExceeded,
  
  /// Scenario not found
  scenarioNotFound,
  
  /// Unknown error
  unknown,
}

/// Exception thrown when pre-learning operations fail
class PreLearningException implements Exception {
  /// Error message
  final String message;
  
  /// Type of error
  final PreLearningErrorType errorType;

  /// Creates a new [PreLearningException] instance
  const PreLearningException(this.message, this.errorType);

  @override
  String toString() => message;
}
