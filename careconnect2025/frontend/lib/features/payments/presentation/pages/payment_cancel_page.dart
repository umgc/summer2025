// filepath: lib/features/payments/presentation/pages/payment_cancel_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentCancelPage extends StatelessWidget {
  final bool? isRegistration;

  const PaymentCancelPage({super.key, this.isRegistration = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Cancelled'),
        backgroundColor: const Color(0xFF14366E),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    size: 80,
                    color: Colors.orange.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Payment Cancelled',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14366E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isRegistration == true
                      ? 'Your registration is not complete without payment. You can try again or contact support if you need assistance.'
                      : 'Your payment was cancelled. No charges were made to your account.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14366E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (isRegistration == true) {
                        // Go back to package selection
                        context.go('/select-package');
                      } else {
                        // Go to dashboard
                        context.go('/dashboard/patient');
                      }
                    },
                    child: Text(
                      isRegistration == true
                          ? 'Try Payment Again'
                          : 'Return to Dashboard',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    if (isRegistration == true) {
                      context.go('/login');
                    } else {
                      context.go('/');
                    }
                  },
                  child: Text(
                    isRegistration == true
                        ? 'Skip for Now (Go to Login)'
                        : 'Go to Home',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
