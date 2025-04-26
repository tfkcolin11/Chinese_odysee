import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for displaying vocabulary mastery
class VocabularyMasteryScreen extends ConsumerStatefulWidget {
  /// Creates a new [VocabularyMasteryScreen] instance
  const VocabularyMasteryScreen({super.key});

  @override
  ConsumerState<VocabularyMasteryScreen> createState() => _VocabularyMasteryScreenState();
}

class _VocabularyMasteryScreenState extends ConsumerState<VocabularyMasteryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedHskLevel = 1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyAsync = ref.watch(vocabularyProvider(_selectedHskLevel));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Vocabulary Mastery',
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vocabulary',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Vocabulary list
          Expanded(
            child: vocabularyAsync.when(
              data: (vocabulary) => _buildVocabularyList(context, vocabulary),
              loading: () => const LoadingIndicator(showText: true),
              error: (error, stackTrace) => ErrorDisplay(
                message: 'Failed to load vocabulary: ${error.toString()}',
                onRetry: () => ref.refresh(vocabularyProvider(_selectedHskLevel)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyList(BuildContext context, List<Vocabulary> vocabulary) {
    // Filter vocabulary based on search query
    final filteredVocabulary = _searchQuery.isEmpty
        ? vocabulary
        : vocabulary.where((item) {
            return item.characters.contains(_searchQuery) ||
                item.pinyin.contains(_searchQuery) ||
                item.englishTranslation.contains(_searchQuery);
          }).toList();

    if (filteredVocabulary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.translate,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No vocabulary found for HSK $_selectedHskLevel'
                  : 'No vocabulary matching "$_searchQuery"',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredVocabulary.length,
      itemBuilder: (context, index) {
        final vocabularyItem = filteredVocabulary[index];
        return _buildVocabularyCard(context, vocabularyItem);
      },
    );
  }

  Widget _buildVocabularyCard(BuildContext context, Vocabulary vocabulary) {
    // Mock mastery data
    final masteryScore = _getMockMasteryScore(vocabulary.vocabularyId);
    final masteryLevel = _getMasteryLevel(masteryScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showVocabularyDetails(context, vocabulary, masteryScore, masteryLevel),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chinese characters
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocabulary.characters,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vocabulary.pinyin,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              // English translation
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocabulary.englishTranslation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (vocabulary.partOfSpeech != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        vocabulary.partOfSpeech!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Mastery badge
              _buildMasteryBadge(context, masteryLevel),
            ],
          ),
        ),
      ),
    );
  }

  void _showVocabularyDetails(
    BuildContext context,
    Vocabulary vocabulary,
    double masteryScore,
    String masteryLevel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with character and pinyin
                  Center(
                    child: Column(
                      children: [
                        Text(
                          vocabulary.characters,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vocabulary.pinyin,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Meaning and part of speech
                  Text(
                    'Meaning:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vocabulary.englishTranslation,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (vocabulary.partOfSpeech != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Part of Speech: ${vocabulary.partOfSpeech}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Mastery information
                  Text(
                    'Mastery:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: masteryScore,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getMasteryColor(masteryLevel),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(masteryScore * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _getMasteryColor(masteryLevel),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level: $masteryLevel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Times practiced: ${_getMockTimesUsed(vocabulary.vocabularyId)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Last practiced: ${_getMockLastPracticed()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Example sentences
                  Text(
                    'Example Sentences:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildExampleSentence(
                    context,
                    '${vocabulary.characters}很好吃。',
                    '${vocabulary.pinyin} hěn hǎo chī.',
                    'The ${vocabulary.englishTranslation} is delicious.',
                  ),
                  const SizedBox(height: 8),
                  _buildExampleSentence(
                    context,
                    '我喜欢${vocabulary.characters}。',
                    'Wǒ xǐhuān ${vocabulary.pinyin}.',
                    'I like the ${vocabulary.englishTranslation}.',
                  ),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Play pronunciation
                          },
                          icon: const Icon(Icons.volume_up),
                          label: const Text('Pronunciation'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to practice screen
                          },
                          icon: const Icon(Icons.school),
                          label: const Text('Practice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExampleSentence(
    BuildContext context,
    String chinese,
    String pinyin,
    String english,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chinese,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pinyin,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(english),
          ],
        ),
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

  double _getMockMasteryScore(String vocabularyId) {
    // Generate a deterministic but seemingly random score based on the ID
    final hashCode = vocabularyId.hashCode;
    return (hashCode % 100) / 100;
  }

  int _getMockTimesUsed(String vocabularyId) {
    // Generate a deterministic but seemingly random count based on the ID
    final hashCode = vocabularyId.hashCode;
    return (hashCode % 20) + 1;
  }

  String _getMockLastPracticed() {
    // Generate a random recent date
    final now = DateTime.now();
    final daysAgo = now.hashCode % 14; // 0-13 days ago
    final date = now.subtract(Duration(days: daysAgo));
    return '${date.day}/${date.month}/${date.year}';
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
