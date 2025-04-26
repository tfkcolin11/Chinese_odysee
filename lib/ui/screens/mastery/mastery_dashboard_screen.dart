import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/ui/screens/mastery/grammar_mastery_screen.dart';
import 'package:chinese_odysee/ui/screens/mastery/vocabulary_mastery_screen.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for displaying mastery dashboard
class MasteryDashboardScreen extends ConsumerWidget {
  /// Creates a new [MasteryDashboardScreen] instance
  const MasteryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final hskLevelsAsync = ref.watch(hskLevelsProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Learning Progress',
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please log in to view your progress'),
            );
          }

          return hskLevelsAsync.when(
            data: (hskLevels) => _buildDashboard(context, ref, hskLevels),
            loading: () => const LoadingIndicator(showText: true),
            error: (error, stackTrace) => ErrorDisplay(
              message: 'Failed to load HSK levels: ${error.toString()}',
              onRetry: () => ref.refresh(hskLevelsProvider),
            ),
          );
        },
        loading: () => const LoadingIndicator(showText: true),
        error: (error, stackTrace) => ErrorDisplay(
          message: 'Failed to load user: ${error.toString()}',
          onRetry: () => ref.refresh(currentUserProvider),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    List<HskLevel> hskLevels,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall progress card
          _buildOverallProgressCard(context),
          const SizedBox(height: 24),

          // Grammar and vocabulary buttons
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  context,
                  'Grammar',
                  Icons.auto_stories,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrammarMasteryScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryCard(
                  context,
                  'Vocabulary',
                  Icons.translate,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VocabularyMasteryScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // HSK level progress
          _buildSectionHeader(context, 'HSK Level Progress'),
          const SizedBox(height: 8),
          ...hskLevels.map((level) => _buildHskLevelProgress(context, level)),
          const SizedBox(height: 24),

          // Recent activity
          _buildSectionHeader(context, 'Recent Activity'),
          const SizedBox(height: 8),
          _buildRecentActivity(context),
          const SizedBox(height: 24),

          // Recommendations
          _buildSectionHeader(context, 'Recommended Practice'),
          const SizedBox(height: 8),
          _buildRecommendations(context),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressStat(
                    context,
                    'Grammar',
                    '42%',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildProgressStat(
                    context,
                    'Vocabulary',
                    '38%',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildProgressStat(
                    context,
                    'Overall',
                    '40%',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              value: 0.4,
              minHeight: 8,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re making good progress! Keep practicing to improve your mastery.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'View Details',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Expanded(
          child: Divider(
            indent: 16,
            thickness: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildHskLevelProgress(BuildContext context, HskLevel level) {
    // Mock progress values
    final progressValues = {
      1: 0.85,
      2: 0.62,
      3: 0.45,
      4: 0.28,
      5: 0.12,
      6: 0.05,
    };

    final progress = progressValues[level.hskLevelId] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  level.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progress),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    // Mock recent activity data
    final activities = [
      {
        'type': 'conversation',
        'title': 'Ordering at a Restaurant',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'score': 85,
      },
      {
        'type': 'vocabulary',
        'title': 'Learned 5 new words',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'type': 'grammar',
        'title': 'Mastered "Using 了 (le)"',
        'date': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getActivityIcon(activity['type'] as String),
              color: _getActivityColor(activity['type'] as String),
            ),
            title: Text(activity['title'] as String),
            subtitle: Text(
              _formatDate(activity['date'] as DateTime),
            ),
            trailing: activity['score'] != null
                ? Text(
                    'Score: ${activity['score']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    // Mock recommendations
    final recommendations = [
      {
        'type': 'grammar',
        'title': 'Practice "Using 的 (de)"',
        'description': 'You\'ve been struggling with this grammar point',
      },
      {
        'type': 'vocabulary',
        'title': 'Review Restaurant Vocabulary',
        'description': 'These words will help in your next conversation',
      },
      {
        'type': 'scenario',
        'title': 'Try "Shopping for Clothes"',
        'description': 'This scenario uses vocabulary you\'ve been learning',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getActivityIcon(recommendation['type'] as String),
              color: _getActivityColor(recommendation['type'] as String),
            ),
            title: Text(recommendation['title'] as String),
            subtitle: Text(recommendation['description'] as String),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // TODO: Navigate to the recommended activity
            },
          ),
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'conversation':
        return Icons.chat;
      case 'vocabulary':
        return Icons.translate;
      case 'grammar':
        return Icons.auto_stories;
      case 'scenario':
        return Icons.movie;
      default:
        return Icons.star;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'conversation':
        return Colors.blue;
      case 'vocabulary':
        return Colors.green;
      case 'grammar':
        return Colors.purple;
      case 'scenario':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
