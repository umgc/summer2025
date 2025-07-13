import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/services/auth_service.dart';

// Utility class to store registration data temporarily
class RegistrationData {
  static String? _email;
  static String? _password;
  static String? _firstName;
  static String? _lastName;
  static String? _dob;
  static String? _phone;
  static String? _licenseNumber;
  static String? _issuingState;
  static int? _yearsExperience;
  static String? _addressLine1;
  static String? _addressLine2;
  static String? _city;
  static String? _state;
  static String? _zip;

  static void setBasicData({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    _email = email;
    _password = password;
    _firstName = firstName;
    _lastName = lastName;
  }

  static void setPersonalData({required String dob, required String phone}) {
    _dob = dob;
    _phone = phone;
  }

  static void setProfessionalData({
    String? licenseNumber,
    String? issuingState,
    int? yearsExperience,
  }) {
    _licenseNumber = licenseNumber;
    _issuingState = issuingState;
    _yearsExperience = yearsExperience;
  }

  static void setAddressData({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zip,
  }) {
    _addressLine1 = addressLine1;
    _addressLine2 = addressLine2;
    _city = city;
    _state = state;
    _zip = zip;
  }

  // Getters
  static String? get email => _email;
  static String? get password => _password;
  static String? get firstName => _firstName;
  static String? get lastName => _lastName;
  static String? get dob => _dob;
  static String? get phone => _phone;
  static String? get licenseNumber => _licenseNumber;
  static String? get issuingState => _issuingState;
  static int? get yearsExperience => _yearsExperience;
  static String? get addressLine1 => _addressLine1;
  static String? get addressLine2 => _addressLine2;
  static String? get city => _city;
  static String? get state => _state;
  static String? get zip => _zip;
  static String get fullName => '${_firstName ?? ''} ${_lastName ?? ''}';

  static void clear() {
    _email = null;
    _password = null;
    _firstName = null;
    _lastName = null;
    _dob = null;
    _phone = null;
    _licenseNumber = null;
    _issuingState = null;
    _yearsExperience = null;
    _addressLine1 = null;
    _addressLine2 = null;
    _city = null;
    _state = null;
    _zip = null;
  }
}

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

  // Controllers for all form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _issuingStateController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  void _continue() async {
    if (_currentStep < 5) {
      // Now we have 6 steps (0-5)
      // Validate current step before moving to next
      if (_validateCurrentStep()) {
        setState(() => _currentStep += 1);
      }
      return;
    }

    // Final step - store all data and proceed
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => errorMessage = "Passwords do not match");
        return;
      }

      // Store all registration data
      RegistrationData.setBasicData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      RegistrationData.setPersonalData(
        dob: _dobController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      RegistrationData.setProfessionalData(
        licenseNumber: _licenseNumberController.text.trim().isNotEmpty
            ? _licenseNumberController.text.trim()
            : null,
        issuingState: _issuingStateController.text.trim().isNotEmpty
            ? _issuingStateController.text.trim()
            : null,
        yearsExperience: _yearsExperienceController.text.trim().isNotEmpty
            ? int.tryParse(_yearsExperienceController.text.trim())
            : null,
      );

      RegistrationData.setAddressData(
        addressLine1: _addressLine1Controller.text.trim().isNotEmpty
            ? _addressLine1Controller.text.trim()
            : null,
        addressLine2: _addressLine2Controller.text.trim().isNotEmpty
            ? _addressLine2Controller.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        state: _stateController.text.trim().isNotEmpty
            ? _stateController.text.trim()
            : null,
        zip: _zipController.text.trim().isNotEmpty
            ? _zipController.text.trim()
            : null,
      );

      // Navigate to payment selection for caregiver registration
      context.go('/register/caregiver/payment');
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal Info
        return _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty &&
            _dobController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty;
      case 1: // Account Info
        return _emailController.text.isNotEmpty &&
            _passwordController.text.length >= 6;
      case 2: // Professional Info (Optional)
        return true; // Let backend handle validation
      case 3: // Address Info (Optional)
        return true; // Let backend handle validation
      default:
        return true;
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Not provided' : value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Sign Up'), backgroundColor: darkBlue),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: isLoading ? null : details.onStepContinue,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _currentStep == 5
                                    ? 'Continue to Payment'
                                    : 'Continue',
                              ),
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
                  title: const Text("Step 1 of 6: Personal Information"),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'First name required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Last name required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth (MM/DD/YYYY)*',
                          border: OutlineInputBorder(),
                          hintText: '01/01/1990',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Date of birth required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number*',
                          border: OutlineInputBorder(),
                          hintText: '240-555-5555',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Phone number required' : null,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Step 2 of 6: Account Credentials"),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email*',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return 'Email is required';
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.length < 6 ? 'Minimum 6 characters' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text(
                    "Step 3 of 6: Professional Information (Optional)",
                  ),
                  isActive: _currentStep >= 2,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _licenseNumberController,
                        decoration: const InputDecoration(
                          labelText: 'License Number',
                          border: OutlineInputBorder(),
                          hintText: 'AA123456 (Optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _issuingStateController,
                        decoration: const InputDecoration(
                          labelText: 'Issuing State',
                          border: OutlineInputBorder(),
                          hintText: 'VA (Optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearsExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Years of Experience',
                          border: OutlineInputBorder(),
                          hintText: '5 (Optional)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text(
                    "Step 4 of 6: Address Information (Optional)",
                  ),
                  isActive: _currentStep >= 3,
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _addressLine1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address Line 1',
                          border: OutlineInputBorder(),
                          hintText: '112 SE Ave (Optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressLine2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address Line 2 (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Apt 103',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                                hintText: 'McLean (Optional)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: const InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(),
                                hintText: 'VA (Optional)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _zipController,
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code',
                          border: OutlineInputBorder(),
                          hintText: '19053 (Optional)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Step 5 of 6: Review Information"),
                  isActive: _currentStep >= 4,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please review your information:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildReviewRow(
                        'Name',
                        '${_firstNameController.text} ${_lastNameController.text}',
                      ),
                      _buildReviewRow('Email', _emailController.text),
                      _buildReviewRow('Phone', _phoneController.text),
                      _buildReviewRow('Date of Birth', _dobController.text),
                      _buildReviewRow(
                        'License Number',
                        _licenseNumberController.text,
                      ),
                      _buildReviewRow(
                        'Issuing State',
                        _issuingStateController.text,
                      ),
                      _buildReviewRow(
                        'Years Experience',
                        _yearsExperienceController.text,
                      ),
                      _buildReviewRow(
                        'Address',
                        '${_addressLine1Controller.text}${_addressLine2Controller.text.isNotEmpty ? ', ${_addressLine2Controller.text}' : ''}',
                      ),
                      _buildReviewRow(
                        'City, State ZIP',
                        '${_cityController.text}, ${_stateController.text} ${_zipController.text}',
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text("Step 6 of 6: Terms & Conditions"),
                  isActive: _currentStep >= 5,
                  content: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (_) {}),
                          const Expanded(
                            child: Text(
                              "I agree to the Terms & Conditions and Privacy Policy.",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'By proceeding, you will be directed to select a subscription package and complete payment. Your caregiver account will be created after successful payment.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
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

class CaregiverRegistrationFlowPage extends StatefulWidget {
  const CaregiverRegistrationFlowPage({super.key});

  @override
  State<CaregiverRegistrationFlowPage> createState() =>
      _CaregiverRegistrationFlowPageState();
}

class _CaregiverRegistrationFlowPageState
    extends State<CaregiverRegistrationFlowPage> {
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1: Register the caregiver first, then navigate to package selection
  Future<void> _registerCaregiverThenPay() async {
    setState(() => _isLoading = true);
    setState(() => _errorMessage = null);

    try {
      print('Creating caregiver account first...');
      print('Using registration data:');
      print('   - Name: ${RegistrationData.fullName}');
      print('   - Email: ${RegistrationData.email}');
      print('   - DOB: ${RegistrationData.dob}');
      print('   - Phone: ${RegistrationData.phone}');
      print('   - License: ${RegistrationData.licenseNumber}');
      print('   - State: ${RegistrationData.issuingState}');
      print('   - Years: ${RegistrationData.yearsExperience}');
      print('   - Address1: ${RegistrationData.addressLine1}');
      print('   - Address2: ${RegistrationData.addressLine2}');
      print('   - City: ${RegistrationData.city}');
      print('   - State: ${RegistrationData.state}');
      print('   - ZIP: ${RegistrationData.zip}');

      // Register the caregiver using the proper API endpoint with form data
      await AuthService.registerCaregiver(
        firstName: RegistrationData.firstName!,
        lastName: RegistrationData.lastName!,
        email: RegistrationData.email!,
        password: RegistrationData.password!,
        dob: RegistrationData.dob!,
        phone: RegistrationData.phone!,
        licenseNumber: RegistrationData.licenseNumber,
        issuingState: RegistrationData.issuingState,
        yearsExperience: RegistrationData.yearsExperience,
        addressLine1: RegistrationData.addressLine1,
        addressLine2: RegistrationData.addressLine2,
        city: RegistrationData.city,
        state: RegistrationData.state,
        zip: RegistrationData.zip,
      );

      print('Caregiver account created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Now select your subscription package.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Now navigate to package selection for payment
        _navigateToPackageSelection();
      }
    } catch (e) {
      print('Caregiver registration failed: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Registration error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Step 2: Navigate to package selection (after account is created)
  void _navigateToPackageSelection() {
    print('Navigating to package selection...');
    context.go('/select-package');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Registration'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to CareConnect!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Hello ${RegistrationData.firstName},\nYour account will be created first, then you\'ll select a subscription package.\nAfter successful payment, you can log in to access CareConnect.',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: _registerCaregiverThenPay,
                    child: const Text('Complete Registration & Pay'),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
