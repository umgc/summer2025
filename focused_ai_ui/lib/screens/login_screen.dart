import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in_web/web_only.dart' as web show renderButton;

import '../constants/app_strings.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingControllers for the input fields
  final TextEditingController _moodleUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // GlobalKey for form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variable to manage the loading indicator for username/password login
  bool _isLoadingUsernamePass = false;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _moodleUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to handle the username/password login process
  void _handleusernamePasswordLogin() async {
    // Validate the form fields first
    if (_formKey.currentState?.validate() ?? false) {
      // If validation passes, set loading state
      setState(() {
        _isLoadingUsernamePass = true;
      });

      // Get the AuthService instance without listening for rebuilds
      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        await authService.signInWithMoodle(
          moodleUrl: _moodleUrlController.text,
          username: _usernameController.text,
          password: _passwordController.text,
        );

        // Navigation handled by main.dart's routing logic based on authService state
      } catch (e) {
        // Show an error message (e.g., using a SnackBar)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.loginFailed}: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Always set loading to false, even on error
        if (mounted) {
          setState(() {
            _isLoadingUsernamePass = false;
          });
        }
      }
    }
  }

  // AuthService listens to the authentication stream for results.

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for responsiveness: switch layout based on screen width
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // If width is greater than a certain breakpoint (e.g., 800 pixels), use Row layout
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                // Left side with logo
                Expanded(
                  child: _buildGradientLogoSection(),
                ),
                // Right side with login form
                Expanded(
                  child: _buildLoginFormSection(context),
                ),
              ],
            );
          } else {
            // For smaller screens, use a Column layout (logo on top, form below)
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildGradientLogoSection(height: MediaQuery.of(context).size.height * 0.3), // Make logo section smaller on mobile
                  _buildLoginFormSection(context, isMobile: true),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Helper method to build the gradient logo section
  Widget _buildGradientLogoSection({double? height}) {
    return Container(
      height: height, // Optional height for mobile
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa1c4fd), Color.fromARGB(255, 120, 236, 201)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ensure you have this asset in your pubspec.yaml under 'assets:'
            Image.asset('assets/focused_ai_logo.png', width: 400),
          ],
        ),
      ),
    );
  }

  // Helper method to build the login form section
  Widget _buildLoginFormSection(BuildContext context, {bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 30.0 : 60.0, vertical: isMobile ? 40.0 : 0.0),
      child: Center(
        child: SingleChildScrollView( // Added for scrollability on smaller screens if content overflows
          child: Form( // Wrap the form fields with a Form widget
            key: _formKey, // Assign the form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Text(
                  AppStrings.loginTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(AppStrings.loginDirections),
                SizedBox(height: 20),
                // Moodle URL field
                TextFormField(
                  controller: _moodleUrlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'https://your-moodle-site.com',
                    labelText: 'Moodle URL',
                    prefixIcon: Icon(Icons.web),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Moodle URL';
                    }
                    // Basic URL validation
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return 'Please enter a valid URL starting with http:// or https://';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppStrings.usernameHint,
                    labelText: AppStrings.usernameLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.usernameEmptyError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppStrings.passwordHint,
                    labelText: AppStrings.passwordLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordEmptyError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoadingUsernamePass ? null : _handleusernamePasswordLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoadingUsernamePass // Show loading indicator based on username/pass loading state
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            AppStrings.signInWithMoodleButton,
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(AppStrings.orContinueWith),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 15),
                // Conditionally render Google Sign-in button for web
                // The web.renderButton() intrinsically handles its own loading state and click.
                // It does not expose an onPressed callback like a Flutter button.
                if (kIsWeb) // Only for web
                  Align( // Center the button if it's smaller than full width
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 250, // Google's button has a fixed width
                      height: 45, // Match height of other buttons
                      child: web.renderButton(), // This renders the actual Google button
                    ),
                  )
                else // For non-web platforms (e.g., if you were to support mobile later)
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // For non-web, you'd call authService.signInWithGoogle() here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google Sign-in not implemented for this platform.')),
                        );
                      },
                      icon: Image.asset('assets/Google_G.png', height: 20),
                      label: const Text(
                        AppStrings.googleButton,
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  AppStrings.termsAndPrivacyText, // Using AppStrings
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}