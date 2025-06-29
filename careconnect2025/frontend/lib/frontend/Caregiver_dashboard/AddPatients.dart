/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for patient details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controller for credentials (password)
  final _passwordController = TextEditingController();

  // Controllers for address details
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _addressPhoneController = TextEditingController();

  bool _isLoading = false;

  // Show a date picker and assign formatted value to DOB field
  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  // Submit the form, construct request body, and perform the POST request
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Updated  the endpoint (note: caregiverId = 1 is in the URL)
        final uri = Uri.parse(
          "https://powerful-chamber-10556-971785a2bae0.herokuapp.com/v1/api/caregivers/1/patients",
        );

        // Provided Bearer token
        final token =
            "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJqYW5lLm1hbGFsYUBleGFtcGxlLmNvbSIsInJvbGUiOiJDQVJFR0lWRVIiLCJpYXQiOjE3NTA4MDE5NDQsImV4cCI6MTc1MDgwNTU0NH0.g7x2SeJS1M4G_gPNQAuMo_rewlqtnnCrgwR6PIydgEo";

        // Construct request body as expected by backend
        final data = {
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "dob": _dobController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "address": {
            "line1": _addressLine1Controller.text.trim(),
            "line2": _addressLine2Controller.text.trim(),
            "city": _cityController.text.trim(),
            "state": _stateController.text.trim(),
            "zip": _zipController.text.trim(),
            "phone": _addressPhoneController.text.trim(),
          },
          "credentials": {
            "email": _emailController.text.trim(),
            "password": _passwordController.text.trim(),
          }
        };

        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient added successfully')),
          );
          _formKey.currentState!.reset();
          _clearControllers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed. Code: ${response.statusCode}')),
          );
          print('Error body: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Clear all controllers after submission/resetting the form
  void _clearControllers() {
    _firstNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _addressPhoneController.clear();
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _addressPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_lastNameController, 'Last Name'),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDOB(context),
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                validator: (val) => val!.isEmpty ? 'Select DOB' : null,
              ),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_phoneController, 'Phone Number'),
              const SizedBox(height: 20),
              const Text('Address Info', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField(_addressLine1Controller, 'Address Line 1'),
              _buildTextField(_addressLine2Controller, 'Address Line 2', required: false),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_stateController, 'State'),
              _buildTextField(_zipController, 'Zip'),
              _buildTextField(_addressPhoneController, 'Address Phone'),
              const SizedBox(height: 20),
              const Text('Credentials', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val == null || val.isEmpty ? 'Enter Password' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add Patient', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a text field with validation
  Widget _buildTextField(TextEditingController controller, String labelText, {bool required = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      validator: (val) =>
      required && (val == null || val.isEmpty) ? 'Enter $labelText' : null,
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  final String token = dotenv.env['backend_AddPatient_token']!;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(dotenv.env['backend_AddPatient_url']!);

    final Map<String, dynamic> data = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "dob": _dobController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "phone": _phoneController.text.trim(),
      "caregiverId": 1,
      "relationship": _relationshipController.text.trim(),
      "address": {
        "line1": "112 SE Ave", // Hardcoded for now, update as needed
        "line2": "Apt 103",
        "city": "McLean",
        "state": "VA",
        "zip": "19053",
        "phone": _phoneController.text.trim()
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Patient added successfully')),
        );
        _formKey.currentState!.reset();
        _clearControllers();
      } else {
        debugPrint('Server error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed (code ${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _clearControllers() {
    _firstNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _emailController.clear();
    _phoneController.clear();
    _relationshipController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  Widget _buildField(TextEditingController controller, String labelText,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: labelText),
        validator: (val) =>
        val == null || val.trim().isEmpty ? 'Enter $labelText' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Add Patient'), backgroundColor: Colors.indigo, foregroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(_firstNameController, 'First Name'),
              _buildField(_lastNameController, 'Last Name'),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _pickDate,
                decoration:
                const InputDecoration(labelText: 'Date of Birth'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Select DOB' : null,
              ),
              _buildField(_emailController, 'Email'),
              _buildField(_phoneController, 'Phone'),
              _buildField(_relationshipController, 'Relationship'),
              _buildField(_passwordController, 'Password',
                  obscureText: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Submit',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
