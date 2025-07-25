import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/services/auth_token_manager.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import '../../models/subscription_model.dart';
import '../../models/package_model.dart';
import '../pages/stripe_checkout_page.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  _SubscriptionManagementPageState createState() =>
      _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState
    extends State<SubscriptionManagementPage> {
  bool _isLoading = true;
  String? _error;
  Subscription? _currentSubscription;
  String? _customerId;
  bool _processingAction = false;
  SubscriptionPlan? _selectedPlan;
  List<SubscriptionPlan> _plans = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // We no longer need a separate call to get customer ID, as we'll extract it from the subscription data

      // Now we don't need a separate call to getCurrentSubscription since we use getUserSubscriptions
      final response = await ApiService.getCurrentSubscription();

      // Fetch available plans from API
      final plansResponse = await ApiService.getAvailablePlans();

      if (plansResponse.statusCode == 200) {
        final plansData = jsonDecode(plansResponse.body);
        print('⚠️ Plans data from API: $plansData');
        if (plansData != null && plansData is List) {
          _plans = plansData.map((planData) {
            print('⚠️ Processing plan: $planData');
            // Generate default features based on the plan
            final List<String> features = [];

            // Basic features for all plans
            features.add('Core monitoring features');
            features.add('Email support');

            // Additional features based on plan name/nickname
            final nickname = (planData['nickname'] ?? '')
                .toString()
                .toLowerCase();
            if (nickname.contains('premium')) {
              features.add('Unlimited patients');
              features.add('Premium monitoring features');
              features.add('Advanced analytics with exports');
              features.add('24/7 priority support');
              features.add('AI-powered insights and recommendations');
            } else if (nickname.contains('standard')) {
              features.add('Up to 10 patients');
              features.add('Advanced monitoring');
              features.add('Full analytics dashboard');
              features.add('Priority email support');
            } else {
              features.add('Up to 3 patients');
              features.add('Basic analytics');
            }

            return SubscriptionPlan(
              id:
                  planData['priceId'] ??
                  planData['id'], // Use priceId if available
              name: planData['nickname'] ?? 'Basic Plan',
              description: planData['active'] == true
                  ? 'Active Plan'
                  : 'Inactive Plan',
              amount:
                  (planData['amount'] ?? 0) / 100, // Convert cents to dollars
              interval: planData['interval'] ?? 'month',
              features: features,
            );
          }).toList();
        } else {
          // Fall back to default plans if the response isn't in the expected format
          _plans = availablePlans;
        }
      } else {
        // Fall back to default plans if API call fails
        _plans = availablePlans;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          // If data is a list, find the active subscription
          if (data is List) {
            final activeSubscriptions = data
                .where(
                  (sub) =>
                      sub is Map<String, dynamic> &&
                      sub.containsKey('status') &&
                      sub['status'].toString().toLowerCase() == 'active',
                )
                .toList();

            // Use the first active subscription or null if none found
            final activeSubscription = activeSubscriptions.isNotEmpty
                ? activeSubscriptions.first
                : null;

            // Extract customer ID from the subscription data
            if (activeSubscription != null &&
                activeSubscription is Map<String, dynamic>) {
              if (activeSubscription.containsKey('stripeCustomerId')) {
                _customerId = activeSubscription['stripeCustomerId'];
              } else if (activeSubscription.containsKey('customer')) {
                _customerId = activeSubscription['customer'];
              } else if (activeSubscription.containsKey('customerId')) {
                _customerId = activeSubscription['customerId'];
              }
            } else if (data.isNotEmpty && data.first is Map<String, dynamic>) {
              if (data.first.containsKey('stripeCustomerId')) {
                _customerId = data.first['stripeCustomerId'];
              } else if (data.first.containsKey('customer')) {
                _customerId = data.first['customer'];
              } else if (data.first.containsKey('customerId')) {
                _customerId = data.first['customerId'];
              }
            }

            setState(() {
              _currentSubscription = activeSubscription != null
                  ? Subscription.fromJson(activeSubscription)
                  : null;

              // Set the selected plan based on current subscription
              if (_currentSubscription != null) {
                if (_plans.isNotEmpty) {
                  // Try to find a matching plan by ID first
                  try {
                    _selectedPlan = _plans.firstWhere(
                      (plan) => plan.id == _currentSubscription!.planId,
                      orElse: () => _plans.length > 1
                          ? _plans[1]
                          : _plans[0], // Default to standard plan if available
                    );
                  } catch (e) {
                    print('Error finding plan match: $e');
                    // Fallback to match by name if ID doesn't match
                    try {
                      _selectedPlan = _plans.firstWhere(
                        (plan) => plan.name.toLowerCase().contains(
                          _currentSubscription!.planName.toLowerCase(),
                        ),
                        orElse: () => _plans.length > 1 ? _plans[1] : _plans[0],
                      );
                    } catch (e) {
                      print('Error finding plan by name: $e');
                      // Last resort: just use the first plan
                      _selectedPlan = _plans.isNotEmpty ? _plans[0] : null;
                    }
                  }
                }
              } else {
                _selectedPlan = _plans.isNotEmpty
                    ? _plans[0]
                    : null; // Default to basic plan if no subscription
              }
            });
          }
          // Handle the case if it's still returning a single subscription object
          else if (data is Map<String, dynamic> && data.containsKey('id')) {
            setState(() {
              _currentSubscription = Subscription.fromJson(data);

              // Set the selected plan based on current subscription
              if (_currentSubscription != null) {
                if (_plans.isNotEmpty) {
                  // Try to find a matching plan by ID first
                  try {
                    _selectedPlan = _plans.firstWhere(
                      (plan) => plan.id == _currentSubscription!.planId,
                      orElse: () => _plans.length > 1
                          ? _plans[1]
                          : _plans[0], // Default to standard plan if available
                    );
                  } catch (e) {
                    print('Error finding plan match: $e');
                    // Fallback to match by name if ID doesn't match
                    try {
                      _selectedPlan = _plans.firstWhere(
                        (plan) => plan.name.toLowerCase().contains(
                          _currentSubscription!.planName.toLowerCase(),
                        ),
                        orElse: () => _plans.length > 1 ? _plans[1] : _plans[0],
                      );
                    } catch (e) {
                      print('Error finding plan by name: $e');
                      // Last resort: just use the first plan
                      _selectedPlan = _plans.isNotEmpty ? _plans[0] : null;
                    }
                  }
                }
              }
            });
          } else {
            setState(() {
              _currentSubscription = null;
              _selectedPlan = _plans.isNotEmpty
                  ? _plans[0]
                  : null; // Default to basic plan if no subscription
            });
          }
        } else {
          setState(() {
            _currentSubscription = null;
            _selectedPlan = _plans.isNotEmpty
                ? _plans[0]
                : null; // Default to basic plan if no subscription
          });
        }
      } else if (response.statusCode == 404) {
        // No subscription found, which is a valid state
        setState(() {
          _currentSubscription = null;
          _selectedPlan = _plans.isNotEmpty
              ? _plans[0]
              : null; // Default to basic plan
        });
      } else {
        setState(() {
          _error =
              'Failed to load subscription: ${response.statusCode}. Please try again later.';
        });
        print('Subscription API error: ${response.statusCode}');
        try {
          print('Response body: ${response.body}');
        } catch (e) {
          // Ignore body parsing errors
        }
      }
    } catch (e) {
      setState(() {
        _error =
            'Error loading subscription data. Please check your connection and try again.';
      });
      print('Exception in _loadSubscriptionData: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePlan(SubscriptionPlan newPlan) async {
    // Print debug information
    print('⚠️ Change plan triggered. CustomerId: $_customerId');
    if (_currentSubscription != null) {
      print('⚠️ Current subscription ID: ${_currentSubscription?.id}');
      print('⚠️ Current subscription planId: ${_currentSubscription?.planId}');
      print('⚠️ Current subscription status: ${_currentSubscription?.status}');
    } else {
      print('⚠️ No current subscription');
    }

    // Ensure we have a customerId for new subscriptions
    if (_processingAction) return;

    // For existing active subscriptions that need to be changed,
    // first cancel the existing subscription, then redirect to checkout
    if (_currentSubscription != null && _currentSubscription!.isActive) {
      // Enhanced confirmation dialog showing plan comparison
      final bool? confirmSwitch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.swap_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Confirm Plan Change'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are about to change your subscription plan:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),

                // Current plan info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.remove_circle_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current Plan (to be cancelled)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_currentSubscription!.planName} - ${_currentSubscription!.formattedAmount}/${_currentSubscription!.formattedInterval}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // New plan info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'New Plan (to be activated)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${newPlan.name} - ${newPlan.formattedAmount}/${newPlan.formattedInterval}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'What happens next:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Your current subscription will be cancelled\n'
                        '2. You\'ll be redirected to checkout for the new plan\n'
                        '3. No charge for unused time on current plan\n'
                        '4. New plan starts immediately after payment',
                        style: TextStyle(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('CONFIRM CHANGE'),
            ),
          ],
        ),
      );

      if (confirmSwitch != true) return;

      setState(() {
        _processingAction = true;
      });

      try {
        // First cancel the current subscription
        final response = await ApiService.cancelSubscription(
          _currentSubscription!.stripeSubscriptionId,
        );

        if (response.statusCode != 200) {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['error'] ?? 'Failed to cancel current subscription',
          );
        }

        // Get the user's ID for checkout
        final userSession = await AuthTokenManager.getUserSession();
        final userId = userSession != null
            ? userSession['id']?.toString()
            : null;

        // Extract customer ID from existing subscription
        final customerId = _currentSubscription!.customerId;

        // Now redirect to checkout flow with the new plan
        _redirectToCheckout(newPlan, userId, customerId);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          _processingAction = false;
        });
      }
    } else {
      // For new subscriptions or inactive subscriptions,
      // get the user ID and customer ID if available, then redirect to checkout
      try {
        final userSession = await AuthTokenManager.getUserSession();
        final userId = userSession != null
            ? userSession['id']?.toString()
            : null;

        // Redirect to checkout flow for a new subscription
        _redirectToCheckout(newPlan, userId, _customerId);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Helper method to redirect to the checkout page
  void _redirectToCheckout(
    SubscriptionPlan plan,
    String? userId,
    String? customerId,
  ) {
    // Convert SubscriptionPlan to PackageModel for the checkout page
    final package = PackageModel(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      priceCents: (plan.amount * 100).toInt(), // Convert dollars to cents
    );

    // Navigate to checkout page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StripeCheckoutPage(
          package: package,
          userId: userId,
          stripeCustomerId: customerId,
          fromPortal:
              true, // Indicate this is coming from subscription management page
        ),
      ),
    ).then((_) {
      // Refresh data when returning from checkout
      _loadSubscriptionData();
      setState(() {
        _processingAction = false;
      });
    });
  }

  Future<void> _cancelSubscription() async {
    if (_processingAction || _currentSubscription == null) return;

    // First confirmation dialog with clear warning about loss of access
    final bool? initialConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warning: Cancelling your subscription will have the following effects:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('• You will be automatically logged out of the application'),
            Text(
              '• Your access to the application will be immediately removed',
            ),
            Text(
              '• You will not receive a refund for the current billing period',
            ),
            SizedBox(height: 16),
            Text('Are you sure you want to proceed with cancellation?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NO, KEEP MY PLAN'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('YES, CANCEL'),
          ),
        ],
      ),
    );

    if (initialConfirm != true) return;

    // Second confirmation as an extra safety measure
    final bool? finalConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This action cannot be undone. You will need to create a new subscription if you want to use the app again. Proceed with cancellation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NO, GO BACK'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('YES, CANCEL MY SUBSCRIPTION'),
          ),
        ],
      ),
    );

    if (finalConfirm != true) return;

    setState(() {
      _processingAction = true;
    });

    try {
      // Use stripe subscription ID for cancellation request as the backend expects it
      final response = await ApiService.cancelSubscription(
        _currentSubscription!
            .stripeSubscriptionId, // Use Stripe's subscription ID
      );
      if (response.statusCode == 200) {
        // Show brief success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Subscription cancelled successfully. Logging out...',
            ),
          ),
        );

        // Small delay to show the message before logout
        await Future.delayed(const Duration(seconds: 1));

        // Force logout by clearing the user session
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await AuthTokenManager.clearAuthData();
        userProvider.clearUser();

        // Navigate to login screen
        if (!context.mounted) return;

        // Clear navigation history and go to login
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to cancel subscription');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));

      setState(() {
        _processingAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Subscription Management',
        centerTitle: true,
      ),
      drawer: const CommonDrawer(currentRoute: '/select-package'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Subscription',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadSubscriptionData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentSubscription(),
          const SizedBox(height: 24),
          _buildAvailablePlans(),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscription() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Subscription',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),

            if (_currentSubscription == null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Subscription',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a plan below to get started with CareConnect',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Enhanced subscription details with better visual hierarchy
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan name prominently displayed
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentSubscription!.planName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const Spacer(),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _currentSubscription!.status,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _currentSubscription!.statusDisplay.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Amount paid and billing info
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount Paid',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentSubscription!.formattedAmount,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              Text(
                                '/ ${_currentSubscription!.formattedInterval}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Billing',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(
                                  _currentSubscription!.currentPeriodEnd,
                                ),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Additional subscription details
              _buildInfoRow(
                icon: Icons.event,
                label: 'Current Period',
                value:
                    '${_formatDate(_currentSubscription!.currentPeriodStart)} - ${_formatDate(_currentSubscription!.currentPeriodEnd)}',
              ),

              if (_currentSubscription!.cancelAtPeriodEnd) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Subscription will be cancelled at the end of current period',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              if (!_currentSubscription!.cancelAtPeriodEnd &&
                  _currentSubscription!.isActive) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _processingAction
                            ? null
                            : _cancelSubscription,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel Subscription'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String timestamp) {
    if (timestamp.isEmpty) return 'N/A';

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(timestamp) * 1000,
      );
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return timestamp;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'trialing':
        return AppTheme.success;
      case 'past_due':
      case 'unpaid':
        return AppTheme.warning;
      case 'canceled':
      case 'incomplete':
      case 'incomplete_expired':
        return AppTheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: valueColor != null
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailablePlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Plans',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (_plans.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No subscription plans are currently available',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check back later or contact support',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ..._plans.map((plan) {
            // Check if this is the current plan using ID, name, and price as fallbacks
            final isCurrentPlan =
                _currentSubscription != null &&
                (_currentSubscription!.planId == plan.id ||
                    _currentSubscription!.planName.toLowerCase().contains(
                      plan.name.toLowerCase(),
                    ) ||
                    plan.name.toLowerCase().contains(
                      _currentSubscription!.planName.toLowerCase(),
                    ) ||
                    (_currentSubscription!.planAmount > 0 &&
                        plan.amount > 0 &&
                        _currentSubscription!.planAmount ==
                            plan.amount)); // Price equality as last resort
            final isSelectedPlan = _selectedPlan?.id == plan.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: isSelectedPlan ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelectedPlan
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPlan = plan;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Plan name and selection indicator
                          Expanded(
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: plan.id,
                                  groupValue: _selectedPlan?.id,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPlan = _plans.firstWhere(
                                        (p) => p.id == value,
                                      );
                                    });
                                  },
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        plan.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withOpacity(0.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                plan.formattedAmount,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              Text(
                                plan.formattedInterval,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Features
                      ...plan.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(feature)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action button
                      if (isCurrentPlan)
                        // For current plan, show a different styled button indicating it's the current plan
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: null, // Always disabled for current plan
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                const Text('Current Active Plan'),
                              ],
                            ),
                          ),
                        )
                      else
                        // For other plans, show the regular action button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _processingAction
                                ? null // Disable if processing
                                : () => _changePlan(plan),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              disabledBackgroundColor: Theme.of(
                                context,
                              ).disabledColor,
                            ),
                            child: _processingAction && isSelectedPlan
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _currentSubscription != null &&
                                            _currentSubscription!.isActive
                                        ? 'Switch to This Plan'
                                        : 'Subscribe Now',
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
