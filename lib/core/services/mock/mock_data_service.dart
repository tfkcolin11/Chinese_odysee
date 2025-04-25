import 'package:chinese_odysee/core/models/models.dart';
import 'package:uuid/uuid.dart';

/// Service for providing mock data for testing
class MockDataService {
  static final _uuid = Uuid();

  /// Gets mock HSK levels
  static List<HskLevel> getMockHskLevels() {
    return [
      const HskLevel(
        hskLevelId: 1,
        name: 'HSK Level 1',
        description: 'Basic level with 150 words and simple grammar',
      ),
      const HskLevel(
        hskLevelId: 2,
        name: 'HSK Level 2',
        description: 'Elementary level with 300 words',
      ),
      const HskLevel(
        hskLevelId: 3,
        name: 'HSK Level 3',
        description: 'Intermediate level with 600 words',
      ),
      const HskLevel(
        hskLevelId: 4,
        name: 'HSK Level 4',
        description: 'Advanced intermediate with 1200 words',
      ),
      const HskLevel(
        hskLevelId: 5,
        name: 'HSK Level 5',
        description: 'Advanced level with 2500 words',
      ),
      const HskLevel(
        hskLevelId: 6,
        name: 'HSK Level 6',
        description: 'Proficient level with 5000+ words',
      ),
    ];
  }

  /// Gets mock scenarios
  static List<Scenario> getMockScenarios() {
    return [
      Scenario(
        scenarioId: _uuid.v4(),
        name: 'Ordering at a Restaurant',
        description: 'Practice ordering food and drinks at a Chinese restaurant',
        isPredefined: true,
        suggestedHskLevel: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUsedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Scenario(
        scenarioId: _uuid.v4(),
        name: 'Shopping for Clothes',
        description: 'Practice buying clothes and asking about sizes and prices',
        isPredefined: true,
        suggestedHskLevel: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        lastUsedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Scenario(
        scenarioId: _uuid.v4(),
        name: 'Asking for Directions',
        description: 'Practice asking for and giving directions to places',
        isPredefined: true,
        suggestedHskLevel: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Scenario(
        scenarioId: _uuid.v4(),
        name: 'At the Hotel',
        description: 'Practice checking in, asking about facilities, and resolving issues',
        isPredefined: true,
        suggestedHskLevel: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Scenario(
        scenarioId: _uuid.v4(),
        name: 'Making Friends',
        description: 'Practice introducing yourself and making small talk',
        isPredefined: true,
        suggestedHskLevel: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastUsedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Gets a mock initial conversation turn
  static ConversationTurn getMockInitialTurn(String conversationId) {
    return ConversationTurn(
      turnId: _uuid.v4(),
      conversationId: conversationId,
      turnNumber: 1,
      timestamp: DateTime.now(),
      speaker: Speaker.ai,
      aiResponseText: '你好！欢迎来到中文学习之旅。我是你的AI语言伙伴。我们今天要练习什么？',
    );
  }

  /// Gets a mock AI response turn
  static ConversationTurn getMockAiResponseTurn(
    String conversationId,
    int turnNumber,
    String userInput,
  ) {
    String response;
    
    if (userInput.contains('你好') || userInput.contains('hello')) {
      response = '你好！很高兴认识你。你叫什么名字？';
    } else if (userInput.contains('名字') || userInput.contains('叫')) {
      response = '很高兴认识你！你今天想练习什么话题？';
    } else if (userInput.contains('餐厅') || userInput.contains('吃饭')) {
      response = '好的，我们来练习餐厅对话。你想点什么菜？';
    } else if (userInput.contains('菜') || userInput.contains('吃')) {
      response = '这个菜很好吃。你还想点什么饮料？';
    } else {
      response = '对不起，我没听懂。你能用简单的话再说一遍吗？';
    }
    
    return ConversationTurn(
      turnId: _uuid.v4(),
      conversationId: conversationId,
      turnNumber: turnNumber,
      timestamp: DateTime.now(),
      speaker: Speaker.ai,
      aiResponseText: response,
    );
  }

  /// Gets a mock conversation
  static Conversation getMockConversation(String scenarioId, int hskLevelId) {
    final conversationId = _uuid.v4();
    
    return Conversation(
      conversationId: conversationId,
      userId: 'mock-user-id',
      scenarioId: scenarioId,
      scenarioName: 'Mock Scenario',
      hskLevelPlayed: hskLevelId,
      startedAt: DateTime.now(),
      currentScore: 100,
      outcomeStatus: ConversationStatus.pending,
    );
  }
}
