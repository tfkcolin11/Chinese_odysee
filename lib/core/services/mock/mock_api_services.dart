import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/services/api/api_services.dart';
import 'package:chinese_odysee/core/services/mock/mock_data_service.dart';
import 'package:uuid/uuid.dart';

/// Mock implementation of [HskService]
class MockHskService implements HskService {
  final _uuid = Uuid();
  final ApiService _apiService;

  /// Creates a new [MockHskService] instance
  MockHskService(this._apiService);

  @override
  Future<List<HskLevel>> getHskLevels() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return MockDataService.getMockHskLevels();
  }

  @override
  Future<List<GrammarPoint>> getGrammarPoints({int? hskLevelId}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Create mock grammar points
    final List<GrammarPoint> grammarPoints = [];
    
    for (int i = 1; i <= 5; i++) {
      final level = hskLevelId ?? i;
      grammarPoints.add(
        GrammarPoint(
          grammarPointId: _uuid.v4(),
          hskLevelId: level,
          name: 'Grammar Point $i for HSK $level',
          descriptionHtml: 'This is a description of grammar point $i for HSK level $level',
          exampleSentenceChinese: '这是一个例子。',
          exampleSentencePinyin: 'Zhè shì yī gè lì zi.',
          exampleSentenceTranslation: 'This is an example.',
        ),
      );
    }
    
    return grammarPoints;
  }

  @override
  Future<List<Vocabulary>> getVocabulary({
    int? hskLevelId,
    int page = 1,
    int limit = 50,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Create mock vocabulary items
    final List<Vocabulary> vocabulary = [];
    
    final words = [
      {'characters': '你好', 'pinyin': 'nǐ hǎo', 'english': 'hello'},
      {'characters': '谢谢', 'pinyin': 'xiè xiè', 'english': 'thank you'},
      {'characters': '再见', 'pinyin': 'zài jiàn', 'english': 'goodbye'},
      {'characters': '朋友', 'pinyin': 'péng yǒu', 'english': 'friend'},
      {'characters': '学生', 'pinyin': 'xué shēng', 'english': 'student'},
    ];
    
    for (int i = 0; i < words.length; i++) {
      final level = hskLevelId ?? 1;
      vocabulary.add(
        Vocabulary(
          vocabularyId: _uuid.v4(),
          hskLevelId: level,
          characters: words[i]['characters']!,
          pinyin: words[i]['pinyin']!,
          englishTranslation: words[i]['english']!,
          partOfSpeech: 'noun',
        ),
      );
    }
    
    return vocabulary;
  }
}

/// Mock implementation of [ScenarioService]
class MockScenarioService implements ScenarioService {
  final ApiService _apiService;
  final List<Scenario> _scenarios = MockDataService.getMockScenarios();

  /// Creates a new [MockScenarioService] instance
  MockScenarioService(this._apiService);

  @override
  Future<List<Scenario>> getScenarios({ScenarioType type = ScenarioType.all}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (type == ScenarioType.predefined) {
      return _scenarios.where((s) => s.isPredefined).toList();
    } else if (type == ScenarioType.user) {
      return _scenarios.where((s) => !s.isPredefined).toList();
    } else {
      return _scenarios;
    }
  }

  @override
  Future<Scenario> getScenario(String scenarioId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final scenario = _scenarios.firstWhere(
      (s) => s.scenarioId == scenarioId,
      orElse: () => throw Exception('Scenario not found'),
    );
    
    return scenario;
  }

  @override
  Future<Scenario> createScenario({
    required String name,
    required String description,
    int? suggestedHskLevel,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final newScenario = Scenario(
      scenarioId: const Uuid().v4(),
      name: name,
      description: description,
      isPredefined: false,
      suggestedHskLevel: suggestedHskLevel,
      createdByUserId: 'mock-user-id',
      createdAt: DateTime.now(),
    );
    
    _scenarios.add(newScenario);
    
    return newScenario;
  }
}

/// Mock implementation of [ConversationService]
class MockConversationService implements ConversationService {
  final ApiService _apiService;
  Conversation? _activeConversation;
  final List<ConversationTurn> _turns = [];
  int _turnCounter = 1;

  /// Creates a new [MockConversationService] instance
  MockConversationService(this._apiService);

  @override
  Future<Map<String, dynamic>> startConversation({
    required String scenarioId,
    required int hskLevelPlayed,
    String? inspirationSavedInstanceId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Create a new conversation
    _activeConversation = MockDataService.getMockConversation(
      scenarioId,
      hskLevelPlayed,
    );
    
    // Create the initial AI turn
    final initialTurn = MockDataService.getMockInitialTurn(
      _activeConversation!.conversationId,
    );
    
    // Add the turn to the list
    _turns.clear();
    _turns.add(initialTurn);
    _turnCounter = 2;
    
    return {
      'conversation': _activeConversation!,
      'initialTurn': initialTurn,
    };
  }

  @override
  Future<Conversation> getConversation(String conversationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_activeConversation == null) {
      throw Exception('No active conversation');
    }
    
    return _activeConversation!;
  }

  @override
  Future<List<ConversationTurn>> getConversationTurns(String conversationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _turns;
  }

  @override
  Future<Map<String, dynamic>> submitUserTurn({
    required String conversationId,
    required String inputText,
    required InputMode inputMode,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (_activeConversation == null) {
      throw Exception('No active conversation');
    }
    
    // Create a user turn
    final userTurn = ConversationTurn(
      turnId: const Uuid().v4(),
      conversationId: _activeConversation!.conversationId,
      turnNumber: _turnCounter++,
      timestamp: DateTime.now(),
      speaker: Speaker.user,
      inputMode: inputMode,
      userValidatedTranscript: inputText,
    );
    
    // Add the user turn to the list
    _turns.add(userTurn);
    
    // Create an AI response turn
    final aiTurn = MockDataService.getMockAiResponseTurn(
      _activeConversation!.conversationId,
      _turnCounter++,
      inputText,
    );
    
    // Add the AI turn to the list
    _turns.add(aiTurn);
    
    // Update the conversation score
    final newScore = _activeConversation!.currentScore - 5;
    _activeConversation = _activeConversation!.copyWith(
      currentScore: newScore > 0 ? newScore : 0,
    );
    
    return {
      'aiTurn': aiTurn,
      'userTurnFeedback': {
        'scoreChange': -5,
        'errors': [],
        'correctGrammarPoints': [],
        'correctVocabulary': [],
      },
      'updatedConversationScore': _activeConversation!.currentScore,
    };
  }

  @override
  Future<Conversation> endConversation(String conversationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_activeConversation == null) {
      throw Exception('No active conversation');
    }
    
    // Update the conversation status
    _activeConversation = _activeConversation!.copyWith(
      endedAt: DateTime.now(),
      finalScore: _activeConversation!.currentScore,
      outcomeStatus: ConversationStatus.achieved,
    );
    
    return _activeConversation!;
  }

  @override
  Future<Conversation> saveConversation({
    required String conversationId,
    String? savedInstanceName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_activeConversation == null) {
      throw Exception('No active conversation');
    }
    
    // Update the conversation with saved instance details
    _activeConversation = _activeConversation!.copyWith(
      savedInstanceDetails: {
        'name': savedInstanceName ?? 'Saved Conversation',
        'savedAt': DateTime.now().toIso8601String(),
      },
    );
    
    return _activeConversation!;
  }
}
