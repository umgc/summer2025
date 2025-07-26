// filepath: lib/features/payments/presentation/pages/payment_success_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../config/router/app_router.dart';
import '../../../../providers/user_provider.dart';
import '../../../../widgets/responsive_container.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? sessionId;
  final bool? isRegistration;
  final bool fromPortal;

  const PaymentSuccessPage({
    super.key,
    this.sessionId,
    this.isRegistration = false,
    this.fromPortal = false,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isRedirecting = false;
  double _progressValue = 0.0;

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

    // Start the progress animation over 4 seconds
    const redirectDelay = 4;
    for (int i = 1; i <= redirectDelay; i++) {
      Future.delayed(Duration(seconds: i), () {
        if (mounted) {
          setState(() {
            _progressValue = i / redirectDelay;
          });
        }
      });
    }

    // Auto-redirect after delay
    Future.delayed(const Duration(seconds: redirectDelay), () {
      if (mounted) {
        setState(() {
          _isRedirecting = true;
        });
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
      // Determine user type from the provider or route info
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userType = userProvider.user != null
          ? userProvider.user!.role.toLowerCase()
          : 'caregiver'; // Default to caregiver for registration flows

      context.go('/login', extra: {'userType': userType});
    } else if (widget.fromPortal) {
      // If coming from subscription management portal, return to subscription management page
      context.go('/select-package');
    } else {
      // For existing users, go to dashboard based on their role
      navigateToDashboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
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
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Progress indicator showing redirect countdown
                Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        minHeight: 6.0,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Redirecting in ${((1.0 - _progressValue) * 4).ceil()} seconds...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isRegistration == true
                      ? 'Registration Complete!'
                      : 'Payment Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                widget.isRegistration == true
                    ? _buildWelcomeText(context)
                    : Text(
                        'Thank you for your payment! Your subscription has been updated successfully.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                if (widget.sessionId != null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Session ID: ${widget.sessionId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
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
                    onPressed: _navigateToNext,
                    child: Text(
                      widget.isRegistration == true
                          ? 'Continue to Login'
                          : widget.fromPortal
                          ? 'Return to Subscription Management'
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add the method after build
  Widget _buildWelcomeText(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final name = userProvider.user?.name ?? '';
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        children: [
          const TextSpan(text: 'Welcome to CareConnect'),
          if (name.isNotEmpty)
            TextSpan(
              text: ', ',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          if (name.isNotEmpty)
            TextSpan(
              text: name,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          const TextSpan(
            text:
                '! Your account has been created and your subscription is active. You can now log in to access all features.',
          ),
        ],
      ),
    );
  }
}
