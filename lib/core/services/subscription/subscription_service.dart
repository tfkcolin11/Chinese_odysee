import 'dart:convert';
import 'package:chinese_odysee/core/models/subscription_status.dart';
import 'package:chinese_odysee/core/models/usage_limits.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';

/// Service for subscription-related operations
class SubscriptionService {
  /// API service for remote operations
  final ApiService _apiService;

  /// Creates a new [SubscriptionService] instance
  SubscriptionService(this._apiService);

  /// Gets the current user's subscription status
  Future<UserSubscription> getCurrentSubscription() async {
    try {
      final response = await _apiService.get('/users/me/subscription');
      
      return UserSubscription.fromMap(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      throw SubscriptionException(
        'Failed to get subscription status: ${e.toString()}',
        SubscriptionErrorType.unknown,
      );
    }
  }

  /// Gets the current user's usage limits
  Future<UsageLimits> getUsageLimits() async {
    try {
      final response = await _apiService.get('/users/me/usage-limits');
      
      return UsageLimits.fromMap(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      throw SubscriptionException(
        'Failed to get usage limits: ${e.toString()}',
        SubscriptionErrorType.unknown,
      );
    }
  }

  /// Validates a purchase receipt from the app store
  /// 
  /// [store] should be either 'apple' or 'google'
  /// [receiptData] is the receipt data from the store
  Future<UserSubscription> validateReceipt({
    required SubscriptionStore store,
    required dynamic receiptData,
  }) async {
    try {
      final response = await _apiService.post(
        '/subscriptions/validate-receipt',
        body: jsonEncode({
          'store': store.name,
          'receiptData': receiptData,
        }),
      );
      
      return UserSubscription.fromMap(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 400) {
          throw const SubscriptionException(
            'Invalid receipt data',
            SubscriptionErrorType.invalidReceipt,
          );
        } else if (e.statusCode == 409) {
          throw const SubscriptionException(
            'Receipt validation conflict',
            SubscriptionErrorType.receiptConflict,
          );
        }
      }
      
      throw SubscriptionException(
        'Failed to validate receipt: ${e.toString()}',
        SubscriptionErrorType.unknown,
      );
    }
  }

  /// Restores purchases from the app store
  Future<UserSubscription> restorePurchases() async {
    try {
      final response = await _apiService.post('/subscriptions/restore-purchases');
      
      return UserSubscription.fromMap(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      throw SubscriptionException(
        'Failed to restore purchases: ${e.toString()}',
        SubscriptionErrorType.unknown,
      );
    }
  }

  /// Checks if the user has access to a premium feature
  /// 
  /// Returns true if the user has access, false otherwise
  Future<bool> checkFeatureAccess(FeatureType featureType) async {
    try {
      final subscription = await getCurrentSubscription();
      
      // If the user has a premium subscription, they have access to all features
      if (subscription.isPremium) {
        return true;
      }
      
      // For free users, check usage limits for specific features
      if (featureType == FeatureType.conversationTurn ||
          featureType == FeatureType.preLearning ||
          featureType == FeatureType.customScenario ||
          featureType == FeatureType.saveInstance) {
        final limits = await getUsageLimits();
        
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
      
      // For other features, free users don't have access
      return false;
    } catch (e) {
      // If there's an error, assume the user doesn't have access
      return false;
    }
  }
}

/// Types of features that may require premium
enum FeatureType {
  /// Conversation turn
  conversationTurn,
  
  /// Pre-learning
  preLearning,
  
  /// Custom scenario creation
  customScenario,
  
  /// Save conversation instance
  saveInstance,
  
  /// Detailed analysis
  detailedAnalysis,
  
  /// Advanced recommendations
  advancedRecommendations,
}

/// Types of subscription errors
enum SubscriptionErrorType {
  /// Invalid receipt data
  invalidReceipt,
  
  /// Receipt validation conflict
  receiptConflict,
  
  /// Unknown error
  unknown,
}

/// Exception thrown when subscription operations fail
class SubscriptionException implements Exception {
  /// Error message
  final String message;
  
  /// Type of error
  final SubscriptionErrorType errorType;

  /// Creates a new [SubscriptionException] instance
  const SubscriptionException(this.message, this.errorType);

  @override
  String toString() => message;
}
