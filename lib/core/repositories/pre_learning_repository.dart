import 'dart:convert';
import 'package:chinese_odysee/core/models/pre_learning_content.dart';
import 'package:chinese_odysee/core/services/api/pre_learning_service.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';

/// Repository for pre-learning content operations
class PreLearningRepository {
  /// Pre-learning service for API operations
  final PreLearningService _preLearningService;
  
  /// Storage service for local operations
  final StorageService _storageService;
  
  /// Table name in the local database
  static const String _tableName = 'ScenarioPreLearningCache';

  /// Creates a new [PreLearningRepository] instance
  PreLearningRepository({
    required PreLearningService preLearningService,
    required StorageService storageService,
  })  : _preLearningService = preLearningService,
        _storageService = storageService;

  /// Gets pre-learning content for a scenario and HSK level
  /// 
  /// This will first check the local cache, and if not found or expired,
  /// it will fetch from the API
  Future<PreLearningContent> getPreLearningContent({
    required String scenarioId,
    required int hskLevelId,
  }) async {
    try {
      // Try to get from local cache first
      final cachedContent = await getCachedContent(scenarioId, hskLevelId);
      
      if (cachedContent != null) {
        // Check if the cache is still valid (not expired)
        final now = DateTime.now();
        final expiresAt = await _getCacheExpiryTime(scenarioId, hskLevelId);
        
        if (expiresAt != null && expiresAt.isAfter(now)) {
          return cachedContent;
        }
      }
      
      // If not in cache or expired, fetch from API
      final content = await _preLearningService.getPreLearningContent(
        scenarioId: scenarioId,
        hskLevelId: hskLevelId,
      );
      
      // Cache the content
      await cachePreLearningContent(content);
      
      return content;
    } catch (e) {
      // If API call fails but we have cached content, return it even if expired
      if (e is PreLearningException) {
        final cachedContent = await getCachedContent(scenarioId, hskLevelId);
        if (cachedContent != null) {
          return cachedContent;
        }
      }
      
      // Otherwise, rethrow the exception
      rethrow;
    }
  }

  /// Gets cached pre-learning content for a scenario and HSK level
  Future<PreLearningContent?> getCachedContent(
    String scenarioId,
    int hskLevelId,
  ) async {
    try {
      final maps = await _storageService.query(
        _tableName,
        where: 'scenario_id = ? AND hsk_level_id = ?',
        whereArgs: [scenarioId, hskLevelId],
        limit: 1,
      );
      
      if (maps.isEmpty) {
        return null;
      }
      
      final contentJson = maps.first['generated_content_json'] as String;
      final contentMap = jsonDecode(contentJson) as Map<String, dynamic>;
      
      return PreLearningContent.fromMap(contentMap);
    } catch (e) {
      // If there's an error reading from the cache, return null
      return null;
    }
  }

  /// Caches pre-learning content
  Future<void> cachePreLearningContent(PreLearningContent content) async {
    try {
      // Calculate expiry time (e.g., 7 days from now)
      final expiresAt = DateTime.now().add(const Duration(days: 7));
      
      // Convert content to JSON
      final contentJson = jsonEncode(content.toMap());
      
      // Check if a cache entry already exists
      final existingMaps = await _storageService.query(
        _tableName,
        where: 'scenario_id = ? AND hsk_level_id = ?',
        whereArgs: [content.scenarioId, content.hskLevelId],
        limit: 1,
      );
      
      if (existingMaps.isNotEmpty) {
        // Update existing cache entry
        await _storageService.update(
          _tableName,
          {
            'generated_content_json': contentJson,
            'generated_at': content.generatedAt.toIso8601String(),
            'expires_at': expiresAt.toIso8601String(),
          },
          'scenario_id = ? AND hsk_level_id = ?',
          [content.scenarioId, content.hskLevelId],
        );
      } else {
        // Insert new cache entry
        await _storageService.insert(
          _tableName,
          {
            'cache_id': DateTime.now().millisecondsSinceEpoch.toString(),
            'scenario_id': content.scenarioId,
            'hsk_level_id': content.hskLevelId,
            'generated_content_json': contentJson,
            'generated_at': content.generatedAt.toIso8601String(),
            'expires_at': expiresAt.toIso8601String(),
          },
        );
      }
    } catch (e) {
      // If there's an error caching, log it but don't throw
      // This is non-critical functionality
      print('Error caching pre-learning content: $e');
    }
  }

  /// Gets the expiry time for a cached content
  Future<DateTime?> _getCacheExpiryTime(
    String scenarioId,
    int hskLevelId,
  ) async {
    try {
      final maps = await _storageService.query(
        _tableName,
        columns: ['expires_at'],
        where: 'scenario_id = ? AND hsk_level_id = ?',
        whereArgs: [scenarioId, hskLevelId],
        limit: 1,
      );
      
      if (maps.isEmpty) {
        return null;
      }
      
      return DateTime.parse(maps.first['expires_at'] as String);
    } catch (e) {
      return null;
    }
  }

  /// Clears expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      await _storageService.delete(
        _tableName,
        'expires_at < ?',
        [now],
      );
    } catch (e) {
      // If there's an error clearing the cache, log it but don't throw
      print('Error clearing expired cache: $e');
    }
  }
}
