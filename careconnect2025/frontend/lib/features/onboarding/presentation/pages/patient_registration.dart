import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import '../../models/address_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientRegistrationPage extends StatefulWidget {
  final int? caregiverId;

  const PatientRegistrationPage({super.key, this.caregiverId});

  @override
  State<PatientRegistrationPage> createState() =>
      _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final _formKeys = [
    GlobalKey<FormState>(), // Step 0: Personal Info
    GlobalKey<FormState>(), // Step 1: Address Info
    GlobalKey<FormState>(), // Step 2: Emergency Contact
  ];

  int _currentStep = 0;
  bool _isLoading = false;

  // Step 0: Personal Information
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  // final _passwordController = TextEditingController(); // Commented out - handled on backend
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  // Step 1: Address Information
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _addressPhoneController = TextEditingController();

  // Step 2: Emergency Contact & Relationship
  final _relationshipController = TextEditingController();

  @override
  void dispose() {
    // Personal info controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    // _passwordController.dispose(); // Commented out - handled on backend
    _phoneController.dispose();
    _dobController.dispose();

    // Address controllers
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _addressPhoneController.dispose();

    // Relationship controller
    _relationshipController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Register New Patient',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF14366E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/caregiver'),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF14366E),
            primary: const Color(0xFF14366E),
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            if (step < _currentStep) {
              setState(() => _currentStep = step);
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex < 2)
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _nextStep(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14366E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _registerPatient(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Register Patient'),
                  ),
                const SizedBox(width: 8),
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: _isLoading ? null : () => _previousStep(),
                    child: const Text('Back'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Personal Information'),
              content: _buildPersonalInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Address Information'),
              content: _buildAddressStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : _currentStep == 1
                  ? StepState.indexed
                  : StepState.disabled,
            ),
            Step(
              title: const Text('Relationship'),
              content: _buildRelationshipStep(),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.indexed : StepState.disabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKeys[0],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    labelStyle: const TextStyle(color: Color(0xFF14366E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF14366E)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    labelStyle: const TextStyle(color: Color(0xFF14366E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF14366E)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address *',
              labelStyle: const TextStyle(color: Color(0xFF14366E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF14366E)),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password field commented out - handled on backend
          // TextFormField(
          //   controller: _passwordController,
          //   decoration: InputDecoration(
          //     labelText: 'Password *',
          //     labelStyle: const TextStyle(color: Color(0xFF14366E)),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     focusedBorder: const OutlineInputBorder(
          //       borderSide: BorderSide(color: Color(0xFF14366E)),
          //     ),
          //     prefixIcon: const Icon(Icons.lock),
          //   ),
          //   obscureText: true,
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter password';
          //     }
          //     if (value.length < 6) {
          //       return 'Password must be at least 6 characters';
          //     }
          //     return null;
          //   },
          // ),
          // const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              labelStyle: const TextStyle(color: Color(0xFF14366E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF14366E)),
              ),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth *',
              labelStyle: const TextStyle(color: Color(0xFF14366E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF14366E)),
              ),
              prefixIcon: const Icon(Icons.calendar_today),
              hintText: 'MM/DD/YYYY',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter date of birth';
              }
              return null;
            },
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                // Format as MM/DD/YYYY to match API expectation
                _dobController.text =
                    '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
              }
            },
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Form(
      key: _formKeys[1],
      child: Column(
        children: [
          TextFormField(
            controller: _addressLine1Controller,
            decoration: InputDecoration(
              labelText: 'Address Line 1 *',
              labelStyle: const TextStyle(color: Color(0xFF14366E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF14366E)),
              ),
              hintText: 'Street address, P.O. box',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter address line 1';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressLine2Controller,
            decoration: InputDecoration(
              labelText: 'Address Line 2 (Optional)',
              labelStyle: const TextStyle(color: Color(0xFF14366E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF14366E)),
              ),
              hintText: 'Apartment, suite, unit, building, floor, etc.',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City *',
                    labelStyle: const TextStyle(color: Color(0xFF14366E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF14366E)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'State *',
                    labelStyle: const TextStyle(color: Color(0xFF14366E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF14366E)),
                    ),
                    hintText: 'VA',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _zipController,
                  decoration: InputDecoration(
                    labelText: 'ZIP Code *',
                    labelStyle: const TextStyle(color: Color(0xFF14366E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF14366E)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ZIP code';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _addressPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Address Phone *',
                    labelStyle: const TextStyle(color: Color(0xFF14366E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF14366E)),
                    ),
                    hintText: 'Home/Work phone',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address phone';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipStep() {
    return Form(
      key: _formKeys[2],
      child: Column(
        children: [
          TextFormField(
            controller: _relationshipController,
            decoration: InputDecoration(
              labelText: 'Relationship to Patient *',
              labelStyle: const TextStyle(color: Color(0xFF14366E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF14366E)),
              ),
              hintText: 'e.g., Parent, Spouse, Child, Daughter, Son, etc.',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter relationship to patient';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Registration Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Patient: ${_firstNameController.text} ${_lastNameController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Email: ${_emailController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Phone: ${_phoneController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Date of Birth: ${_dobController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Address: ${_addressLine1Controller.text}, ${_cityController.text}, ${_stateController.text} ${_zipController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _registerPatient() async {
    if (!_formKeys[_currentStep].currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      final caregiverId = widget.caregiverId ?? user?.caregiverId;

      if (caregiverId == null) {
        throw Exception('Caregiver ID is required for patient registration');
      }

      // Create Address object using the model
      final address = Address(
        line1: _addressLine1Controller.text.trim(),
        line2: _addressLine2Controller.text.trim().isNotEmpty
            ? _addressLine2Controller.text.trim()
            : null,
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zip: _zipController.text.trim(),
        phone: _addressPhoneController.text.trim(),
      );

      // Structure the request body - password field removed (handled on backend)
      final requestBody = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'dob': _dobController.text.trim(), // Already in MM/DD/YYYY format
        'email': _emailController.text.trim(),
        // 'password': _passwordController.text.trim(), // Removed - handled on backend
        'phone': _phoneController.text.trim(),
        'address': address.toJson(), // Use the Address model's toJson method
        'caregiverId': caregiverId,
        'relationship': _relationshipController.text.trim(),
      };

      print('🔍 Patient registration request body: ${jsonEncode(requestBody)}');

      // Use caregiver-specific API endpoint
      final response = await ApiService.registerPatientForCaregiver(
        caregiverId: caregiverId,
        patientData: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient registered successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/dashboard/caregiver');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? errorData['error'] ?? 'Registration failed',
        );
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
      setState(() => _isLoading = false);
    }
  }
}
