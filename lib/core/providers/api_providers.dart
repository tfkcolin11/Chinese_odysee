import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/services/api/api_services.dart';

/// Provider for the API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    baseUrl: 'https://your-api-domain.com/v1',
  );
});

/// Provider for the user service
final userServiceProvider = Provider<UserService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
});

/// Provider for the HSK service
final hskServiceProvider = Provider<HskService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return HskService(apiService);
});

/// Provider for the scenario service
final scenarioServiceProvider = Provider<ScenarioService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ScenarioService(apiService);
});

/// Provider for the conversation service
final conversationServiceProvider = Provider<ConversationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ConversationService(apiService);
});

/// Provider for the speech service
final speechServiceProvider = Provider<SpeechService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SpeechService(apiService);
});

/// Provider for the recommendations service
final recommendationsServiceProvider = Provider<RecommendationsService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RecommendationsService(apiService);
});
