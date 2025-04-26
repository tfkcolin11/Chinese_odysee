import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/providers/api_providers.dart';
import 'package:chinese_odysee/core/repositories/conversation_repository.dart';
import 'package:chinese_odysee/core/repositories/scenario_repository.dart';
import 'package:chinese_odysee/core/repositories/user_repository.dart';
import 'package:chinese_odysee/core/services/connectivity/connectivity_service.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';

/// Provider for the storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  final storageService = StorageService();
  ref.onDispose(() {
    storageService.close();
  });
  return storageService;
});

/// Provider for the connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivityService = ConnectivityService();
  ref.onDispose(() {
    connectivityService.dispose();
  });
  return connectivityService;
});

/// Provider for the connectivity status
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

/// Provider for the user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final userService = ref.watch(userServiceProvider);
  
  return UserRepository(
    apiService: apiService,
    storageService: storageService,
    userService: userService,
  );
});

/// Provider for the scenario repository
final scenarioRepositoryProvider = Provider<ScenarioRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final scenarioService = ref.watch(scenarioServiceProvider);
  
  return ScenarioRepository(
    apiService: apiService,
    storageService: storageService,
    scenarioService: scenarioService,
  );
});

/// Provider for the conversation repository
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final conversationService = ref.watch(conversationServiceProvider);
  
  return ConversationRepository(
    apiService: apiService,
    storageService: storageService,
    conversationService: conversationService,
  );
});
