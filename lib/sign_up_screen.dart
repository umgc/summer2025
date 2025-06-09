import 'package:flutter/material.dart';

class sign_up_screen extends StatefulWidget {
  const sign_up_screen({super.key});

  @override
  State<sign_up_screen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<sign_up_screen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _continue() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      if (_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created!')),
        );
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
    const darkBlue = Color(0xFF0D47A1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient registration"),
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
                        onPressed: details.onStepContinue,
                        child: Text(_currentStep == 2 ? 'Complete Registration' : 'Continue'),
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
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                      ),
                      TextFormField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                          hintText: 'mm/dd/yyyy',
                        ),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Step 2 of 3: Contact Information"),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
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
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Step 3 of 3: Account Access"),
                  isActive: _currentStep >= 2,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(value: true, onChanged: (val) {}),
                            Expanded(
                              child: Text(
                                "I understand and agree to the Terms & Conditions and Privacy Policy.",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
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
