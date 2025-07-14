
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authToken = dotenv.env['backend_token'];
    final urlString = dotenv.env['backend_AddPatient_Url'];

    if (authToken == null || authToken.isEmpty) {
      _showError("Missing 'backend_token' in .env");
      return;
    }

    if (urlString == null || urlString.isEmpty) {
      _showError("Missing 'backend_AddPatient_url' in .env");
      return;
    }

    final url = Uri.parse(urlString);

    final data = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "dob": _dobController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "phone": _phoneController.text.trim(),
      "caregiverId": 1,
      "relationship": _relationshipController.text.trim(),
      "address": {
        "line1": "112 SE Ave",
        "line2": "Apt 103",
        "city": "McLean",
        "state": "VA",
        "zip": "19053",
        "phone": _phoneController.text.trim(),
      }
    };

    try {
      setState(() => _isLoading = true);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": authToken,
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
        debugPrint("Response: ${response.body}");
        _showError("❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Exception: $e");
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label),
        validator: (val) =>
        val == null || val.trim().isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
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
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Select DOB' : null,
              ),
              _buildField(_emailController, 'Email'),
              _buildField(_phoneController, 'Phone'),
              _buildField(_relationshipController, 'Relationship'),
              _buildField(_passwordController, 'Password', obscure: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
