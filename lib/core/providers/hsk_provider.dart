import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/api_providers.dart';

/// Provider for HSK levels
final hskLevelsProvider = FutureProvider<List<HskLevel>>((ref) async {
  final hskService = ref.watch(hskServiceProvider);
  return hskService.getHskLevels();
});

/// Provider for grammar points by HSK level
final grammarPointsProvider = FutureProvider.family<List<GrammarPoint>, int?>((ref, hskLevelId) async {
  final hskService = ref.watch(hskServiceProvider);
  return hskService.getGrammarPoints(hskLevelId: hskLevelId);
});

/// Provider for vocabulary by HSK level
final vocabularyProvider = FutureProvider.family<List<Vocabulary>, int?>((ref, hskLevelId) async {
  final hskService = ref.watch(hskServiceProvider);
  return hskService.getVocabulary(hskLevelId: hskLevelId);
});
