import 'dart:convert';
import 'package:chinese_odysee/core/models/subscription_status.dart';
import 'package:chinese_odysee/core/models/usage_limits.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';
import 'package:chinese_odysee/core/services/subscription/subscription_service.dart';

/// Repository for subscription-related operations
class SubscriptionRepository {
  /// Subscription service for API operations
  final SubscriptionService _subscriptionService;
  
  /// Storage service for local operations
  final StorageService _storageService;
  
  /// Table name for subscriptions in the local database
  static const String _subscriptionTableName = 'UserSubscriptions';
  
  /// Table name for usage limits in the local database
  static const String _usageLimitsTableName = 'UserUsageTracking';
  
  /// Key for storing the last subscription check time
  static const String _lastSubscriptionCheckKey = 'last_subscription_check';

  /// Creates a new [SubscriptionRepository] instance
  SubscriptionRepository({
    required SubscriptionService subscriptionService,
    required StorageService storageService,
  })  : _subscriptionService = subscriptionService,
        _storageService = storageService;

  /// Gets the current user's subscription status
  /// 
  /// This will first check the local cache, and if it's too old,
  /// it will fetch from the API
  Future<UserSubscription> getCurrentSubscription() async {
    try {
      // Check if we need to refresh from the API
      final shouldRefresh = await _shouldRefreshSubscription();
      
      if (shouldRefresh) {
        // Fetch from API
        final subscription = await _subscriptionService.getCurrentSubscription();
        
        // Cache the subscription
        await _cacheSubscription(subscription);
        
        // Update the last check time
        await _updateLastSubscriptionCheckTime();
        
        return subscription;
      } else {
        // Get from cache
        final cachedSubscription = await _getCachedSubscription();
        
        if (cachedSubscription != null) {
          return cachedSubscription;
        }
        
        // If not in cache, fetch from API
        final subscription = await _subscriptionService.getCurrentSubscription();
        
        // Cache the subscription
        await _cacheSubscription(subscription);
        
        // Update the last check time
        await _updateLastSubscriptionCheckTime();
        
        return subscription;
      }
    } catch (e) {
      // If API call fails but we have cached subscription, return it
      final cachedSubscription = await _getCachedSubscription();
      
      if (cachedSubscription != null) {
        return cachedSubscription;
      }
      
      // Otherwise, create a default free subscription
      return UserSubscription(
        subscriptionId: 'default',
        userId: 'current_user',
        planType: PlanType.free,
        status: SubscriptionStatus.active,
        store: SubscriptionStore.none,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Gets the current user's usage limits
  Future<UsageLimits> getUsageLimits() async {
    try {
      // Try to get from API first
      final limits = await _subscriptionService.getUsageLimits();
      
      // Cache the limits
      await _cacheUsageLimits(limits);
      
      return limits;
    } catch (e) {
      // If API call fails, try to get from cache
      final cachedLimits = await _getCachedUsageLimits();
      
      if (cachedLimits != null) {
        return cachedLimits;
      }
      
      // If not in cache, create default limits for free tier
      return UsageLimits(
        userId: 'current_user',
        periodStartTimestamp: DateTime.now(),
        dailyTurnsLimit: 30, // Default limit for free tier
        dailyTurnsUsed: 0,
        dailyPrelearnLimit: 5, // Default limit for free tier
        dailyPrelearnUsed: 0,
        customScenarioLimit: 3, // Default limit for free tier
        customScenariosCreated: 0,
        savedInstanceLimit: 5, // Default limit for free tier
        instancesSaved: 0,
      );
    }
  }

  /// Validates a purchase receipt from the app store
  Future<UserSubscription> validateReceipt({
    required SubscriptionStore store,
    required dynamic receiptData,
  }) async {
    final subscription = await _subscriptionService.validateReceipt(
      store: store,
      receiptData: receiptData,
    );
    
    // Cache the subscription
    await _cacheSubscription(subscription);
    
    // Update the last check time
    await _updateLastSubscriptionCheckTime();
    
    return subscription;
  }

  /// Restores purchases from the app store
  Future<UserSubscription> restorePurchases() async {
    final subscription = await _subscriptionService.restorePurchases();
    
    // Cache the subscription
    await _cacheSubscription(subscription);
    
    // Update the last check time
    await _updateLastSubscriptionCheckTime();
    
    return subscription;
  }

  /// Checks if the user has access to a premium feature
  Future<bool> checkFeatureAccess(FeatureType featureType) async {
    try {
      // First check with the service (which will check with the API)
      return await _subscriptionService.checkFeatureAccess(featureType);
    } catch (e) {
      // If API call fails, check locally
      final subscription = await _getCachedSubscription();
      
      // If the user has a premium subscription, they have access to all features
      if (subscription != null && subscription.isPremium) {
        return true;
      }
      
      // For free users, check usage limits for specific features
      if (featureType == FeatureType.conversationTurn ||
          featureType == FeatureType.preLearning ||
          featureType == FeatureType.customScenario ||
          featureType == FeatureType.saveInstance) {
        final limits = await _getCachedUsageLimits();
        
        if (limits != null) {
          switch (featureType) {
            case FeatureType.conversationTurn:
              return !limits.hasDailyTurnsLimitReached;
            case FeatureType.preLearning:
              return !limits.hasDailyPrelearnLimitReached;
            case FeatureType.customScenario:
              return !limits.hasCustomScenarioLimitReached;
            case FeatureType.saveInstance:
              return !limits.hasSavedInstanceLimitReached;
            default:
              return false;
          }
        }
      }
      
      // For other features, free users don't have access
      return false;
    }
  }

  /// Increments the usage count for a specific feature
  Future<void> incrementUsage(FeatureType featureType) async {
    try {
      // Get current limits
      final limits = await getUsageLimits();
      
      // Create updated limits based on feature type
      UsageLimits updatedLimits;
      
      switch (featureType) {
        case FeatureType.conversationTurn:
          updatedLimits = limits.copyWith(
            dailyTurnsUsed: limits.dailyTurnsUsed + 1,
          );
          break;
        case FeatureType.preLearning:
          updatedLimits = limits.copyWith(
            dailyPrelearnUsed: limits.dailyPrelearnUsed + 1,
          );
          break;
        case FeatureType.customScenario:
          updatedLimits = limits.copyWith(
            customScenariosCreated: limits.customScenariosCreated + 1,
          );
          break;
        case FeatureType.saveInstance:
          updatedLimits = limits.copyWith(
            instancesSaved: limits.instancesSaved + 1,
          );
          break;
        default:
          // No usage to increment for other feature types
          return;
      }
      
      // Cache the updated limits
      await _cacheUsageLimits(updatedLimits);
      
      // Try to update on the server (but don't wait for it)
      _updateUsageOnServer(featureType).catchError((_) {
        // Ignore errors, we've already updated locally
      });
    } catch (e) {
      // If there's an error, log it but don't throw
      print('Error incrementing usage: $e');
    }
  }

  /// Updates usage on the server
  Future<void> _updateUsageOnServer(FeatureType featureType) async {
    // This would call an API endpoint to update usage on the server
    // For now, we'll just simulate it
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Checks if we should refresh the subscription from the API
  Future<bool> _shouldRefreshSubscription() async {
    try {
      final lastCheckTimeStr = _storageService.getString(_lastSubscriptionCheckKey);
      
      if (lastCheckTimeStr == null) {
        return true;
      }
      
      final lastCheckTime = DateTime.parse(lastCheckTimeStr);
      final now = DateTime.now();
      
      // Refresh if it's been more than 1 hour since the last check
      return now.difference(lastCheckTime).inHours >= 1;
    } catch (e) {
      return true;
    }
  }

  /// Updates the last subscription check time
  Future<void> _updateLastSubscriptionCheckTime() async {
    await _storageService.setString(
      _lastSubscriptionCheckKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Gets the cached subscription
  Future<UserSubscription?> _getCachedSubscription() async {
    try {
      final maps = await _storageService.query(
        _subscriptionTableName,
        limit: 1,
      );
      
      if (maps.isEmpty) {
        return null;
      }
      
      return UserSubscription.fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  /// Caches a subscription
  Future<void> _cacheSubscription(UserSubscription subscription) async {
    try {
      // Check if a subscription already exists
      final existingMaps = await _storageService.query(
        _subscriptionTableName,
        limit: 1,
      );
      
      if (existingMaps.isNotEmpty) {
        // Update existing subscription
        await _storageService.update(
          _subscriptionTableName,
          subscription.toMap(),
          'subscription_id = ?',
          [existingMaps.first['subscriptionId']],
        );
      } else {
        // Insert new subscription
        await _storageService.insert(
          _subscriptionTableName,
          subscription.toMap(),
        );
      }
    } catch (e) {
      // If there's an error caching, log it but don't throw
      print('Error caching subscription: $e');
    }
  }

  /// Gets the cached usage limits
  Future<UsageLimits?> _getCachedUsageLimits() async {
    try {
      final maps = await _storageService.query(
        _usageLimitsTableName,
        where: 'period_type = ?',
        whereArgs: ['daily'],
        limit: 1,
      );
      
      if (maps.isEmpty) {
        return null;
      }
      
      // Check if the period has reset
      final periodStart = DateTime.parse(maps.first['period_start_timestamp'] as String);
      final now = DateTime.now();
      
      // If it's a new day, reset the daily counts
      if (now.day != periodStart.day || now.month != periodStart.month || now.year != periodStart.year) {
        final resetLimits = UsageLimits(
          userId: maps.first['user_id'] as String,
          periodStartTimestamp: now,
          dailyTurnsLimit: maps.first['daily_turns_limit'] as int?,
          dailyTurnsUsed: 0, // Reset to 0
          dailyPrelearnLimit: maps.first['daily_prelearn_limit'] as int?,
          dailyPrelearnUsed: 0, // Reset to 0
          customScenarioLimit: maps.first['custom_scenario_limit'] as int?,
          customScenariosCreated: maps.first['custom_scenarios_created'] as int,
          savedInstanceLimit: maps.first['saved_instance_limit'] as int?,
          instancesSaved: maps.first['instances_saved'] as int,
        );
        
        // Cache the reset limits
        await _cacheUsageLimits(resetLimits);
        
        return resetLimits;
      }
      
      return UsageLimits.fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  /// Caches usage limits
  Future<void> _cacheUsageLimits(UsageLimits limits) async {
    try {
      // Check if limits already exist
      final existingMaps = await _storageService.query(
        _usageLimitsTableName,
        where: 'user_id = ? AND period_type = ?',
        whereArgs: [limits.userId, 'daily'],
        limit: 1,
      );
      
      if (existingMaps.isNotEmpty) {
        // Update existing limits
        await _storageService.update(
          _usageLimitsTableName,
          {
            'period_start_timestamp': limits.periodStartTimestamp.toIso8601String(),
            'daily_turns_limit': limits.dailyTurnsLimit,
            'daily_turns_used': limits.dailyTurnsUsed,
            'daily_prelearn_limit': limits.dailyPrelearnLimit,
            'daily_prelearn_used': limits.dailyPrelearnUsed,
            'custom_scenario_limit': limits.customScenarioLimit,
            'custom_scenarios_created': limits.customScenariosCreated,
            'saved_instance_limit': limits.savedInstanceLimit,
            'instances_saved': limits.instancesSaved,
            'updated_at': DateTime.now().toIso8601String(),
          },
          'user_id = ? AND period_type = ?',
          [limits.userId, 'daily'],
        );
      } else {
        // Insert new limits
        await _storageService.insert(
          _usageLimitsTableName,
          {
            'tracking_id': DateTime.now().millisecondsSinceEpoch.toString(),
            'user_id': limits.userId,
            'period_type': 'daily',
            'period_start_timestamp': limits.periodStartTimestamp.toIso8601String(),
            'daily_turns_limit': limits.dailyTurnsLimit,
            'daily_turns_used': limits.dailyTurnsUsed,
            'daily_prelearn_limit': limits.dailyPrelearnLimit,
            'daily_prelearn_used': limits.dailyPrelearnUsed,
            'custom_scenario_limit': limits.customScenarioLimit,
            'custom_scenarios_created': limits.customScenariosCreated,
            'saved_instance_limit': limits.savedInstanceLimit,
            'instances_saved': limits.instancesSaved,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      // If there's an error caching, log it but don't throw
      print('Error caching usage limits: $e');
    }
  }
}
