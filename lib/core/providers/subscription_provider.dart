import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/subscription_status.dart';
import 'package:chinese_odysee/core/models/usage_limits.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/repositories/subscription_repository.dart';
import 'package:chinese_odysee/core/services/subscription/subscription_service.dart';

/// Provider for the subscription service
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SubscriptionService(apiService);
});

/// Provider for the subscription repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  
  return SubscriptionRepository(
    subscriptionService: subscriptionService,
    storageService: storageService,
  );
});

/// Provider for the current subscription status
final subscriptionStatusProvider = FutureProvider<UserSubscription>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getCurrentSubscription();
});

/// Provider for the current usage limits
final usageLimitsProvider = FutureProvider<UsageLimits>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getUsageLimits();
});

/// Provider for checking feature access
final featureAccessProvider = FutureProvider.family<bool, FeatureType>((ref, featureType) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.checkFeatureAccess(featureType);
});

/// Notifier for managing subscriptions
class SubscriptionNotifier extends StateNotifier<AsyncValue<UserSubscription?>> {
  /// Subscription repository
  final SubscriptionRepository _repository;

  /// Creates a new [SubscriptionNotifier] instance
  SubscriptionNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Load the initial subscription
    _loadSubscription();
  }

  /// Loads the current subscription
  Future<void> _loadSubscription() async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _repository.getCurrentSubscription();
      state = AsyncValue.data(subscription);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Validates a purchase receipt
  Future<void> validateReceipt({
    required SubscriptionStore store,
    required dynamic receiptData,
  }) async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _repository.validateReceipt(
        store: store,
        receiptData: receiptData,
      );
      state = AsyncValue.data(subscription);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Restores purchases
  Future<void> restorePurchases() async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _repository.restorePurchases();
      state = AsyncValue.data(subscription);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refreshes the subscription status
  Future<void> refresh() async {
    await _loadSubscription();
  }
}

/// Provider for the subscription notifier
final subscriptionNotifierProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<UserSubscription?>>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionNotifier(repository);
});
