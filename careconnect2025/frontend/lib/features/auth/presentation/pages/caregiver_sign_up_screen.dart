import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';

class CaregiverRegistrationData {
  static String? _email;
  static String? _password;
  static String? _firstName;
  static String? _lastName;
  static String? _dob;
  static String? _phone;
  static String? _gender;
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

  static void setPersonalData({
    required String dob,
    required String phone,
    String? gender,
  }) {
    _dob = dob;
    _phone = phone;
    _gender = gender;
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
  static String? get gender => _gender;
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
    _gender = null;
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

class CaregiverSignUpScreen extends StatefulWidget {
  const CaregiverSignUpScreen({super.key});

  @override
  State<CaregiverSignUpScreen> createState() => _CaregiverSignUpScreenState();
}

class _CaregiverSignUpScreenState extends State<CaregiverSignUpScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

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

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _selectedGender;

  void _continue() async {
    if (_currentStep < 5) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep += 1);
      }
      return;
    }

    // Final step - store all data and proceed
    if (_formKey.currentState!.validate()) {
      // Store all data
      CaregiverRegistrationData.setBasicData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      CaregiverRegistrationData.setPersonalData(
        dob: _dobController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
      );

      CaregiverRegistrationData.setProfessionalData(
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

      CaregiverRegistrationData.setAddressData(
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

      await _registerCaregiver();
    }
  }

  Future<void> _registerCaregiver() async {
    setState(() => _isLoading = true);

    try {
      // Mock registration - in production would call actual API
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        CaregiverRegistrationData.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caregiver registration completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal Information
        return _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty &&
            _dobController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _validatePhone(_phoneController.text) == null;
      case 1: // Account Credentials
        return _emailController.text.isNotEmpty &&
            _validateEmail(_emailController.text) == null &&
            _passwordController.text.isNotEmpty &&
            _passwordController.text.length >= 8 &&
            _confirmPasswordController.text == _passwordController.text;
      case 2: // Professional Information (optional for caregivers)
        return true;
      case 3: // Address Information (optional)
        return true;
      case 4: // Review
        return true;
      default:
        return false;
    }
  }

  String? _validateEmail(String email) {
    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$|^\d{3}-\d{3}-\d{4}$');
    if (!phoneRegex.hasMatch(phone.replaceAll(' ', '').replaceAll('-', ''))) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to update UI
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
    _dobController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _issuingStateController.dispose();
    _yearsExperienceController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Registration'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).primaryColor,
                  ),
                ),
                child: Stepper(
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    // Allow tapping on previous steps only
                    if (step <= _currentStep) {
                      setState(() => _currentStep = step);
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Row(
                      children: [
                        if (details.stepIndex < 5)
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Continue'),
                          ),
                        if (details.stepIndex == 5)
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Register'),
                          ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: Text(
                            details.stepIndex == 0 ? 'Cancel' : 'Back',
                          ),
                        ),
                      ],
                    );
                  },
                  onStepContinue: _continue,
                  onStepCancel: _cancel,
                  steps: [
                    Step(
                      title: const Text("Step 1 of 6: Personal Information"),
                      isActive: _currentStep >= 0,
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            decoration: AppTheme.inputDecoration(
                              'First Name*',
                              hint: 'John',
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'First name required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: AppTheme.inputDecoration(
                              'Last Name*',
                              hint: 'Doe',
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Last name required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _dobController,
                            decoration:
                                AppTheme.inputDecoration(
                                  'Date of Birth*',
                                  hint: 'MM/DD/YYYY',
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_today),
                                    onPressed: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().subtract(
                                          const Duration(days: 6570),
                                        ),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now().subtract(
                                          const Duration(days: 6570),
                                        ),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _dobController.text =
                                              '${date.month.toString().padLeft(2, '0')}/'
                                              '${date.day.toString().padLeft(2, '0')}/'
                                              '${date.year}';
                                        });
                                      }
                                    },
                                  ),
                                ),
                            validator: (value) => value!.isEmpty
                                ? 'Date of birth required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration:
                                AppTheme.inputDecoration(
                                  'Phone Number*',
                                  hint: '240-555-5555',
                                ).copyWith(
                                  errorText: _validatePhone(
                                    _phoneController.text,
                                  ),
                                ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Phone number required';
                              }
                              return _validatePhone(value);
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: AppTheme.inputDecoration(
                              'Gender',
                              hint: 'Select your gender',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text('Other'),
                              ),
                              DropdownMenuItem(
                                value: 'prefer_not_to_say',
                                child: Text('Prefer not to say'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
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
                            decoration:
                                AppTheme.inputDecoration(
                                  'Email*',
                                  hint: 'name@example.com',
                                ).copyWith(
                                  errorText: _validateEmail(
                                    _emailController.text,
                                  ),
                                ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) return 'Email required';
                              return _validateEmail(value);
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration:
                                AppTheme.inputDecoration(
                                  'Password*',
                                  hint: 'Minimum 8 characters',
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                ),
                            validator: (value) {
                              if (value!.isEmpty) return 'Password required';
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration:
                                AppTheme.inputDecoration(
                                  'Confirm Password*',
                                  hint: 'Re-enter your password',
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showConfirmPassword =
                                            !_showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please confirm password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
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
                          const Text(
                            'Professional information is optional for caregivers.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _licenseNumberController,
                            decoration: AppTheme.inputDecoration(
                              'License Number',
                              hint:
                                  'Professional license number (if applicable)',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _issuingStateController,
                            decoration: AppTheme.inputDecoration(
                              'Issuing State',
                              hint: 'State that issued the license',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _yearsExperienceController,
                            decoration: AppTheme.inputDecoration(
                              'Years of Experience',
                              hint: 'Years of caregiving experience',
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
                            decoration: AppTheme.inputDecoration(
                              'Address Line 1',
                              hint: '123 Main Street',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressLine2Controller,
                            decoration: AppTheme.inputDecoration(
                              'Address Line 2',
                              hint: 'Apt 4B (optional)',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: AppTheme.inputDecoration(
                                    'City',
                                    hint: 'New York',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _stateController,
                                  decoration: AppTheme.inputDecoration(
                                    'State',
                                    hint: 'NY',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _zipController,
                                  decoration: AppTheme.inputDecoration(
                                    'ZIP',
                                    hint: '10001',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
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
                          _buildReviewRow(
                            'Gender',
                            _selectedGender ?? 'Not specified',
                          ),
                          _buildReviewRow('Date of Birth', _dobController.text),
                          if (_licenseNumberController.text.isNotEmpty)
                            _buildReviewRow(
                              'License Number',
                              _licenseNumberController.text,
                            ),
                          if (_issuingStateController.text.isNotEmpty)
                            _buildReviewRow(
                              'Issuing State',
                              _issuingStateController.text,
                            ),
                          if (_yearsExperienceController.text.isNotEmpty)
                            _buildReviewRow(
                              'Years of Experience',
                              _yearsExperienceController.text,
                            ),
                          if (_addressLine1Controller.text.isNotEmpty)
                            _buildReviewRow('Address', _getFormattedAddress()),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text("Step 6 of 6: Confirmation"),
                      isActive: _currentStep >= 5,
                      content: const Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Ready to create your caregiver account!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Click "Register" to complete your registration.',
                            textAlign: TextAlign.center,
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

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
          Expanded(child: Text(value.isNotEmpty ? value : 'Not provided')),
        ],
      ),
    );
  }

  String _getFormattedAddress() {
    final parts = <String>[];
    if (_addressLine1Controller.text.isNotEmpty) {
      parts.add(_addressLine1Controller.text);
    }
    if (_addressLine2Controller.text.isNotEmpty) {
      parts.add(_addressLine2Controller.text);
    }
    if (_cityController.text.isNotEmpty) {
      parts.add(_cityController.text);
    }
    if (_stateController.text.isNotEmpty) {
      parts.add(_stateController.text);
    }
    if (_zipController.text.isNotEmpty) {
      parts.add(_zipController.text);
    }
    return parts.join(', ');
  }
}
