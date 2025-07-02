// filepath: lib/features/payments/presentation/pages/payment_success_page.dart
import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String? sessionId;
  const PaymentSuccessPage({super.key, this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Success')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Payment Successful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (sessionId != null) Text('Session ID: $sessionId'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to dashboard or home
                Navigator.of(context).pushReplacementNamed('/dashboard/patient');
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}