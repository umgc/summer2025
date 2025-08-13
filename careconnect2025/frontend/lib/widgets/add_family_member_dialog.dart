import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';

class AddFamilyMemberDialog extends StatefulWidget {
  const AddFamilyMemberDialog({super.key});

  @override
  _AddFamilyMemberDialogState createState() => _AddFamilyMemberDialogState();
}

class _AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Family Member', style: textTheme.titleLarge),
              const SizedBox(height: 20),

              // First Name field
              TextFormField(
                controller: _firstNameController,
                decoration: AppTheme.inputDecoration('First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Last Name field
              TextFormField(
                controller: _lastNameController,
                decoration: AppTheme.inputDecoration('Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Relationship field
              TextFormField(
                controller: _relationshipController,
                decoration: AppTheme.inputDecoration(
                  'Relationship',
                  hint: 'e.g., Son, Daughter, Spouse',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter relationship';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: AppTheme.inputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: AppTheme.inputDecoration('Email Address').copyWith(
                  prefixIcon: Icon(
                    Icons.email,
                    color: theme.colorScheme.primary,
                  ),
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
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: theme.textButtonTheme.style,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop({
                          'firstName': _firstNameController.text.trim(),
                          'lastName': _lastNameController.text.trim(),
                          'relationship': _relationshipController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'email': _emailController.text.trim(),
                        });
                      }
                    },
                    style: AppTheme.primaryButtonStyle,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
