import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/pre_learning_content.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/repositories/pre_learning_repository.dart';
import 'package:chinese_odysee/core/services/api/pre_learning_service.dart';

/// Provider for the pre-learning service
final preLearningServiceProvider = Provider<PreLearningService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PreLearningService(apiService);
});

/// Provider for the pre-learning repository
final preLearningRepositoryProvider = Provider<PreLearningRepository>((ref) {
  final preLearningService = ref.watch(preLearningServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  
  return PreLearningRepository(
    preLearningService: preLearningService,
    storageService: storageService,
  );
});

/// Provider for pre-learning content for a specific scenario and HSK level
final preLearningContentProvider = FutureProvider.family<PreLearningContent, PreLearningParams>((ref, params) async {
  final repository = ref.watch(preLearningRepositoryProvider);
  return repository.getPreLearningContent(
    scenarioId: params.scenarioId,
    hskLevelId: params.hskLevelId,
  );
});

/// Parameters for pre-learning content provider
class PreLearningParams {
  /// ID of the scenario
  final String scenarioId;
  
  /// HSK level ID
  final int hskLevelId;

  /// Creates a new [PreLearningParams] instance
  const PreLearningParams({
    required this.scenarioId,
    required this.hskLevelId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreLearningParams &&
        other.scenarioId == scenarioId &&
        other.hskLevelId == hskLevelId;
  }

  @override
  int get hashCode => scenarioId.hashCode ^ hskLevelId.hashCode;
}

/// Notifier for managing pre-learning content
class PreLearningNotifier extends StateNotifier<AsyncValue<PreLearningContent?>> {
  /// Pre-learning repository
  final PreLearningRepository _repository;
  
  /// Scenario ID
  final String _scenarioId;
  
  /// HSK level ID
  final int _hskLevelId;

  /// Creates a new [PreLearningNotifier] instance
  PreLearningNotifier(this._repository, this._scenarioId, this._hskLevelId)
      : super(const AsyncValue.loading()) {
    // Load the initial content
    _loadContent();
  }

  /// Loads the pre-learning content
  Future<void> _loadContent() async {
    try {
      state = const AsyncValue.loading();
      final content = await _repository.getPreLearningContent(
        scenarioId: _scenarioId,
        hskLevelId: _hskLevelId,
      );
      state = AsyncValue.data(content);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refreshes the pre-learning content
  Future<void> refresh() async {
    await _loadContent();
  }
}

/// Provider for the pre-learning notifier
final preLearningNotifierProvider = StateNotifierProvider.family<PreLearningNotifier, AsyncValue<PreLearningContent?>, PreLearningParams>((ref, params) {
  final repository = ref.watch(preLearningRepositoryProvider);
  return PreLearningNotifier(repository, params.scenarioId, params.hskLevelId);
});
