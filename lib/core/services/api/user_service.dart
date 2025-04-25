import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Service for user-related API operations
class UserService {
  /// API service for making HTTP requests
  final ApiService _apiService;

  /// Creates a new [UserService] instance
  UserService(this._apiService);

  /// Gets the current user's profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/users/me');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the user's settings
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final response = await _apiService.get('/settings');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the user's settings
  Future<Map<String, dynamic>> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _apiService.put('/settings', data: settings);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the user's mastery for grammar points
  Future<List<UserMasteryGrammar>> getUserMasteryGrammar(int hskLevelId) async {
    try {
      final response = await _apiService.get(
        '/mastery/grammar',
        queryParameters: {'hskLevelId': hskLevelId},
      );
      return (response.data as List)
          .map((item) => UserMasteryGrammar.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the user's mastery for vocabulary
  Future<List<UserMasteryVocabulary>> getUserMasteryVocabulary(int hskLevelId) async {
    try {
      final response = await _apiService.get(
        '/mastery/vocabulary',
        queryParameters: {'hskLevelId': hskLevelId},
      );
      return (response.data as List)
          .map((item) => UserMasteryVocabulary.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the user's saved words
  Future<List<UserSavedWord>> getUserSavedWords({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/saved-words',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['items'] as List)
          .map((item) => UserSavedWord.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
