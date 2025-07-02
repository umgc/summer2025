// filepath: lib/features/payments/presentation/pages/payment_cancel_page.dart
import 'package:flutter/material.dart';

class PaymentCancelPage extends StatelessWidget {
  const PaymentCancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Cancelled')),
      body: const Center(
        child: Text('Payment was cancelled.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}