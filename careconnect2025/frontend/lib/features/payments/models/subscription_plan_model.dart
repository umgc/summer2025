class SubscriptionPlan {
  final String id;
  final bool active;
  final int amount;
  final String currency;
  final String interval;
  final int intervalCount;
  final String product;
  final String nickname;
  final String? customDescription;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.active,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.intervalCount,
    required this.product,
    required this.nickname,
    this.customDescription,
    this.features = const [],
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      active: json['active'] ?? false,
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'usd',
      interval: json['interval'] ?? 'month',
      intervalCount: json['intervalCount'] ?? 1,
      product: json['product'] ?? '',
      nickname: json['nickname'] ?? '',
      customDescription: json['description'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'active': active,
      'amount': amount,
      'currency': currency,
      'interval': interval,
      'intervalCount': intervalCount,
      'product': product,
      'nickname': nickname,
    };
  }

  // Helper method to get formatted price
  String get formattedPrice {
    return '\$${(amount / 100).toStringAsFixed(2)}';
  }

  // Helper method to get description based on plan type
  String get description {
    if (customDescription != null) return customDescription!;

    if (nickname.toLowerCase().contains('standard')) {
      return 'Basic features for patients and caregivers.';
    } else if (nickname.toLowerCase().contains('premium')) {
      return 'All features including video calls, AI assistant, and device integration.';
    }
    return 'Subscription plan for CareConnect services.';
  }

  // Helper method to get formatted interval
  String get formattedInterval {
    return interval == 'year' ? 'yearly' : 'monthly';
  }
}
