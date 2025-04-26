import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/services/api/api_services.dart';
import 'package:chinese_odysee/core/services/subscription/subscription_service.dart';
import 'package:chinese_odysee/ui/animations/animations.dart';
import 'package:chinese_odysee/ui/screens/conversation_screen.dart';
import 'package:chinese_odysee/ui/screens/pre_learning_screen.dart';
import 'package:chinese_odysee/ui/screens/subscription_screen.dart';
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
    return AnimatedScenarioCard(
      scenario: scenario,
      hskLevel: hskLevel,
      onSelected: (selectedScenario) => _startConversation(context, ref, selectedScenario),
    );
  }

  void _startConversation(
    BuildContext context,
    WidgetRef ref,
    Scenario scenario,
  ) async {
    // Show options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Learning'),
        content: const Text(
          'Would you like to review vocabulary and grammar for this scenario before starting the conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startDirectConversation(context, ref, scenario);
            },
            child: const Text('Start Conversation'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPreLearning(context, scenario);
            },
            child: const Text('Learn & Practice First'),
          ),
        ],
      ),
    );
  }

  void _navigateToPreLearning(BuildContext context, Scenario scenario) {
    // Check if the user has access to pre-learning
    // This would normally be done through the subscription provider
    // For now, we'll just navigate to the pre-learning screen

    context.navigateWithTransition(
      PreLearningScreen(
        scenario: scenario,
        hskLevel: hskLevel,
      ),
      type: PageTransitionType.fadeAndScale,
    );
  }

  void _startDirectConversation(
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
        context.navigateWithTransition(
          ConversationScreen(
            initialTurn: initialTurn,
            hskLevel: hskLevel,
            scenario: scenario,
          ),
          type: PageTransitionType.fadeAndScale,
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
      final _ = ref.refresh(scenariosProvider(ScenarioType.all));

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


}
