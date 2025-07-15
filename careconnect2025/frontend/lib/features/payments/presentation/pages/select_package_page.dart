import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/package_model.dart';
import '../../../payments/models/subscription_plan_model.dart';
import 'stripe_checkout_page.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/services/api_service.dart';

class SelectPackagePage extends StatefulWidget {
  const SelectPackagePage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Package',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF14366E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSubscriptionPlans,
            tooltip: 'Refresh Plans',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF14366E)),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/dashboard/patient');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Task Scheduling'),
              onTap: () {
                Navigator.pop(context);
                context.go('/taskscheduling');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat & Calls'),
              onTap: () {
                Navigator.pop(context);
                context.go('/chatandcalls');
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('AI Assistant'),
              onTap: () {
                Navigator.pop(context);
                context.go('/aiassistant');
              },
            ),
            ListTile(
              leading: const Icon(Icons.watch),
              title: const Text('Fitbit Integration'),
              onTap: () {
                Navigator.pop(context);
                context.go('/fitbit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Emergency SOS'),
              onTap: () {
                Navigator.pop(context);
                context.go('/sos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Subscribe'),
              onTap: () {
                Navigator.pop(context);
                context.go('/select-package');
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Achievements'),
              onTap: () {
                Navigator.pop(context);
                context.go('/gamification');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Add logout logic if needed
                Navigator.pop(context);
                context.go('/');
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchSubscriptionPlans,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : plans.isEmpty
          ? const Center(
              child: Text(
                'No subscription plans available',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      plan.nickname,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.description),
                        const SizedBox(height: 4),
                        Text(
                          'Billed ${plan.interval}ly',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      plan.formattedPrice,
                      style: const TextStyle(
                        color: Color(0xFF14366E),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StripeCheckoutPage(
                            package: _convertToPackageModel(plan),
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
