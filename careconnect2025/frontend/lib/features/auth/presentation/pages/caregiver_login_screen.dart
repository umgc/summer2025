import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/auth_service.dart';
import '../../../../providers/user_provider.dart';
import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_theme.dart';

class CaregiverLoginScreen extends StatefulWidget {
  const CaregiverLoginScreen({super.key});

  @override
  State<CaregiverLoginScreen> createState() => _CaregiverLoginScreenState();
}

class _CaregiverLoginScreenState extends State<CaregiverLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
        role: 'caregiver',
      );

      if (user.role.toUpperCase() == 'CAREGIVER') {
        // Update UserProvider with the logged-in user
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);

          // Add a small delay to ensure JWT token is fully saved before navigation
          await Future.delayed(const Duration(milliseconds: 100));

          navigateToDashboard(context);
        }
      } else {
        setState(() {
          errorMessage = "You are not registered as a caregiver.";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Caregiver Login'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textLight,
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Caregiver Login',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: AppTheme.inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: AppTheme.inputDecoration('Password'),
                  ),
                  const SizedBox(height: 10),
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: AppTheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: AppTheme.primaryButtonStyle,
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const CircularProgressIndicator(color: AppTheme.textLight)
                          : const Text('Log in', style: AppTheme.buttonText),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    style: AppTheme.textButtonStyle,
                    onPressed: () => context.go('/reset-password'),
                    child: const Text('Forgot your password?'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    style: AppTheme.textButtonStyle,
                    onPressed: () => context.go('/signup'),
                    child: const Text('Register here for an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
