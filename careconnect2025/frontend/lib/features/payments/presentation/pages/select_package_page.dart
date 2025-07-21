import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/package_model.dart';
import '../../../payments/models/subscription_plan_model.dart';
import 'stripe_checkout_page.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';

class SelectPackagePage extends StatefulWidget {
  final String? userId;
  final String? stripeCustomerId;
  const SelectPackagePage({super.key, this.userId, this.stripeCustomerId});

  @override
  State<SelectPackagePage> createState() => _SelectPackagePageState();
}

class _SelectPackagePageState extends State<SelectPackagePage> {
  List<SubscriptionPlan> plans = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('🚀 SelectPackagePage initState called');
    print('🔗 Base URL: ${ApiConstants.baseUrl}');
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchSubscriptionPlans() async {
    print('🔍 Starting to fetch subscription plans...');
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = '${ApiConstants.baseUrl}subscriptions/plans';
      print('📡 Making API call to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📊 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> plansJson = json.decode(response.body);
        print('✅ Successfully parsed ${plansJson.length} plans');

        setState(() {
          plans = plansJson
              .map((json) => SubscriptionPlan.fromJson(json))
              .where((plan) => plan.active) // Only show active plans
              .toList();
          isLoading = false;
        });

        print('🎯 Filtered to ${plans.length} active plans');
      } else {
        print('❌ API call failed with status: ${response.statusCode}');
        setState(() {
          errorMessage =
              'Failed to load subscription plans (Status: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      print('🚨 Exception occurred: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Convert SubscriptionPlan to PackageModel for compatibility with StripeCheckoutPage
  PackageModel _convertToPackageModel(SubscriptionPlan plan) {
    return PackageModel(
      id: plan.id,
      name: plan.nickname,
      description: plan.description,
      priceCents: plan.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Choose Your Package',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSubscriptionPlans,
            tooltip: 'Refresh Plans',
          ),
        ],
      ),
      drawer: const CommonDrawer(currentRoute: '/select-package'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: AppTheme.primaryButtonStyle,
                    onPressed: _fetchSubscriptionPlans,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : plans.isEmpty
          ? Center(
              child: Text(
                'No subscription plans available',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  elevation: theme.cardTheme.elevation,
                  shape: theme.cardTheme.shape,
                  color: theme.cardTheme.color,
                  child: ListTile(
                    title: Text(
                      plan.nickname,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Billed ${plan.interval}ly',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Text(
                      plan.formattedPrice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StripeCheckoutPage(
                            package: _convertToPackageModel(plan),
                            userId: widget.userId,
                            stripeCustomerId: widget.stripeCustomerId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
