import 'dart:convert';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/repositories/base_repository.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';
import 'package:chinese_odysee/core/services/api/conversation_service.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';

/// Repository for conversation-related operations
class ConversationRepository extends BaseRepository<Conversation> {
  /// Conversation service for API operations
  final ConversationService _conversationService;

  /// Creates a new [ConversationRepository] instance
  ConversationRepository({
    required super.apiService,
    required super.storageService,
    required ConversationService conversationService,
  }) : _conversationService = conversationService,
       super(
         tableName: 'Conversation',
       );

  @override
  Map<String, dynamic> toMap(Conversation model) {
    return {
      'conversationId': model.conversationId,
      'userId': model.userId,
      'scenarioId': model.scenarioId,
      'scenarioName': model.scenarioName,
      'hskLevelPlayed': model.hskLevelPlayed,
      'startedAt': model.startedAt.toIso8601String(),
      'endedAt': model.endedAt?.toIso8601String(),
      'currentScore': model.currentScore,
      'finalScore': model.finalScore,
      'outcomeStatus': model.outcomeStatus.name,
      'aiHiddenGoalDescription': model.aiHiddenGoalDescription,
      'savedInstanceDetails': model.savedInstanceDetails != null
          ? jsonEncode(model.savedInstanceDetails)
          : null,
    };
  }

  @override
  Conversation fromMap(Map<String, dynamic> map) {
    return Conversation(
      conversationId: map['conversationId'] as String,
      userId: map['userId'] as String,
      scenarioId: map['scenarioId'] as String,
      scenarioName: map['scenarioName'] as String,
      hskLevelPlayed: map['hskLevelPlayed'] as int,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: map['endedAt'] != null
          ? DateTime.parse(map['endedAt'] as String)
          : null,
      currentScore: map['currentScore'] as int,
      finalScore: map['finalScore'] as int?,
      outcomeStatus: ConversationStatus.values.firstWhere(
        (e) => e.name == map['outcomeStatus'],
        orElse: () => ConversationStatus.pending,
      ),
      aiHiddenGoalDescription: map['aiHiddenGoalDescription'] as String?,
      savedInstanceDetails: map['savedInstanceDetails'] != null
          ? jsonDecode(map['savedInstanceDetails'] as String)
              as Map<String, dynamic>
          : null,
    );
  }

  @override
  String get idField => 'conversationId';

  @override
  String getIdValue(Conversation model) => model.conversationId;

  @override
  Future<List<Conversation>> _getAllRemote() async {
    // In a real app, this would call an API to get all conversations
    // For now, we'll throw an error since getting all conversations is not supported
    throw UnimplementedError('Getting all conversations is not supported');
  }

  @override
  Future<Conversation?> _getByIdRemote(String id) async {
    return await _conversationService.getConversation(id);
  }

  @override
  Future<Conversation> _createRemote(Conversation item) async {
    // In a real app, this would call an API to create a conversation
    // For now, we'll throw an error since conversation creation is handled by startConversation
    throw UnimplementedError('Creating a conversation is not supported');
  }

  @override
  Future<Conversation> _updateRemote(Conversation item) async {
    // In a real app, this would call an API to update a conversation
    // For now, we'll throw an error since conversation updates are handled by specific methods
    throw UnimplementedError('Updating a conversation is not supported');
  }

  @override
  Future<bool> _deleteRemote(String id) async {
    // In a real app, this would call an API to delete a conversation
    // For now, we'll throw an error since conversation deletion is not supported
    throw UnimplementedError('Deleting a conversation is not supported');
  }

  /// Starts a new conversation
  Future<Map<String, dynamic>> startConversation({
    required String scenarioId,
    required int hskLevelPlayed,
    String? inspirationSavedInstanceId,
  }) async {
    try {
      if (isOfflineMode) {
        // In offline mode, create a local conversation
        final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Get the scenario name from local storage
        final scenarioMaps = await storageService.query(
          'Scenario',
          where: 'scenarioId = ?',
          whereArgs: [scenarioId],
          limit: 1,
        );
        
        final scenarioName = scenarioMaps.isNotEmpty
            ? scenarioMaps.first['name'] as String
            : 'Unknown Scenario';
        
        // Create a new conversation
        final conversation = Conversation(
          conversationId: conversationId,
          userId: 'local-user', // This would be the actual user ID in a real app
          scenarioId: scenarioId,
          scenarioName: scenarioName,
          hskLevelPlayed: hskLevelPlayed,
          startedAt: DateTime.now(),
          currentScore: 100,
          outcomeStatus: ConversationStatus.pending,
        );
        
        // Save the conversation to local storage
        await _saveLocal(conversation, syncStatus: 'pending_create');
        
        // Create an initial AI turn
        final initialTurn = ConversationTurn(
          turnId: '${conversationId}_1',
          conversationId: conversationId,
          turnNumber: 1,
          timestamp: DateTime.now(),
          speaker: Speaker.ai,
          aiResponseText: 'Welcome to the conversation! (Offline Mode)',
        );
        
        // Save the turn to local storage
        await storageService.insert(
          'ConversationTurn',
          {
            'turnId': initialTurn.turnId,
            'conversationId': initialTurn.conversationId,
            'turnNumber': initialTurn.turnNumber,
            'timestamp': initialTurn.timestamp.toIso8601String(),
            'speaker': initialTurn.speaker.name,
            'aiResponseText': initialTurn.aiResponseText,
            'syncStatus': 'pending_create',
          },
        );
        
        return {
          'conversation': conversation,
          'initialTurn': initialTurn,
        };
      } else {
        try {
          // Try to start a conversation via the API
          final result = await _conversationService.startConversation(
            scenarioId: scenarioId,
            hskLevelPlayed: hskLevelPlayed,
            inspirationSavedInstanceId: inspirationSavedInstanceId,
          );
          
          // Save the conversation to local storage
          final conversation = result['conversation'] as Conversation;
          await _saveLocal(conversation);
          
          // Save the initial turn to local storage
          final initialTurn = result['initialTurn'] as ConversationTurn;
          await storageService.insert(
            'ConversationTurn',
            {
              'turnId': initialTurn.turnId,
              'conversationId': initialTurn.conversationId,
              'turnNumber': initialTurn.turnNumber,
              'timestamp': initialTurn.timestamp.toIso8601String(),
              'speaker': initialTurn.speaker.name,
              'aiResponseText': initialTurn.aiResponseText,
              'syncStatus': 'synced',
            },
          );
          
          return result;
        } catch (e) {
          // If API call fails, fall back to offline mode
          setOfflineMode(true);
          return await startConversation(
            scenarioId: scenarioId,
            hskLevelPlayed: hskLevelPlayed,
          );
        }
      }
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
      if (isOfflineMode) {
        // In offline mode, create a local user turn and AI response
        
        // Get the current conversation
        final conversationMaps = await storageService.query(
          'Conversation',
          where: 'conversationId = ?',
          whereArgs: [conversationId],
          limit: 1,
        );
        
        if (conversationMaps.isEmpty) {
          throw Exception('Conversation not found');
        }
        
        final conversation = fromMap(conversationMaps.first);
        
        // Get the latest turn number
        final turnMaps = await storageService.query(
          'ConversationTurn',
          where: 'conversationId = ?',
          whereArgs: [conversationId],
          orderBy: 'turnNumber DESC',
          limit: 1,
        );
        
        final latestTurnNumber = turnMaps.isNotEmpty
            ? turnMaps.first['turnNumber'] as int
            : 0;
        
        // Create a user turn
        final userTurn = ConversationTurn(
          turnId: '${conversationId}_${latestTurnNumber + 1}',
          conversationId: conversationId,
          turnNumber: latestTurnNumber + 1,
          timestamp: DateTime.now(),
          speaker: Speaker.user,
          inputMode: inputMode,
          userValidatedTranscript: inputText,
        );
        
        // Save the user turn to local storage
        await storageService.insert(
          'ConversationTurn',
          {
            'turnId': userTurn.turnId,
            'conversationId': userTurn.conversationId,
            'turnNumber': userTurn.turnNumber,
            'timestamp': userTurn.timestamp.toIso8601String(),
            'speaker': userTurn.speaker.name,
            'inputMode': userTurn.inputMode?.name,
            'userValidatedTranscript': userTurn.userValidatedTranscript,
            'syncStatus': 'pending_create',
          },
        );
        
        // Create a simple AI response (in a real app, this would use a local model)
        final aiTurn = ConversationTurn(
          turnId: '${conversationId}_${latestTurnNumber + 2}',
          conversationId: conversationId,
          turnNumber: latestTurnNumber + 2,
          timestamp: DateTime.now(),
          speaker: Speaker.ai,
          aiResponseText: _getOfflineAiResponse(inputText),
        );
        
        // Save the AI turn to local storage
        await storageService.insert(
          'ConversationTurn',
          {
            'turnId': aiTurn.turnId,
            'conversationId': aiTurn.conversationId,
            'turnNumber': aiTurn.turnNumber,
            'timestamp': aiTurn.timestamp.toIso8601String(),
            'speaker': aiTurn.speaker.name,
            'aiResponseText': aiTurn.aiResponseText,
            'syncStatus': 'pending_create',
          },
        );
        
        // Update the conversation score
        final newScore = conversation.currentScore - 5;
        final updatedConversation = conversation.copyWith(
          currentScore: newScore > 0 ? newScore : 0,
        );
        
        // Save the updated conversation
        await _saveLocal(updatedConversation, syncStatus: 'pending_update');
        
        return {
          'aiTurn': aiTurn,
          'userTurnFeedback': {
            'scoreChange': -5,
            'errors': [],
            'correctGrammarPoints': [],
            'correctVocabulary': [],
          },
          'updatedConversationScore': updatedConversation.currentScore,
        };
      } else {
        try {
          // Try to submit the turn via the API
          final result = await _conversationService.submitUserTurn(
            conversationId: conversationId,
            inputText: inputText,
            inputMode: inputMode,
          );
          
          // Save the user turn and AI response to local storage
          final aiTurn = result['aiTurn'] as ConversationTurn;
          
          // Get the user turn number
          final userTurnNumber = aiTurn.turnNumber - 1;
          
          // Save the user turn
          await storageService.insert(
            'ConversationTurn',
            {
              'turnId': '${conversationId}_$userTurnNumber',
              'conversationId': conversationId,
              'turnNumber': userTurnNumber,
              'timestamp': DateTime.now().toIso8601String(),
              'speaker': Speaker.user.name,
              'inputMode': inputMode.name,
              'userValidatedTranscript': inputText,
              'syncStatus': 'synced',
            },
          );
          
          // Save the AI turn
          await storageService.insert(
            'ConversationTurn',
            {
              'turnId': aiTurn.turnId,
              'conversationId': aiTurn.conversationId,
              'turnNumber': aiTurn.turnNumber,
              'timestamp': aiTurn.timestamp.toIso8601String(),
              'speaker': aiTurn.speaker.name,
              'aiResponseText': aiTurn.aiResponseText,
              'syncStatus': 'synced',
            },
          );
          
          // Update the conversation score
          final updatedScore = result['updatedConversationScore'] as int;
          
          // Get the current conversation
          final conversationMaps = await storageService.query(
            'Conversation',
            where: 'conversationId = ?',
            whereArgs: [conversationId],
            limit: 1,
          );
          
          if (conversationMaps.isNotEmpty) {
            final conversation = fromMap(conversationMaps.first);
            final updatedConversation = conversation.copyWith(
              currentScore: updatedScore,
            );
            
            // Save the updated conversation
            await _saveLocal(updatedConversation);
          }
          
          return result;
        } catch (e) {
          // If API call fails, fall back to offline mode
          setOfflineMode(true);
          return await submitUserTurn(
            conversationId: conversationId,
            inputText: inputText,
            inputMode: inputMode,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the conversation turns
  Future<List<ConversationTurn>> getConversationTurns(String conversationId) async {
    try {
      if (isOfflineMode) {
        // In offline mode, get turns from local storage
        final maps = await storageService.query(
          'ConversationTurn',
          where: 'conversationId = ?',
          whereArgs: [conversationId],
          orderBy: 'turnNumber ASC',
        );
        
        return maps.map((map) => _turnFromMap(map)).toList();
      } else {
        try {
          // Try to get turns from the API
          final turns = await _conversationService.getConversationTurns(conversationId);
          
          // Save turns to local storage
          for (final turn in turns) {
            await storageService.insert(
              'ConversationTurn',
              _turnToMap(turn),
            );
          }
          
          return turns;
        } catch (e) {
          // If API call fails, fall back to local storage
          final maps = await storageService.query(
            'ConversationTurn',
            where: 'conversationId = ?',
            whereArgs: [conversationId],
            orderBy: 'turnNumber ASC',
          );
          
          return maps.map((map) => _turnFromMap(map)).toList();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Ends a conversation
  Future<Conversation> endConversation(String conversationId) async {
    try {
      if (isOfflineMode) {
        // In offline mode, update the conversation locally
        final maps = await storageService.query(
          'Conversation',
          where: 'conversationId = ?',
          whereArgs: [conversationId],
          limit: 1,
        );
        
        if (maps.isEmpty) {
          throw Exception('Conversation not found');
        }
        
        final conversation = fromMap(maps.first);
        final updatedConversation = conversation.copyWith(
          endedAt: DateTime.now(),
          finalScore: conversation.currentScore,
          outcomeStatus: ConversationStatus.achieved,
        );
        
        // Save the updated conversation
        await _saveLocal(updatedConversation, syncStatus: 'pending_update');
        
        return updatedConversation;
      } else {
        try {
          // Try to end the conversation via the API
          final endedConversation = await _conversationService.endConversation(conversationId);
          
          // Save the updated conversation
          await _saveLocal(endedConversation);
          
          return endedConversation;
        } catch (e) {
          // If API call fails, fall back to offline mode
          setOfflineMode(true);
          return await endConversation(conversationId);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Saves a conversation
  Future<Conversation> saveConversation({
    required String conversationId,
    String? savedInstanceName,
  }) async {
    try {
      if (isOfflineMode) {
        // In offline mode, update the conversation locally
        final maps = await storageService.query(
          'Conversation',
          where: 'conversationId = ?',
          whereArgs: [conversationId],
          limit: 1,
        );
        
        if (maps.isEmpty) {
          throw Exception('Conversation not found');
        }
        
        final conversation = fromMap(maps.first);
        final savedInstanceDetails = {
          'name': savedInstanceName ?? 'Saved Conversation',
          'savedAt': DateTime.now().toIso8601String(),
        };
        
        final updatedConversation = conversation.copyWith(
          savedInstanceDetails: savedInstanceDetails,
        );
        
        // Save the updated conversation
        await _saveLocal(updatedConversation, syncStatus: 'pending_update');
        
        return updatedConversation;
      } else {
        try {
          // Try to save the conversation via the API
          final savedConversation = await _conversationService.saveConversation(
            conversationId: conversationId,
            savedInstanceName: savedInstanceName,
          );
          
          // Save the updated conversation
          await _saveLocal(savedConversation);
          
          return savedConversation;
        } catch (e) {
          // If API call fails, fall back to offline mode
          setOfflineMode(true);
          return await saveConversation(
            conversationId: conversationId,
            savedInstanceName: savedInstanceName,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Gets a simple AI response for offline mode
  String _getOfflineAiResponse(String userInput) {
    final input = userInput.toLowerCase();
    
    if (input.contains('你好') || input.contains('hello')) {
      return '你好！很高兴认识你。你叫什么名字？';
    } else if (input.contains('名字') || input.contains('叫')) {
      return '很高兴认识你！你今天想练习什么话题？';
    } else if (input.contains('餐厅') || input.contains('吃饭')) {
      return '好的，我们来练习餐厅对话。你想点什么菜？';
    } else if (input.contains('菜') || input.contains('吃')) {
      return '这个菜很好吃。你还想点什么饮料？';
    } else {
      return '对不起，我没听懂。你能用简单的话再说一遍吗？(离线模式)';
    }
  }

  /// Converts a conversation turn to a map
  Map<String, dynamic> _turnToMap(ConversationTurn turn) {
    return {
      'turnId': turn.turnId,
      'conversationId': turn.conversationId,
      'turnNumber': turn.turnNumber,
      'timestamp': turn.timestamp.toIso8601String(),
      'speaker': turn.speaker.name,
      'inputMode': turn.inputMode?.name,
      'userRawInput': turn.userRawInput,
      'userValidatedTranscript': turn.userValidatedTranscript,
      'aiResponseText': turn.aiResponseText,
      'grammarPointsUsedCorrectlyIds': turn.grammarPointsUsedCorrectlyIds != null
          ? jsonEncode(turn.grammarPointsUsedCorrectlyIds)
          : null,
      'vocabularyUsedCorrectlyIds': turn.vocabularyUsedCorrectlyIds != null
          ? jsonEncode(turn.vocabularyUsedCorrectlyIds)
          : null,
      'identifiedErrors': turn.identifiedErrors != null
          ? jsonEncode(turn.identifiedErrors)
          : null,
      'scoreChange': turn.scoreChange,
      'flaggedNewWordId': turn.flaggedNewWordId,
      'syncStatus': 'synced',
    };
  }

  /// Creates a conversation turn from a map
  ConversationTurn _turnFromMap(Map<String, dynamic> map) {
    return ConversationTurn(
      turnId: map['turnId'] as String,
      conversationId: map['conversationId'] as String,
      turnNumber: map['turnNumber'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      speaker: Speaker.values.firstWhere(
        (e) => e.name == map['speaker'],
        orElse: () => Speaker.ai,
      ),
      inputMode: map['inputMode'] != null
          ? InputMode.values.firstWhere(
              (e) => e.name == map['inputMode'],
              orElse: () => InputMode.text,
            )
          : null,
      userRawInput: map['userRawInput'] as String?,
      userValidatedTranscript: map['userValidatedTranscript'] as String?,
      aiResponseText: map['aiResponseText'] as String?,
      grammarPointsUsedCorrectlyIds: map['grammarPointsUsedCorrectlyIds'] != null
          ? List<String>.from(jsonDecode(map['grammarPointsUsedCorrectlyIds'] as String))
          : null,
      vocabularyUsedCorrectlyIds: map['vocabularyUsedCorrectlyIds'] != null
          ? List<String>.from(jsonDecode(map['vocabularyUsedCorrectlyIds'] as String))
          : null,
      identifiedErrors: map['identifiedErrors'] != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(map['identifiedErrors'] as String).map(
                (item) => Map<String, dynamic>.from(item),
              ),
            )
          : null,
      scoreChange: map['scoreChange'] as int?,
      flaggedNewWordId: map['flaggedNewWordId'] as String?,
    );
  }
}
