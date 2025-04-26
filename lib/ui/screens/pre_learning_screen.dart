import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/models/pre_learning_content.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/services/subscription/subscription_service.dart';
import 'package:chinese_odysee/ui/animations/animations.dart';
import 'package:chinese_odysee/ui/screens/conversation_screen.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for pre-conversation learning
class PreLearningScreen extends ConsumerWidget {
  /// The scenario to learn about
  final Scenario scenario;
  
  /// The HSK level for the scenario
  final HskLevel hskLevel;

  /// Creates a new [PreLearningScreen] instance
  const PreLearningScreen({
    super.key,
    required this.scenario,
    required this.hskLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if the user has access to this feature
    final featureAccessAsync = ref.watch(featureAccessProvider(FeatureType.preLearning));
    
    // Get the pre-learning content
    final preLearningParams = PreLearningParams(
      scenarioId: scenario.scenarioId,
      hskLevelId: hskLevel.hskLevelId,
    );
    final preLearningAsync = ref.watch(preLearningContentProvider(preLearningParams));
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Learn & Practice',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(preLearningContentProvider(preLearningParams));
            },
            tooltip: 'Refresh content',
          ),
        ],
      ),
      body: featureAccessAsync.when(
        data: (hasAccess) {
          if (!hasAccess) {
            return _buildPremiumRequired(context, ref);
          }
          
          return preLearningAsync.when(
            data: (content) => _buildContent(context, ref, content),
            loading: () => const LoadingIndicator(message: 'Generating learning content...'),
            error: (error, stack) => ErrorDisplay(
              error: error.toString(),
              onRetry: () {
                ref.refresh(preLearningContentProvider(preLearningParams));
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Checking access...'),
        error: (error, stack) => ErrorDisplay(
          error: 'Failed to check feature access: ${error.toString()}',
          onRetry: () {
            ref.refresh(featureAccessProvider(FeatureType.preLearning));
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _startConversation(context, ref),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Start Conversation'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PreLearningContent content,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildVocabularySection(context, content.vocabulary),
          const SizedBox(height: 32),
          _buildGrammarSection(context, content.grammarPoints),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          scenario.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'HSK Level ${hskLevel.hskLevelId}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          scenario.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        const Text(
          'Review these vocabulary words and grammar points before starting the conversation. This will help you communicate more effectively.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildVocabularySection(
    BuildContext context,
    List<VocabularyItem> vocabulary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.book,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Key Vocabulary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vocabulary.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = vocabulary[index];
              return ListTile(
                title: Row(
                  children: [
                    Text(
                      item.characters,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.pinyin,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(item.translation),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    // TODO: Implement text-to-speech for vocabulary
                  },
                  tooltip: 'Listen',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarSection(
    BuildContext context,
    List<GrammarPoint> grammarPoints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Grammar Points',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grammarPoints.length,
          itemBuilder: (context, index) {
            final item = grammarPoints[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.explanation),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.format_quote),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.example,
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPremiumRequired(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Premium Feature',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Pre-learning content for custom scenarios is only available with a premium subscription.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to subscription screen
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Upgrade to Premium'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _startConversation(context, ref),
              child: const Text('Continue Without Learning'),
            ),
          ],
        ),
      ),
    );
  }

  void _startConversation(BuildContext context, WidgetRef ref) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Starting conversation...'),
          ],
        ),
      ),
    );

    // In a real app, this would call the API to start a conversation
    // For now, we'll just simulate a delay
    Future.delayed(const Duration(seconds: 1), () {
      // Close loading dialog and navigate to conversation screen
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Create a mock initial turn
        final initialTurn = ConversationTurn(
          turnId: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: 'mock-conversation-id',
          turnNumber: 1,
          timestamp: DateTime.now(),
          speaker: Speaker.ai,
          aiResponseText: '你好！欢迎来到中文学习之旅。我是你的AI语言伙伴。我们今天要练习${scenario.name}。',
        );
        
        // Navigate to conversation screen
        context.navigateWithTransition(
          ConversationScreen(
            initialTurn: initialTurn,
            hskLevel: hskLevel,
            scenario: scenario,
          ),
          type: PageTransitionType.fadeAndScale,
        );
      }
    });
  }
}
