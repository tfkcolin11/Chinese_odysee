import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/repositories/conversation_repository.dart';

/// Provider for the active conversation
final activeConversationProvider = StateNotifierProvider<ActiveConversationNotifier, AsyncValue<Conversation?>>((ref) {
  final conversationRepository = ref.watch(conversationRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  // Update the repository's offline mode based on connectivity
  conversationRepository.setOfflineMode(!connectivityService.isConnected);

  // Listen to connectivity changes and update the repository's offline mode
  ref.listen(
    connectivityStatusProvider.select((value) => value.valueOrNull ?? false),
    (_, isConnected) {
      conversationRepository.setOfflineMode(!isConnected);
    },
  );

  return ActiveConversationNotifier(conversationRepository);
});

/// Notifier for the active conversation
class ActiveConversationNotifier extends StateNotifier<AsyncValue<Conversation?>> {
  /// Conversation repository for data operations
  final ConversationRepository _conversationRepository;

  /// Creates a new [ActiveConversationNotifier] instance
  ActiveConversationNotifier(this._conversationRepository) : super(const AsyncValue.data(null));

  /// Starts a new conversation
  Future<ConversationTurn> startConversation({
    required String scenarioId,
    required int hskLevelPlayed,
    String? inspirationSavedInstanceId,
  }) async {
    try {
      state = const AsyncValue.loading();

      final result = await _conversationRepository.startConversation(
        scenarioId: scenarioId,
        hskLevelPlayed: hskLevelPlayed,
        inspirationSavedInstanceId: inspirationSavedInstanceId,
      );

      final conversation = result['conversation'] as Conversation;
      final initialTurn = result['initialTurn'] as ConversationTurn;

      state = AsyncValue.data(conversation);

      return initialTurn;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Submits a user turn and gets the AI's response
  Future<Map<String, dynamic>> submitUserTurn({
    required String inputText,
    required InputMode inputMode,
  }) async {
    try {
      if (!state.hasValue || state.value == null) {
        throw Exception('No active conversation');
      }

      final conversationId = state.value!.conversationId;

      final result = await _conversationRepository.submitUserTurn(
        conversationId: conversationId,
        inputText: inputText,
        inputMode: inputMode,
      );

      // Update the conversation score
      final updatedScore = result['updatedConversationScore'] as int;
      final updatedConversation = state.value!.copyWith(
        currentScore: updatedScore,
      );

      state = AsyncValue.data(updatedConversation);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Ends the active conversation
  Future<void> endConversation() async {
    try {
      if (!state.hasValue || state.value == null) {
        return;
      }

      final conversationId = state.value!.conversationId;
      final endedConversation = await _conversationRepository.endConversation(conversationId);

      state = AsyncValue.data(endedConversation);
    } catch (e) {
      rethrow;
    }
  }

  /// Saves the active conversation
  Future<void> saveConversation({String? savedInstanceName}) async {
    try {
      if (!state.hasValue || state.value == null) {
        throw Exception('No active conversation');
      }

      final conversationId = state.value!.conversationId;
      final savedConversation = await _conversationRepository.saveConversation(
        conversationId: conversationId,
        savedInstanceName: savedInstanceName,
      );

      state = AsyncValue.data(savedConversation);
    } catch (e) {
      rethrow;
    }
  }

  /// Clears the active conversation
  void clearConversation() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for conversation turns
final conversationTurnsProvider = FutureProvider.family<List<ConversationTurn>, String>((ref, conversationId) async {
  final conversationRepository = ref.watch(conversationRepositoryProvider);
  return conversationRepository.getConversationTurns(conversationId);
});
