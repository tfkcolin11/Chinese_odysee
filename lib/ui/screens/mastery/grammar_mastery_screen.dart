import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for displaying grammar mastery
class GrammarMasteryScreen extends ConsumerStatefulWidget {
  /// Creates a new [GrammarMasteryScreen] instance
  const GrammarMasteryScreen({super.key});

  @override
  ConsumerState<GrammarMasteryScreen> createState() => _GrammarMasteryScreenState();
}

class _GrammarMasteryScreenState extends ConsumerState<GrammarMasteryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedHskLevel = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedHskLevel = _tabController.index + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grammarPointsAsync = ref.watch(grammarPointsProvider(_selectedHskLevel));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Grammar Mastery',
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'HSK 1'),
            Tab(text: 'HSK 2'),
            Tab(text: 'HSK 3'),
            Tab(text: 'HSK 4'),
            Tab(text: 'HSK 5'),
            Tab(text: 'HSK 6'),
          ],
        ),
      ),
      body: grammarPointsAsync.when(
        data: (grammarPoints) => _buildGrammarList(context, grammarPoints),
        loading: () => const LoadingIndicator(showText: true),
        error: (error, stackTrace) => ErrorDisplay(
          message: 'Failed to load grammar points: ${error.toString()}',
          onRetry: () => ref.refresh(grammarPointsProvider(_selectedHskLevel)),
        ),
      ),
    );
  }

  Widget _buildGrammarList(BuildContext context, List<GrammarPoint> grammarPoints) {
    if (grammarPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No grammar points found for HSK $_selectedHskLevel',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grammarPoints.length,
      itemBuilder: (context, index) {
        final grammarPoint = grammarPoints[index];
        return _buildGrammarCard(context, grammarPoint);
      },
    );
  }

  Widget _buildGrammarCard(BuildContext context, GrammarPoint grammarPoint) {
    // Mock mastery data
    final masteryScore = _getMockMasteryScore(grammarPoint.grammarPointId);
    final masteryLevel = _getMasteryLevel(masteryScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                grammarPoint.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _buildMasteryBadge(context, masteryLevel),
          ],
        ),
        subtitle: Text(
          'Mastery: ${(masteryScore * 100).toInt()}%',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (grammarPoint.descriptionHtml != null) ...[
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(grammarPoint.descriptionHtml!),
                  const SizedBox(height: 16),
                ],
                if (grammarPoint.exampleSentenceChinese != null) ...[
                  Text(
                    'Example:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    grammarPoint.exampleSentenceChinese!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (grammarPoint.exampleSentencePinyin != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      grammarPoint.exampleSentencePinyin!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (grammarPoint.exampleSentenceTranslation != null) ...[
                    const SizedBox(height: 4),
                    Text(grammarPoint.exampleSentenceTranslation!),
                  ],
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Practice History:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Used ${_getMockTimesUsed(grammarPoint.grammarPointId)} times',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: masteryScore,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getMasteryColor(masteryLevel),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to practice screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Practice This Point'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryBadge(BuildContext context, String masteryLevel) {
    Color badgeColor;
    switch (masteryLevel) {
      case 'Beginner':
        badgeColor = Colors.red;
        break;
      case 'Intermediate':
        badgeColor = Colors.orange;
        break;
      case 'Advanced':
        badgeColor = Colors.green;
        break;
      case 'Master':
        badgeColor = Colors.blue;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        masteryLevel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  double _getMockMasteryScore(String grammarPointId) {
    // Generate a deterministic but seemingly random score based on the ID
    final hashCode = grammarPointId.hashCode;
    return (hashCode % 100) / 100;
  }

  int _getMockTimesUsed(String grammarPointId) {
    // Generate a deterministic but seemingly random count based on the ID
    final hashCode = grammarPointId.hashCode;
    return (hashCode % 20) + 1;
  }

  String _getMasteryLevel(double masteryScore) {
    if (masteryScore < 0.25) {
      return 'Beginner';
    } else if (masteryScore < 0.5) {
      return 'Intermediate';
    } else if (masteryScore < 0.75) {
      return 'Advanced';
    } else {
      return 'Master';
    }
  }

  Color _getMasteryColor(String masteryLevel) {
    switch (masteryLevel) {
      case 'Beginner':
        return Colors.red;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.green;
      case 'Master':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
