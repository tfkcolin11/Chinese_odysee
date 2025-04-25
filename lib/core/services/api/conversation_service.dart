import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Service for conversation-related API operations
class ConversationService {
  /// API service for making HTTP requests
  final ApiService _apiService;

  /// Creates a new [ConversationService] instance
  ConversationService(this._apiService);

  /// Starts a new conversation
  Future<Map<String, dynamic>> startConversation({
    required String scenarioId,
    required int hskLevelPlayed,
    String? inspirationSavedInstanceId,
  }) async {
    try {
      final data = {
        'scenarioId': scenarioId,
        'hskLevelPlayed': hskLevelPlayed,
      };
      
      if (inspirationSavedInstanceId != null) {
        data['inspirationSavedInstanceId'] = inspirationSavedInstanceId;
      }
      
      final response = await _apiService.post('/conversations', data: data);
      
      return {
        'conversation': Conversation.fromJson(response.data['conversation']),
        'initialTurn': ConversationTurn.fromJson(response.data['initialTurn']),
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the current state of a conversation
  Future<Conversation> getConversation(String conversationId) async {
    try {
      final response = await _apiService.get('/conversations/$conversationId');
      return Conversation.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the history of turns for a conversation
  Future<List<ConversationTurn>> getConversationTurns(String conversationId) async {
    try {
      final response = await _apiService.get('/conversations/$conversationId/turns');
      return (response.data as List)
          .map((item) => ConversationTurn.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Submits a user turn and gets the AI's response
  Future<Map<String, dynamic>> submitUserTurn({
    required String conversationId,
    required String inputText,
    required InputMode inputMode,
  }) async {
    try {
      final response = await _apiService.post(
        '/conversations/$conversationId/turns',
        data: {
          'inputText': inputText,
          'inputMode': inputMode.name,
        },
      );
      
      return {
        'aiTurn': ConversationTurn.fromJson(response.data['aiTurn']),
        'userTurnFeedback': response.data['userTurnFeedback'],
        'updatedConversationScore': response.data['updatedConversationScore'],
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Ends a conversation
  Future<Conversation> endConversation(String conversationId) async {
    try {
      final response = await _apiService.post('/conversations/$conversationId/end');
      return Conversation.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Saves a conversation instance
  Future<Conversation> saveConversation({
    required String conversationId,
    String? savedInstanceName,
  }) async {
    try {
      final data = savedInstanceName != null
          ? {'savedInstanceName': savedInstanceName}
          : null;
      
      final response = await _apiService.post(
        '/conversations/$conversationId/save',
        data: data,
      );
      
      return Conversation.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
