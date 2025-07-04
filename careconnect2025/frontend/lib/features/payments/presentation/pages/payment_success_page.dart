// filepath: lib/features/payments/presentation/pages/payment_success_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? sessionId;
  final bool? isRegistration;

  const PaymentSuccessPage({
    super.key,
    this.sessionId,
    this.isRegistration = false,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Auto-redirect after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    if (widget.isRegistration == true) {
      // For new registrations, go to login
      context.go('/login');
    } else {
      // For existing users, go to dashboard
      context.go('/dashboard/patient');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.isRegistration == true
                      ? 'Registration Complete!'
                      : 'Payment Successful!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14366E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isRegistration == true
                      ? 'Welcome to CareConnect! Your account has been created and your subscription is active. You can now log in to access all features.'
                      : 'Thank you for your payment! Your subscription has been updated successfully.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                if (widget.sessionId != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Session ID: ${widget.sessionId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
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
                    onPressed: _navigateToNext,
                    child: Text(
                      widget.isRegistration == true
                          ? 'Continue to Login'
                          : 'Continue to Dashboard',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Redirecting automatically in 4 seconds...',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
