import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/services/api/api_services.dart';
import 'package:chinese_odysee/ui/screens/conversation_screen.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for selecting a scenario
class ScenarioSelectionScreen extends ConsumerWidget {
  /// The selected HSK level
  final HskLevel hskLevel;

  /// Creates a new [ScenarioSelectionScreen] instance
  const ScenarioSelectionScreen({
    super.key,
    required this.hskLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenariosProvider(ScenarioType.all));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Scenario - ${hskLevel.name}',
      ),
      body: scenariosAsync.when(
        data: (scenarios) => _buildScenarioList(context, ref, scenarios),
        loading: () => const LoadingIndicator(showText: true),
        error: (error, stackTrace) => ErrorDisplay(
          message: 'Failed to load scenarios: ${error.toString()}',
          onRetry: () => ref.refresh(scenariosProvider(ScenarioType.all)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateScenarioDialog(context),
        tooltip: 'Create Scenario',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScenarioList(
    BuildContext context,
    WidgetRef ref,
    List<Scenario> scenarios,
  ) {
    // Filter scenarios by suggested HSK level if available
    final filteredScenarios = scenarios.where((scenario) {
      return scenario.suggestedHskLevel == null ||
          scenario.suggestedHskLevel == hskLevel.hskLevelId;
    }).toList();

    if (filteredScenarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No scenarios found for ${hskLevel.name}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try creating a custom scenario',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredScenarios.length,
      itemBuilder: (context, index) {
        final scenario = filteredScenarios[index];
        return _buildScenarioCard(context, ref, scenario);
      },
    );
  }

  Widget _buildScenarioCard(
    BuildContext context,
    WidgetRef ref,
    Scenario scenario,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _startConversation(context, ref, scenario),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      scenario.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (scenario.isPredefined)
                    const Chip(
                      label: Text('Predefined'),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white),
                    )
                  else
                    const Chip(
                      label: Text('Custom'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                scenario.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${_formatDate(scenario.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (scenario.lastUsedAt != null)
                    Text(
                      'Last used: ${_formatDate(scenario.lastUsedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startConversation(
    BuildContext context,
    WidgetRef ref,
    Scenario scenario,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingIndicator(),
            SizedBox(height: 16),
            Text('Starting conversation...'),
          ],
        ),
      ),
    );

    try {
      // Start a new conversation
      final conversationNotifier = ref.read(activeConversationProvider.notifier);
      final initialTurn = await conversationNotifier.startConversation(
        scenarioId: scenario.scenarioId,
        hskLevelPlayed: hskLevel.hskLevelId,
      );

      // Close loading dialog and navigate to conversation screen
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              initialTurn: initialTurn,
              hskLevel: hskLevel,
              scenario: scenario,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start conversation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateScenarioDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Scenario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Scenario Name',
                  hintText: 'e.g., Ordering at a Restaurant',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the scenario in detail',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: () => _createScenario(
                  context,
                  ref,
                  nameController.text,
                  descriptionController.text,
                ),
                child: const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _createScenario(
    BuildContext context,
    WidgetRef ref,
    String name,
    String description,
  ) async {
    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Close the dialog
      Navigator.pop(context);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingIndicator(),
              SizedBox(height: 16),
              Text('Creating scenario...'),
            ],
          ),
        ),
      );

      // Create the scenario
      final scenarioService = ref.read(scenarioServiceProvider);
      await scenarioService.createScenario(
        name: name,
        description: description,
        suggestedHskLevel: hskLevel.hskLevelId,
      );

      // Refresh the scenarios list
      ref.refresh(scenariosProvider(ScenarioType.all));

      // Close loading dialog and show success message
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scenario created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create scenario: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
