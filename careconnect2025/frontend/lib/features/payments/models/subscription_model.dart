class Subscription {
  final String id; // Database ID or Stripe ID depending on source
  final String
  stripeSubscriptionId; // Stripe's subscription ID for API operations
  final String customerId; // Stripe customer ID
  final String status;
  final String currentPeriodStart;
  final String currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String planId;
  final String planName;
  final double planAmount;
  final String planInterval;

  Subscription({
    required this.id,
    required this.stripeSubscriptionId,
    required this.customerId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.planId,
    required this.planName,
    required this.planAmount,
    required this.planInterval,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    // Handle different API response formats
    // Support both Stripe direct format and our backend's custom format

    // Check if this is the new API format with our backend structure
    if (json.containsKey('stripeSubscriptionId') ||
        json.containsKey('stripeCustomerId')) {
      // New backend format
      final stripeSubId = json['stripeSubscriptionId']?.toString() ?? '';
      return Subscription(
        id: json['id']?.toString() ?? '', // Database ID
        stripeSubscriptionId:
            stripeSubId, // Stripe subscription ID for API operations
        customerId:
            json['stripeCustomerId']?.toString() ??
            json['customer']?.toString() ??
            json['customerId']?.toString() ??
            '',
        status: json['status']?.toString() ?? '',
        currentPeriodStart: json['startedAt']?.toString() ?? '',
        currentPeriodEnd: json['currentPeriodEnd']?.toString() ?? '',
        cancelAtPeriodEnd: false, // Default since it's not in the new format
        planId:
            json['planId']?.toString() ?? json['planCode']?.toString() ?? '',
        planName: json['planName']?.toString() ?? 'Standard Plan',
        planAmount: json['priceCents'] != null
            ? ((json['priceCents'] as num).toDouble() / 100)
            : 0.0,
        planInterval: 'month', // Default value
      );
    }

    // Original Stripe format
    final planData =
        json['plan'] as Map<String, dynamic>? ??
        json['items']?['data']?[0]?['plan'] as Map<String, dynamic>? ??
        {};

    final stripeId = json['id']?.toString() ?? '';
    return Subscription(
      id: stripeId, // In direct Stripe format, id is the subscription ID
      stripeSubscriptionId:
          stripeId, // Same value as id for direct Stripe format
      customerId: (json['customer'] ?? '').toString(),
      status: json['status']?.toString() ?? '',
      currentPeriodStart: json['current_period_start']?.toString() ?? '',
      currentPeriodEnd: json['current_period_end']?.toString() ?? '',
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      planId: planData['id']?.toString() ?? '',
      planName: planData['nickname']?.toString() ?? 'Standard Plan',
      planAmount: ((planData['amount'] ?? 0) as num).toDouble() / 100,
      planInterval: planData['interval']?.toString() ?? 'month',
    );
  }

  bool get isActive =>
      status.toLowerCase() == 'active' || status.toLowerCase() == 'trialing';
  bool get isCancelled =>
      status.toLowerCase() == 'canceled' || cancelAtPeriodEnd;

  String get formattedAmount => '\$${planAmount.toStringAsFixed(2)}';

  String get formattedInterval {
    if (planInterval == 'month') return 'Monthly';
    if (planInterval == 'year') return 'Yearly';
    return planInterval;
  }

  String get statusDisplay {
    final lowerStatus = status.toLowerCase();
    if (cancelAtPeriodEnd) return 'Canceling at period end';
    if (lowerStatus == 'active') return 'Active';
    if (lowerStatus == 'trialing') return 'Trial';
    if (lowerStatus == 'canceled') return 'Cancelled';
    if (lowerStatus == 'unpaid') return 'Unpaid';
    return status;
  }
}

class SubscriptionPlan {
  final String id; // This can be the plan ID or price ID depending on source
  final String name;
  final String description;
  final double amount;
  final String interval;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.interval,
    required this.features,
  });

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedInterval {
    if (interval == 'month') return '/month';
    if (interval == 'year') return '/year';
    return '/$interval';
  }
}

// Define available plans
final List<SubscriptionPlan> availablePlans = [
  SubscriptionPlan(
    id: 'price_basic',
    name: 'Basic Plan',
    description: 'Essential care coordination features',
    amount: 9.99,
    interval: 'month',
    features: [
      'Up to 3 patients',
      'Core monitoring features',
      'Basic analytics',
      'Email support',
    ],
  ),
  SubscriptionPlan(
    id: 'price_standard',
    name: 'Standard Plan',
    description: 'Advanced features for better care management',
    amount: 19.99,
    interval: 'month',
    features: [
      'Up to 10 patients',
      'Advanced monitoring',
      'Full analytics dashboard',
      'Priority email support',
      'AI-powered insights',
    ],
  ),
  SubscriptionPlan(
    id: 'price_premium',
    name: 'Premium Plan',
    description: 'Comprehensive care management solution',
    amount: 29.99,
    interval: 'month',
    features: [
      'Unlimited patients',
      'Premium monitoring features',
      'Advanced analytics with exports',
      '24/7 priority support',
      'AI-powered insights and recommendations',
      'Team access controls',
    ],
  ),
];
