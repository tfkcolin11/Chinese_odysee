import 'package:equatable/equatable.dart';

/// Enum representing subscription plan types
enum PlanType {
  /// Free tier
  free,
  
  /// Premium monthly subscription
  premiumMonthly,
  
  /// Premium yearly subscription
  premiumYearly,
}

/// Enum representing subscription status
enum SubscriptionStatus {
  /// Subscription is active
  active,
  
  /// Subscription is pending activation
  pending,
  
  /// Subscription has expired
  expired,
  
  /// Subscription has been cancelled but still active until the end of the period
  cancelled,
  
  /// Subscription is in grace period (payment failed but still active)
  inGracePeriod,
}

/// Enum representing subscription store
enum SubscriptionStore {
  /// Apple App Store
  apple,
  
  /// Google Play Store
  google,
  
  /// No store (free tier)
  none,
}

/// Model representing a user's subscription status
class UserSubscription extends Equatable {
  /// ID of the subscription
  final String subscriptionId;
  
  /// ID of the user
  final String userId;
  
  /// Type of plan
  final PlanType planType;
  
  /// Status of the subscription
  final SubscriptionStatus status;
  
  /// Start of the current billing period
  final DateTime? currentPeriodStart;
  
  /// End of the current billing period
  final DateTime? currentPeriodEnd;
  
  /// Store where the subscription was purchased
  final SubscriptionStore store;
  
  /// Original transaction ID from the store
  final String? storeOriginalTransactionId;
  
  /// Latest transaction ID from the store
  final String? storeLatestTransactionId;
  
  /// When the subscription was created
  final DateTime createdAt;
  
  /// When the subscription was last updated
  final DateTime updatedAt;

  /// Creates a new [UserSubscription] instance
  const UserSubscription({
    required this.subscriptionId,
    required this.userId,
    required this.planType,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    required this.store,
    this.storeOriginalTransactionId,
    this.storeLatestTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [UserSubscription] from a map
  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      subscriptionId: map['subscriptionId'] as String,
      userId: map['userId'] as String,
      planType: PlanType.values.firstWhere(
        (e) => e.name == map['planId'],
        orElse: () => PlanType.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
      currentPeriodStart: map['currentPeriodStart'] != null
          ? DateTime.parse(map['currentPeriodStart'] as String)
          : null,
      currentPeriodEnd: map['currentPeriodEnd'] != null
          ? DateTime.parse(map['currentPeriodEnd'] as String)
          : null,
      store: SubscriptionStore.values.firstWhere(
        (e) => e.name == map['store'],
        orElse: () => SubscriptionStore.none,
      ),
      storeOriginalTransactionId: map['storeOriginalTransactionId'] as String?,
      storeLatestTransactionId: map['storeLatestTransactionId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Converts this [UserSubscription] to a map
  Map<String, dynamic> toMap() {
    return {
      'subscriptionId': subscriptionId,
      'userId': userId,
      'planId': planType.name,
      'status': status.name,
      'currentPeriodStart': currentPeriodStart?.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
      'store': store.name,
      'storeOriginalTransactionId': storeOriginalTransactionId,
      'storeLatestTransactionId': storeLatestTransactionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [UserSubscription] with the given fields replaced
  UserSubscription copyWith({
    String? subscriptionId,
    String? userId,
    PlanType? planType,
    SubscriptionStatus? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    SubscriptionStore? store,
    String? storeOriginalTransactionId,
    String? storeLatestTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSubscription(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      status: status ?? this.status,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      store: store ?? this.store,
      storeOriginalTransactionId:
          storeOriginalTransactionId ?? this.storeOriginalTransactionId,
      storeLatestTransactionId:
          storeLatestTransactionId ?? this.storeLatestTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the subscription is currently active
  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.cancelled ||
      status == SubscriptionStatus.inGracePeriod;

  /// Whether the subscription is premium
  bool get isPremium =>
      isActive && (planType == PlanType.premiumMonthly || planType == PlanType.premiumYearly);

  @override
  List<Object?> get props => [
        subscriptionId,
        userId,
        planType,
        status,
        currentPeriodStart,
        currentPeriodEnd,
        store,
        storeOriginalTransactionId,
        storeLatestTransactionId,
        createdAt,
        updatedAt,
      ];
}
