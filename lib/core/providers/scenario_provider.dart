import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/api_providers.dart';
import 'package:chinese_odysee/core/services/api/api_services.dart';

/// Provider for scenarios by type
final scenariosProvider = FutureProvider.family<List<Scenario>, ScenarioType>((ref, type) async {
  final scenarioService = ref.watch(scenarioServiceProvider);
  return scenarioService.getScenarios(type: type);
});

/// Provider for a specific scenario by ID
final scenarioProvider = FutureProvider.family<Scenario, String>((ref, scenarioId) async {
  final scenarioService = ref.watch(scenarioServiceProvider);
  return scenarioService.getScenario(scenarioId);
});
