import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/subscription_status.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for managing subscriptions
class SubscriptionScreen extends ConsumerWidget {
  /// Creates a new [SubscriptionScreen] instance
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionNotifierProvider);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Premium Subscription',
      ),
      body: subscriptionAsync.when(
        data: (subscription) => _buildContent(context, ref, subscription),
        loading: () => const LoadingIndicator(message: 'Loading subscription details...'),
        error: (error, stack) => ErrorDisplay(
          error: 'Failed to load subscription: ${error.toString()}',
          onRetry: () {
            ref.read(subscriptionNotifierProvider.notifier).refresh();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserSubscription? subscription,
  ) {
    final isPremium = subscription?.isPremium ?? false;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isPremium),
          const SizedBox(height: 24),
          _buildCurrentPlan(context, subscription),
          const SizedBox(height: 32),
          _buildPlanComparison(context),
          const SizedBox(height: 32),
          if (!isPremium) _buildSubscribeButtons(context, ref),
          const SizedBox(height: 16),
          _buildRestoreButton(context, ref),
          const SizedBox(height: 24),
          _buildTermsAndPrivacy(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPremium ? 'Your Premium Subscription' : 'Upgrade to Premium',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          isPremium
              ? 'Thank you for supporting Chinese Odyssey!'
              : 'Unlock all features and enhance your learning experience',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildCurrentPlan(BuildContext context, UserSubscription? subscription) {
    if (subscription == null) {
      return const SizedBox.shrink();
    }
    
    final isPremium = subscription.isPremium;
    final planName = _getPlanName(subscription.planType);
    final statusText = _getStatusText(subscription.status);
    final endDate = subscription.currentPeriodEnd;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.star : Icons.info,
                  color: isPremium
                      ? Colors.amber
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Plan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              planName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(statusText),
            if (endDate != null && isPremium) ...[
              const SizedBox(height: 8),
              Text(
                'Renews on ${_formatDate(endDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanComparison(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Comparison',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFeatureRow(
                  context,
                  'Conversation Turns',
                  'Limited (30/day)',
                  'Unlimited',
                ),
                const Divider(),
                _buildFeatureRow(
                  context,
                  'Pre-Learning Content',
                  'Limited (5/day)',
                  'Unlimited',
                ),
                const Divider(),
                _buildFeatureRow(
                  context,
                  'Custom Scenarios',
                  'Limited (3 total)',
                  'Unlimited',
                ),
                const Divider(),
                _buildFeatureRow(
                  context,
                  'Saved Conversations',
                  'Limited (5 total)',
                  'Unlimited',
                ),
                const Divider(),
                _buildFeatureRow(
                  context,
                  'Detailed Analysis',
                  'Basic',
                  'Advanced',
                ),
                const Divider(),
                _buildFeatureRow(
                  context,
                  'Personalized Recommendations',
                  'Basic',
                  'Advanced',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    String feature,
    String freeValue,
    String premiumValue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(freeValue),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  premiumValue,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButtons(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _subscribe(context, ref, PlanType.premiumMonthly),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Column(
            children: [
              Text(
                'Monthly Subscription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$4.99 per month',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _subscribe(context, ref, PlanType.premiumYearly),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            children: [
              const Text(
                'Annual Subscription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '\$39.99 per year',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Save 33%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton(
        onPressed: () => _restorePurchases(context, ref),
        child: const Text('Restore Purchases'),
      ),
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'By subscribing, you agree to our',
            style: TextStyle(fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: Open terms of service
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Text(
                'and',
                style: TextStyle(fontSize: 12),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Open privacy policy
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _subscribe(BuildContext context, WidgetRef ref, PlanType planType) {
    // TODO: Implement subscription purchase
    // This would integrate with the platform's billing system
    
    // Show a dialog to simulate the purchase process
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription'),
        content: Text(
          'This is a placeholder for the ${_getPlanName(planType)} subscription purchase flow. In a real app, this would integrate with the App Store or Google Play billing.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _restorePurchases(BuildContext context, WidgetRef ref) {
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
            Text('Restoring purchases...'),
          ],
        ),
      ),
    );
    
    // Simulate restore process
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show result dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Purchases'),
            content: const Text(
              'This is a placeholder for the restore purchases flow. In a real app, this would check for existing subscriptions with the App Store or Google Play.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  String _getPlanName(PlanType planType) {
    switch (planType) {
      case PlanType.free:
        return 'Free Plan';
      case PlanType.premiumMonthly:
        return 'Premium Monthly';
      case PlanType.premiumYearly:
        return 'Premium Annual';
    }
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled (active until end of period)';
      case SubscriptionStatus.inGracePeriod:
        return 'Payment issue (grace period)';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
