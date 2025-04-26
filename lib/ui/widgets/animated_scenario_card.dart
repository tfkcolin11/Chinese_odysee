import 'package:flutter/material.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/ui/animations/animations.dart';
import 'package:chinese_odysee/ui/screens/conversation_screen.dart';

/// Animated card for displaying a scenario
class AnimatedScenarioCard extends StatelessWidget {
  /// The scenario to display
  final Scenario scenario;
  
  /// The HSK level for the scenario
  final HskLevel hskLevel;
  
  /// Callback for when the scenario is selected
  final Function(Scenario)? onSelected;

  /// Creates a new [AnimatedScenarioCard] instance
  const AnimatedScenarioCard({
    super.key,
    required this.scenario,
    required this.hskLevel,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a unique tag for the hero animation
    final heroTag = 'scenario-${scenario.scenarioId}';
    
    return Hero(
      tag: heroTag,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: animation.drive(
              Tween<double>(begin: 1.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
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
                            style: Theme.of(flightContext).textTheme.titleLarge,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () {
            if (onSelected != null) {
              onSelected!(scenario);
            } else {
              _startConversation(context);
            }
          },
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
      ),
    );
  }

  void _startConversation(BuildContext context) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
