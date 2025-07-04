import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'dart:convert';

class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({super.key});

  @override
  State<PatientRegistrationPage> createState() =>
      _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _relationship = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    _address.dispose();
    _relationship.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = Provider.of<UserProvider>(context, listen: false).user;
        if (user == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Please log in first')));
          return;
        }

        final response = await ApiService.registerPatient(
          _firstName.text.trim(),
          _lastName.text.trim(),
          _email.text.trim(),
          _phone.text.trim(),
          _dob.text.trim(),
          _address.text.trim(),
          _relationship.text.trim(),
          user.caregiverId ?? 0,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient registered successfully!')),
          );
          context.go('/dashboard/caregiver');
        } else {
          final error =
              jsonDecode(response.body)['message'] ?? 'Registration failed';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register New Patient',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF14366E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/caregiver'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register New Patient',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14366E),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstName,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: const TextStyle(
                              color: Color(0xFF14366E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF14366E)),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter first name'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastName,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: const TextStyle(
                              color: Color(0xFF14366E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF14366E)),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter last name'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF14366E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF14366E)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(color: Color(0xFF14366E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF14366E)),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your phone number'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dob,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      labelStyle: const TextStyle(color: Color(0xFF14366E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF14366E)),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 365 * 30),
                            ),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _dob.text =
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                    ),
                    readOnly: true,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select date of birth'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _address,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: const TextStyle(color: Color(0xFF14366E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF14366E)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your address'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _relationship,
                    decoration: InputDecoration(
                      labelText: 'Relationship to Patient',
                      labelStyle: const TextStyle(color: Color(0xFF14366E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF14366E)),
                      ),
                      hintText: 'e.g., Parent, Spouse, Child, etc.',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your relationship to the patient'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF14366E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Register Patient'),
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
