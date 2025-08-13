// filepath: lib/features/payments/presentation/pages/payment_cancel_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../config/router/app_router.dart';
import '../../../../providers/user_provider.dart';
import '../../../../widgets/app_bar_helper.dart';
import '../../../../widgets/common_drawer.dart';

class PaymentCancelPage extends StatelessWidget {
  final bool? isRegistration;

  const PaymentCancelPage({super.key, this.isRegistration = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarHelper.createAppBar(context, title: 'Payment Cancelled'),
      drawer: const CommonDrawer(currentRoute: '/payment-cancel'),
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
                    color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Payment Cancelled',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isRegistration == true
                      ? 'Your registration is not complete without payment. You can try again or contact support if you need assistance.'
                      : 'Your payment was cancelled. No charges were made to your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                        // Go to dashboard based on user role
                        navigateToDashboard(context);
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
                      // Get user type from provider if possible
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      final userType = userProvider.user != null
                          ? userProvider.user!.role.toLowerCase()
                          : 'caregiver'; // Default for registration
                      context.go('/login', extra: {'userType': userType});
                    } else {
                      context.go('/');
                    }
                  },
                  child: Text(
                    isRegistration == true
                        ? 'Skip for Now (Go to Login)'
                        : 'Go to Home',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
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
