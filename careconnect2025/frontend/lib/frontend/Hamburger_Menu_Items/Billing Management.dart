import 'package:flutter/material.dart';
import 'UpdateBillingDetails.dart';
import 'CancelBillingSubscription.dart';

class BillingAndSubscriptionManagementScreen extends StatelessWidget {
  const BillingAndSubscriptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Subscription'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.indigo),
                title: const Text("Current Plan:"),
                subtitle: const Text("\$20 per patient per month"),
                trailing: const Text("Active", style: TextStyle(color: Colors.green)),
              ),
            ),

            const SizedBox(height: 50),

            // Update Billing Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UpdateBillingDetailsScreen()),
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text('Payment Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height:5),

            // Cancel Subscription Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CancelSubscriptionScreen()),
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Note: Charges are processed monthly via Stripe. You can manage patients and billing anytime.',
              style: TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
