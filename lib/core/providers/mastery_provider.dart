import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/api_providers.dart';
import 'package:uuid/uuid.dart';

/// Provider for grammar mastery data
final grammarMasteryProvider = FutureProvider.family<List<UserMasteryGrammar>, int>((ref, hskLevelId) async {
  final userService = ref.watch(userServiceProvider);
  
  try {
    // In a real app, this would call the API to get mastery data
    // For now, we'll return mock data
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _getMockGrammarMastery(hskLevelId);
  } catch (e) {
    rethrow;
  }
});

/// Provider for vocabulary mastery data
final vocabularyMasteryProvider = FutureProvider.family<List<UserMasteryVocabulary>, int>((ref, hskLevelId) async {
  final userService = ref.watch(userServiceProvider);
  
  try {
    // In a real app, this would call the API to get mastery data
    // For now, we'll return mock data
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _getMockVocabularyMastery(hskLevelId);
  } catch (e) {
    rethrow;
  }
});

/// Provider for overall mastery statistics
final masteryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  // In a real app, this would calculate stats based on actual mastery data
  // For now, we'll return mock stats
  return {
    'grammar': {
      'overall': 0.42,
      'byLevel': {
        1: 0.85,
        2: 0.62,
        3: 0.45,
        4: 0.28,
        5: 0.12,
        6: 0.05,
      },
    },
    'vocabulary': {
      'overall': 0.38,
      'byLevel': {
        1: 0.80,
        2: 0.58,
        3: 0.40,
        4: 0.25,
        5: 0.10,
        6: 0.03,
      },
    },
    'overall': 0.40,
  };
});

/// Provider for learning recommendations
final recommendationsProvider = FutureProvider<Map<String, List<dynamic>>>((ref) async {
  // In a real app, this would call the API to get personalized recommendations
  // For now, we'll return mock recommendations
  await Future.delayed(const Duration(milliseconds: 1000));
  
  return {
    'grammar': _getMockGrammarRecommendations(),
    'vocabulary': _getMockVocabularyRecommendations(),
    'scenarios': _getMockScenarioRecommendations(),
  };
});

// Helper functions to generate mock data

List<UserMasteryGrammar> _getMockGrammarMastery(int hskLevelId) {
  final uuid = Uuid();
  final List<UserMasteryGrammar> result = [];
  
  // Generate 10 mock grammar mastery items
  for (int i = 1; i <= 10; i++) {
    final masteryScore = (hskLevelId == 1)
        ? 0.5 + (i / 20) // Higher scores for HSK 1
        : 0.3 + (i / 30); // Lower scores for higher HSK levels
    
    result.add(
      UserMasteryGrammar(
        userId: 'mock-user-id',
        grammarPointId: uuid.v4(),
        masteryScore: masteryScore.clamp(0.0, 1.0),
        correctStreak: i,
        timesEncountered: 10 + i,
        timesCorrect: 5 + i,
        lastPracticedAt: DateTime.now().subtract(Duration(days: i)),
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }
  
  return result;
}

List<UserMasteryVocabulary> _getMockVocabularyMastery(int hskLevelId) {
  final uuid = Uuid();
  final List<UserMasteryVocabulary> result = [];
  
  // Generate 20 mock vocabulary mastery items
  for (int i = 1; i <= 20; i++) {
    final masteryScore = (hskLevelId == 1)
        ? 0.6 + (i / 50) // Higher scores for HSK 1
        : 0.2 + (i / 40); // Lower scores for higher HSK levels
    
    result.add(
      UserMasteryVocabulary(
        userId: 'mock-user-id',
        vocabularyId: uuid.v4(),
        masteryScore: masteryScore.clamp(0.0, 1.0),
        correctStreak: i % 10,
        timesEncountered: 15 + i,
        timesCorrect: 8 + i,
        lastPracticedAt: DateTime.now().subtract(Duration(days: i % 14)),
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }
  
  return result;
}

List<Map<String, dynamic>> _getMockGrammarRecommendations() {
  return [
    {
      'id': const Uuid().v4(),
      'name': 'Using 的 (de)',
      'description': 'You\'ve been struggling with this grammar point',
      'hskLevel': 1,
      'priority': 'high',
    },
    {
      'id': const Uuid().v4(),
      'name': 'Measure Words',
      'description': 'Practice these to improve your fluency',
      'hskLevel': 2,
      'priority': 'medium',
    },
    {
      'id': const Uuid().v4(),
      'name': 'Using 了 (le)',
      'description': 'This is essential for past tense',
      'hskLevel': 1,
      'priority': 'high',
    },
  ];
}

List<Map<String, dynamic>> _getMockVocabularyRecommendations() {
  return [
    {
      'id': const Uuid().v4(),
      'characters': '餐厅',
      'pinyin': 'cān tīng',
      'english': 'restaurant',
      'description': 'You\'ll need this for ordering food',
      'hskLevel': 1,
      'priority': 'high',
    },
    {
      'id': const Uuid().v4(),
      'characters': '衣服',
      'pinyin': 'yī fu',
      'english': 'clothes',
      'description': 'Useful for shopping scenarios',
      'hskLevel': 1,
      'priority': 'medium',
    },
    {
      'id': const Uuid().v4(),
      'characters': '朋友',
      'pinyin': 'péng yǒu',
      'english': 'friend',
      'description': 'Common word in conversations',
      'hskLevel': 1,
      'priority': 'medium',
    },
  ];
}

List<Map<String, dynamic>> _getMockScenarioRecommendations() {
  return [
    {
      'id': const Uuid().v4(),
      'name': 'Ordering at a Restaurant',
      'description': 'Practice food vocabulary and ordering phrases',
      'hskLevel': 1,
      'priority': 'high',
    },
    {
      'id': const Uuid().v4(),
      'name': 'Shopping for Clothes',
      'description': 'Learn to ask about sizes and prices',
      'hskLevel': 2,
      'priority': 'medium',
    },
    {
      'id': const Uuid().v4(),
      'name': 'Making Friends',
      'description': 'Practice introducing yourself and making small talk',
      'hskLevel': 1,
      'priority': 'medium',
    },
  ];
}
