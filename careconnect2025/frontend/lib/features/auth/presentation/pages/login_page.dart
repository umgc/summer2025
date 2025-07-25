import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../services/enhanced_auth_service.dart';
import '../../../../widgets/role_mismatch_dialog.dart';
import '../../../../providers/user_provider.dart';
import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../widgets/responsive_page_wrapper.dart';
import '../../../../utils/responsive_utils.dart';

class LoginPage extends StatefulWidget {
  final String? userType;

  const LoginPage({super.key, this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  bool _busy = false;
  bool _googleSignInBusy = false;
  String? _error;
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      // Get userType from widget or from GoRouter extra data
      final extra = GoRouter.of(
        context,
      ).routerDelegate.currentConfiguration.extra;
      String role = 'patient'; // Default

      if (widget.userType != null) {
        role = widget.userType!;
      } else if (extra != null &&
          extra is Map<String, dynamic> &&
          extra.containsKey('userType')) {
        role = extra['userType'];
      }

      // Use enhanced authentication service with role validation
      final authResult = await EnhancedAuthService.loginWithRoleValidation(
        email: _email.text.trim(),
        password: _pwd.text,
        expectedRole: role,
      );

      if (authResult.isSuccess) {
        // Login and role validation successful
        final user = authResult.userSession!;

        // Save user info to Provider
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        // Add a small delay to ensure JWT token is fully saved before navigation
        await Future.delayed(const Duration(milliseconds: 100));

        // Navigate to the appropriate dashboard based on user role
        navigateToDashboard(context);
      } else {
        // Handle different types of authentication errors
        if (authResult.errorType == AuthErrorType.roleValidation) {
          // Show role mismatch dialog
          await RoleMismatchDialog.show(
            context: context,
            actualRole: authResult.actualRole!,
            expectedRole: authResult.expectedRole!,
            correctLoginRoute: authResult.correctLoginRoute!,
            message: authResult.errorMessage!,
          );
        } else {
          // Show regular authentication error
          setState(() {
            _error = authResult.errorMessage;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed: $e';
      });
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _googleSignInBusy = true;
      _error = null;
    });

    try {
      // Get userType from widget or from GoRouter extra data
      final extra = GoRouter.of(
        context,
      ).routerDelegate.currentConfiguration.extra;
      String role = 'patient'; // Default

      if (widget.userType != null) {
        role = widget.userType!;
      } else if (extra != null &&
          extra is Map<String, dynamic> &&
          extra.containsKey('userType')) {
        role = extra['userType'];
      }

      // Use enhanced authentication service with role validation for Google login
      final authResult =
          await EnhancedAuthService.loginWithGoogleAndRoleValidation(
            expectedRole: role,
          );

      if (authResult.isSuccess) {
        // Login and role validation successful
        final user = authResult.userSession!;

        // Save user info to Provider
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        // Add a small delay to ensure JWT token is fully saved before navigation
        await Future.delayed(const Duration(milliseconds: 100));

        // Navigate to the appropriate dashboard based on user role
        navigateToDashboard(context);
      } else {
        // Handle different types of authentication errors
        if (authResult.errorType == AuthErrorType.roleValidation) {
          // Show role mismatch dialog
          await RoleMismatchDialog.show(
            context: context,
            actualRole: authResult.actualRole!,
            expectedRole: authResult.expectedRole!,
            correctLoginRoute: authResult.correctLoginRoute!,
            message: authResult.errorMessage!,
          );
        } else {
          // Show regular authentication error
          setState(() {
            _error = authResult.errorMessage;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Google Sign-In failed: $e';
      });
    } finally {
      setState(() => _googleSignInBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.extra;
    String userType = 'patient'; // Default

    if (widget.userType != null) {
      userType = widget.userType!;
    } else if (extra != null &&
        extra is Map<String, dynamic> &&
        extra.containsKey('userType')) {
      userType = extra['userType'];
    }

    // Set display based on user type using centralized theme
    final bool isCaregiver = userType == 'caregiver';
    final String userTypeDisplay = isCaregiver ? 'Caregiver' : 'Patient';
    final IconData userIcon = isCaregiver
        ? Icons.health_and_safety
        : Icons.person;

    // Create a custom app bar with consistent styling
    final appBar = AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/'),
        color: Colors.white,
      ),
    );

    return ResponsivePageWrapper(
      backgroundColor: Colors.white,
      customAppBar: appBar,
      centerContent: true,
      applyPadding: false, // We'll handle padding in the content
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: context.responsiveValue(
                mobile: double.infinity,
                tablet: 500.0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(userIcon, size: 60, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Care Connect',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Closer Connections. Better Care',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$userTypeDisplay Login',
                      textAlign: TextAlign.center,
                      style: AppTheme.headingSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _email,
                    decoration:
                        AppTheme.inputDecoration(
                          'Email',
                          hint: 'Enter your email',
                        ).copyWith(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: AppTheme.primary,
                          ),
                        ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _pwd,
                    obscureText: !_showPassword,
                    decoration:
                        AppTheme.inputDecoration(
                          'Password',
                          hint: 'Enter your password',
                        ).copyWith(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppTheme.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _login,
                      style: AppTheme.primaryButtonStyle,
                      child: _busy
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Log in', style: AppTheme.buttonText),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _googleSignInBusy ? null : _loginWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        elevation: 1,
                        shadowColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: _googleSignInBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google "G" logo representation
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Sign in with Google',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/reset-password'),
                    child: const Text('Forgot your password?'),
                  ),
                  // Only show sign up option for caregivers (hide for patients)
                  if (userType.toLowerCase() == 'caregiver')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
