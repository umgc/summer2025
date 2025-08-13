import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'dart:convert';

/// Service to handle subscription-related operations and premium feature restrictions
class SubscriptionService {
  /// Check if the current user has a premium subscription
  static Future<bool> hasPremiumSubscription(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        return false;
      }

      // Only apply subscription restrictions to caregivers
      if (!user.isCaregiver) {
        return true; // Patients and other roles have full access
      }

      // Get current subscription for caregiver
      final response = await ApiService.getCurrentSubscription();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different response structures
        Map<String, dynamic>? activeSubscription;

        if (data is List && data.isNotEmpty) {
          // Find active subscription
          activeSubscription = data.firstWhere(
            (sub) =>
                sub is Map<String, dynamic> &&
                sub['status']?.toString().toLowerCase() == 'active',
            orElse: () => null,
          );
        } else if (data is Map<String, dynamic> &&
            data['status']?.toString().toLowerCase() == 'active') {
          activeSubscription = data;
        }

        if (activeSubscription != null) {
          final planName =
              activeSubscription['planName']?.toString().toUpperCase() ?? '';
          return planName.contains('PREMIUM') || planName.contains('PRO');
        }
      }

      return false; // No active subscription or failed to fetch
    } catch (e) {
      print('Error checking premium subscription: $e');
      return false; // Default to no premium access on error
    }
  }

  /// Show premium required dialog
  static void showPremiumRequiredDialog(
    BuildContext context,
    String featureName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Premium Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$featureName is only available with a Premium subscription.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Premium to access:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• AI Health Assistant'),
            const Text('• Voice & Video Calls'),
            const Text('• Advanced Analytics'),
            const Text('• Priority Support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToSubscriptionPage(context);
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  /// Navigate to subscription management page
  static void _navigateToSubscriptionPage(BuildContext context) {
    Navigator.of(context).pushNamed('/subscription');
  }

  /// Check if caregiver can use AI assistant
  static Future<bool> canUseAIAssistant(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    // Patients can always use AI assistant
    if (user?.isPatient == true) {
      return true;
    }

    // For caregivers, check premium subscription
    if (user?.isCaregiver == true) {
      return await hasPremiumSubscription(context);
    }

    return true; // Other roles have access
  }

  /// Check if caregiver can use video/voice calls
  static Future<bool> canUseVideoCalls(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    // Patients can always use video calls
    if (user?.isPatient == true) {
      return true;
    }

    // For caregivers, check premium subscription
    if (user?.isCaregiver == true) {
      return await hasPremiumSubscription(context);
    }

    return true; // Other roles have access
  }

  /// Check premium access and show dialog if not available
  static Future<bool> checkPremiumAccessWithDialog(
    BuildContext context,
    String featureName,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    // Only restrict caregivers
    if (user?.isCaregiver != true) {
      return true;
    }

    final hasPremium = await hasPremiumSubscription(context);

    if (!hasPremium) {
      showPremiumRequiredDialog(context, featureName);
      return false;
    }

    return true;
  }
}
