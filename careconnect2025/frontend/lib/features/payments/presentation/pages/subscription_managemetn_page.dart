import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionManagementPage extends StatelessWidget {
  const SubscriptionManagementPage({super.key});

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Cancel Subscription'),
          content: const Text('Are you sure you want to cancel your subscription?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/payment-cancel');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Options'),
        backgroundColor: const Color(0xFF14366E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 48), // This brings content slightly up from true center
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Manage Your Subscription',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14366E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.payment),
                      label: const Text('Subscribe / Change Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14366E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                      onPressed: () => context.go('/select-package'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Subscription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                      onPressed: () => _confirmCancel(context),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Note: Charges are processed monthly via Stripe. You can manage patients and billing anytime.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
