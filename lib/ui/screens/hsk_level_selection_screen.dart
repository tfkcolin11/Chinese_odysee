import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for selecting HSK level
class HskLevelSelectionScreen extends ConsumerWidget {
  /// Creates a new [HskLevelSelectionScreen] instance
  const HskLevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hskLevelsAsync = ref.watch(hskLevelsProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Select HSK Level',
      ),
      body: hskLevelsAsync.when(
        data: (hskLevels) => _buildLevelGrid(context, hskLevels),
        loading: () => const LoadingIndicator(showText: true),
        error: (error, stackTrace) => ErrorDisplay(
          message: 'Failed to load HSK levels: ${error.toString()}',
          onRetry: () => ref.refresh(hskLevelsProvider),
        ),
      ),
    );
  }

  Widget _buildLevelGrid(BuildContext context, List<HskLevel> hskLevels) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your proficiency level',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the HSK level you want to practice',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: hskLevels.length,
              itemBuilder: (context, index) {
                final level = hskLevels[index];
                return _buildLevelCard(context, level);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, HskLevel level) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navigate to scenario selection with the selected HSK level
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScenarioSelectionScreen(hskLevel: level),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                level.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (level.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  level.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
