import 'package:flutter/material.dart';

class InviteFamilyMemberScreen extends StatefulWidget {
  const InviteFamilyMemberScreen({super.key});

  @override
  State<InviteFamilyMemberScreen> createState() =>
      _InviteFamilyMemberScreenState();
}

class _InviteFamilyMemberScreenState extends State<InviteFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedRelationship;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Normally you'd send this to a backend or email
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation sent to family member!')),
      );

      // Clear fields
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      setState(() => _selectedRelationship = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Family Member'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              const Text('Name'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Relationship
              const Text('Relationship'),
              DropdownButtonFormField<String>(
                value: _selectedRelationship,
                items: ['Parent', 'Sibling', 'Spouse', 'Child', 'Other']
                    .map((relation) => DropdownMenuItem(
                  value: relation,
                  child: Text(relation),
                ))
                    .toList(),
                decoration: const InputDecoration(
                  hintText: 'Select relationship',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedRelationship = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a relationship' : null,
              ),
              const SizedBox(height: 16),

              // Email
              const Text('Email'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              const Text('Phone'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Send Invitation',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
