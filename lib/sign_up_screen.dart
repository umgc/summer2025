import 'package:flutter/material.dart';
import 'package:care_connect_app/services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _continue() async {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => errorMessage = "Passwords do not match");
        return;
      }

      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final fullName = '${_firstNameController.text} ${_lastNameController.text}';
        await AuthService.register(
          name: fullName,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please log in.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } catch (error) {
        setState(() => errorMessage = error.toString().replaceAll('Exception: ', ''));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Patient Registration"),
        backgroundColor: darkBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _continue,
              onStepCancel: _goBack,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: isLoading ? null : details.onStepContinue,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_currentStep == 2 ? 'Complete Registration' : 'Continue'),
                      ),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text("Step 1 of 3: Personal Information"),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (value) => value!.isEmpty ? 'First name required' : null,
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (value) => value!.isEmpty ? 'Last name required' : null,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Step 2 of 3: Account Info"),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) => value!.isEmpty ? 'Email is required' : null,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (value) => value!.length < 6 ? 'Minimum 6 characters' : null,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                        validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Step 3 of 3: Terms & Conditions"),
                  isActive: _currentStep >= 2,
                  content: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (_) {}),
                          const Expanded(child: Text("I agree to the Terms & Conditions and Privacy Policy.")),
                        ],
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
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
