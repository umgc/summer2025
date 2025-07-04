import '../../../../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../../config/env_constant.dart';

class CaregiverSignUpScreen extends StatefulWidget {
  const CaregiverSignUpScreen({super.key});

  @override
  State<CaregiverSignUpScreen> createState() => _CaregiverSignUpScreenState();
}

class _CaregiverSignUpScreenState extends State<CaregiverSignUpScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Personal Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();

  // Step 2: Contact Info
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 3: Payment Info
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _billingAddress1Controller = TextEditingController();
  final _billingAddress2Controller = TextEditingController();
  final _billingStateController = TextEditingController();
  final _billingZipController = TextEditingController();

  // Step 4: Account Info
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _continue() async {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    } else {
      if (_formKey.currentState!.validate()) {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }

        try {
          final fullName =
              '${_firstNameController.text} ${_lastNameController.text}';

          // ✅ REGISTER as CAREGIVER
          await AuthService.register(
            name: fullName,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: 'caregiver', // 👈 IMPORTANT
            verificationBaseUrl: getBackendBaseUrl(),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Caregiver account created! Please log in.'),
            ),
          );

          Navigator.pop(context); // or navigate to caregiver login screen
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registration failed: ${error.toString().replaceFirst("Exception: ", "")}',
              ),
            ),
          );
        }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Caregiver registration",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: _continue,
            onStepCancel: _goBack,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: details.onStepContinue,
                      child: Text(
                        _currentStep == 3
                            ? 'Complete Registration'
                            : 'Continue',
                      ),
                    ),
                    const SizedBox(width: 8),
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
                title: const Text("Step 1 of 4: Personal Information"),
                isActive: _currentStep >= 0,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'mm/dd/yyyy',
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text("Step 2 of 4: Contact Information"),
                isActive: _currentStep >= 1,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _address1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address line 1',
                      ),
                    ),
                    TextFormField(
                      controller: _address2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address line 2 (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                    TextFormField(
                      controller: _zipController,
                      decoration: const InputDecoration(labelText: 'ZIP Code'),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text("Step 3 of 4: Billing Information"),
                isActive: _currentStep >= 2,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("1. Subscription Summary:"),
                    const Text(
                      "Standard Plan - \$20/patient/month\nBilled monthly. Cancel anytime.",
                    ),
                    const SizedBox(height: 8),
                    const Text("2. Payment Details:"),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: const InputDecoration(
                              labelText: 'MM/YY',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _cvcController,
                            decoration: const InputDecoration(labelText: 'CVC'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("3. Billing Address:"),
                    TextFormField(
                      controller: _billingAddress1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address line 1',
                      ),
                    ),
                    TextFormField(
                      controller: _billingAddress2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address line 2 (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: _billingStateController,
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                    TextFormField(
                      controller: _billingZipController,
                      decoration: const InputDecoration(labelText: 'ZIP Code'),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text("Step 4 of 4: Account Access"),
                isActive: _currentStep >= 3,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Retype Password',
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(value: true, onChanged: (val) {}),
                        const Expanded(
                          child: Text(
                            "I understand and agree to our Terms & Conditions and Privacy Policy.",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
