import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/services/auth_service.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/responsive_container.dart';

// Utility class to store registration data temporarily
class RegistrationData {
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

class SignUpScreen extends StatefulWidget {
  final String userType;
  const SignUpScreen({super.key, this.userType = 'caregiver'});

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

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _selectedGender;

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
        gender: _selectedGender,
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

  // Validation methods
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return null; // Don't show error for empty field initially
    }

    // More comprehensive email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return null; // Don't show error for empty field initially
    }

    if (password.length < 6) return 'Minimum 6 characters required';

    // Additional password strength checks
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    if (!hasUppercase || !hasDigits || !hasSpecialCharacters) {
      return 'Password should contain uppercase, digits, and special characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) {
      return null; // Don't show error for empty field initially
    }
    if (confirmPassword != password) return 'Passwords do not match';
    return null;
  }

  String? _validateName(String name) {
    if (name.isEmpty) return null; // Don't show error for empty field initially

    // Check if the name contains any digits
    if (RegExp(r'\d').hasMatch(name)) {
      return 'Name cannot contain numbers';
    }

    // Check if the name is too short
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  String? _validateCity(String city) {
    if (city.isEmpty) return null; // Don't show error for empty field initially

    // Check if city contains numbers
    if (RegExp(r'\d').hasMatch(city)) {
      return 'City name cannot contain numbers';
    }

    // Check for special characters (allowing spaces, hyphens, periods)
    final cityRegex = RegExp(r'^[a-zA-Z\s\.\-]+$');
    if (!cityRegex.hasMatch(city)) {
      return 'City name contains invalid characters';
    }

    return null;
  }

  String? _validateState(String state) {
    if (state.isEmpty) {
      return null; // Don't show error for empty field initially
    }

    // Check if state contains numbers
    if (RegExp(r'\d').hasMatch(state)) {
      return 'State name cannot contain numbers';
    }

    // Check for special characters (allowing spaces and hyphens)
    final stateRegex = RegExp(r'^[a-zA-Z\s\-]+$');
    if (!stateRegex.hasMatch(state)) {
      return 'State name contains invalid characters';
    }

    return null;
  }

  String? _validatePhone(String phone) {
    if (phone.isEmpty) {
      return null; // Don't show error for empty field initially
    }

    // Basic phone number validation - ensure it has the right length and only contains digits, dashes, spaces, and parentheses
    final phoneRegex = RegExp(r'^[\d\-\(\)\s]{10,15}$');
    if (!phoneRegex.hasMatch(phone)) return 'Enter a valid phone number';
    return null;
  }

  String? _validateZip(String zip) {
    if (zip.isEmpty) return null; // Don't show error for empty field initially

    // US zip code validation
    final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
    if (!zipRegex.hasMatch(zip)) return 'Enter a valid ZIP code';
    return null;
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal Info
        return _firstNameController.text.isNotEmpty &&
            _validateName(_firstNameController.text) == null &&
            _lastNameController.text.isNotEmpty &&
            _validateName(_lastNameController.text) == null &&
            _dobController.text.isNotEmpty &&
            _validatePhone(_phoneController.text) == null &&
            _phoneController.text.isNotEmpty;
      case 1: // Account Info
        return _emailController.text.isNotEmpty &&
            _validateEmail(_emailController.text) == null &&
            _passwordController.text.length >= 6 &&
            _validatePassword(_passwordController.text) == null &&
            _confirmPasswordController.text == _passwordController.text;
      case 2: // Professional Info (Optional)
        return true; // Let backend handle validation
      case 3: // Address Info
        if (_addressLine1Controller.text.isNotEmpty ||
            _cityController.text.isNotEmpty ||
            _stateController.text.isNotEmpty ||
            _zipController.text.isNotEmpty) {
          // If any address field is filled, validate all required address fields
          return (_cityController.text.isEmpty ||
                  _validateCity(_cityController.text) == null) &&
              (_stateController.text.isEmpty ||
                  _validateState(_stateController.text) == null) &&
              (_zipController.text.isEmpty ||
                  _validateZip(_zipController.text) == null);
        }
        return true; // Address is optional
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
  void initState() {
    super.initState();

    // Set up listeners for real-time validation
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
    _dobController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _addressLine1Controller.addListener(() => setState(() {}));
    _cityController.addListener(() => setState(() {}));
    _stateController.addListener(() => setState(() {}));
    _zipController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Clean up controllers
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

  @override
  Widget build(BuildContext context) {
    // Use the centralized theme system for consistent colors

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarHelper.createAppBar(context, title: 'Sign Up'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            maxWidth: 800, // Set appropriate max width for the sign-up form
            centerContent: true,
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
                          style: AppTheme.primaryButtonStyle,
                          onPressed: isLoading ? null : details.onStepContinue,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: AppTheme.textLight,
                                )
                              : Text(
                                  _currentStep == 5
                                      ? 'Continue to Payment'
                                      : 'Continue',
                                ),
                        ),
                        if (_currentStep > 0)
                          TextButton(
                            style: AppTheme.textButtonStyle,
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
                          decoration:
                              AppTheme.inputDecoration(
                                'First Name*',
                                hint: 'Enter your first name',
                              ).copyWith(
                                errorText: _validateName(
                                  _firstNameController.text,
                                ),
                              ),
                          validator: (value) {
                            if (value!.isEmpty) return 'First name required';
                            return _validateName(value);
                          },
                          onChanged: (_) => setState(() {}),
                          textCapitalization: TextCapitalization
                              .words, // Auto-capitalize each word
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration:
                              AppTheme.inputDecoration(
                                'Last Name*',
                                hint: 'Enter your last name',
                              ).copyWith(
                                errorText: _validateName(
                                  _lastNameController.text,
                                ),
                              ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Last name required';
                            return _validateName(value);
                          },
                          onChanged: (_) => setState(() {}),
                          textCapitalization: TextCapitalization
                              .words, // Auto-capitalize each word
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          decoration:
                              AppTheme.inputDecoration(
                                'Date of Birth (MM/DD/YYYY)*',
                                hint: '01/01/1990',
                              ).copyWith(
                                errorText:
                                    _dobController.text.isEmpty &&
                                        _dobController.text.isNotEmpty
                                    ? 'Date of birth required'
                                    : null,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(1990, 1, 1),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          helpText: 'Select Date of Birth',
                                        );
                                    if (picked != null) {
                                      // Format date as MM/DD/YYYY
                                      final month = picked.month
                                          .toString()
                                          .padLeft(2, '0');
                                      final day = picked.day.toString().padLeft(
                                        2,
                                        '0',
                                      );
                                      final year = picked.year.toString();
                                      setState(() {
                                        _dobController.text =
                                            '$month/$day/$year';
                                      });
                                    }
                                  },
                                ),
                              ),
                          validator: (value) =>
                              value!.isEmpty ? 'Date of birth required' : null,
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
                            if (value!.isEmpty) return 'Phone number required';
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
                            if (value!.isEmpty) return 'Email is required';
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
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
                                hint: 'Minimum 6 characters',
                              ).copyWith(
                                errorText: _validatePassword(
                                  _passwordController.text,
                                ),
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
                          validator: (value) =>
                              value!.length < 6 ? 'Minimum 6 characters' : null,
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
                                errorText: _validateConfirmPassword(
                                  _confirmPasswordController.text,
                                  _passwordController.text,
                                ),
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
                          validator: (value) =>
                              value != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
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
                        TextFormField(
                          controller: _licenseNumberController,
                          decoration: AppTheme.inputDecoration(
                            'License Number',
                            hint: 'AA123456',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _issuingStateController,
                          decoration: AppTheme.inputDecoration(
                            'Issuing State',
                            hint: 'VA',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _yearsExperienceController,
                          decoration: AppTheme.inputDecoration(
                            'Years of Experience',
                            hint: '5',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text("Step 4 of 6: Address Information"),
                    isActive: _currentStep >= 3,
                    content: Column(
                      children: [
                        TextFormField(
                          controller: _addressLine1Controller,
                          decoration: AppTheme.inputDecoration(
                            'Address Line 1',
                            hint: '112 SE Ave',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressLine2Controller,
                          decoration: AppTheme.inputDecoration(
                            'Address Line 2',
                            hint: 'Apt 103',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _cityController,
                                decoration:
                                    AppTheme.inputDecoration(
                                      'City',
                                      hint: 'McLean',
                                    ).copyWith(
                                      errorText: _validateCity(
                                        _cityController.text,
                                      ),
                                    ),
                                validator: (value) => _validateCity(value!),
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _stateController,
                                decoration:
                                    AppTheme.inputDecoration(
                                      'State',
                                      hint: 'VA',
                                    ).copyWith(
                                      errorText: _validateState(
                                        _stateController.text,
                                      ),
                                    ),
                                validator: (value) => _validateState(value!),
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _zipController,
                          decoration:
                              AppTheme.inputDecoration(
                                'ZIP Code',
                                hint: '19053',
                              ).copyWith(
                                errorText: _validateZip(_zipController.text),
                              ),
                          validator: (value) => _validateZip(value!),
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
                        _buildReviewRow(
                          'Gender',
                          _selectedGender ?? 'Not specified',
                        ),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: AppTheme.error),
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
  String? _userId;
  String? _stripeCustomerId;

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
      final registrationResult = await AuthService.registerCaregiver(
        firstName: RegistrationData.firstName!,
        lastName: RegistrationData.lastName!,
        email: RegistrationData.email!,
        password: RegistrationData.password!,
        dob: RegistrationData.dob!,
        phone: RegistrationData.phone!,
        gender: RegistrationData.gender,
        licenseNumber: RegistrationData.licenseNumber,
        issuingState: RegistrationData.issuingState,
        yearsExperience: RegistrationData.yearsExperience,
        addressLine1: RegistrationData.addressLine1,
        addressLine2: RegistrationData.addressLine2,
        city: RegistrationData.city,
        state: RegistrationData.state,
        zip: RegistrationData.zip,
      );

      // Store the user ID and stripeCustomerId from the registration response
      _userId = registrationResult['userId'];
      _stripeCustomerId = registrationResult['stripeCustomerId'];
      print(
        'Caregiver account created successfully with userId: $_userId, stripeCustomerId: $_stripeCustomerId',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // Removed 'const' here because backgroundColor is not a compile-time constant
            content: Text(
              'Account created successfully! Now select your subscription package.',
              style: TextStyle(
                color: AppTheme.textLight,
              ), // Use white text for contrast
            ),
            backgroundColor:
                AppTheme.primary, // Use the centralized theme color
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
    print(
      'Navigating to package selection with userId: $_userId, stripeCustomerId: $_stripeCustomerId',
    );
    // Pass userId and stripeCustomerId in the query parameters to the package selection page
    context.go(
      '/select-package?userId=$_userId&stripeCustomerId=${_stripeCustomerId ?? ""}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Registration'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: theme.primaryColor)
            : Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to CareConnect!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hello ${RegistrationData.firstName},\nYour account will be created first, then you\'ll select a subscription package.\nAfter successful payment, you can log in to access CareConnect.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: AppTheme.primaryButtonStyle,
                      onPressed: _registerCaregiverThenPay,
                      child: const Text('Complete Registration & Pay'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
