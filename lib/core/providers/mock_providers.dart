import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/providers/api_providers.dart';
import 'package:chinese_odysee/core/services/api/api_services.dart';
import 'package:chinese_odysee/core/services/mock/mock_api_services.dart';

/// Provider for the mock HSK service
final mockHskServiceProvider = Provider<HskService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MockHskService(apiService);
});

/// Provider for the mock scenario service
final mockScenarioServiceProvider = Provider<ScenarioService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MockScenarioService(apiService);
});

/// Provider for the mock conversation service
final mockConversationServiceProvider = Provider<ConversationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MockConversationService(apiService);
});

/// Override providers for using mock services
final mockProviders = [
  hskServiceProvider.overrideWithProvider(mockHskServiceProvider),
  scenarioServiceProvider.overrideWithProvider(mockScenarioServiceProvider),
  conversationServiceProvider.overrideWithProvider(mockConversationServiceProvider),
];
