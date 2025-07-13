import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CaregiverRegistrationPage extends StatefulWidget {
  const CaregiverRegistrationPage({super.key});

  @override
  State<CaregiverRegistrationPage> createState() =>
      _CaregiverRegistrationPageState();
}

class _CaregiverRegistrationPageState extends State<CaregiverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  // String _caregiverType = 'Family Member';
  bool _isProfessional = false;
  bool _isFamily = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Handle registration logic
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration submitted!')));
      context.go('/dashboard/caregiver');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caregiver Registration',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF14366E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF14366E)),
              child: const Text(
                'Caregiver Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/dashboard/caregiver');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Patient Logs'),
              onTap: () {
                Navigator.pop(context);
                context.go('/patient-logs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Patient Status'),
              onTap: () {
                Navigator.pop(context);
                context.go('/patient-status');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat & Calls'),
              onTap: () {
                Navigator.pop(context);
                context.go('/chatandcalls');
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('AI Assistant'),
              onTap: () {
                Navigator.pop(context);
                context.go('/aiassistant');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Emergency Alerts'),
              onTap: () {
                Navigator.pop(context);
                context.go('/caregiver-sos-alert');
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Achievements'),
              onTap: () {
                Navigator.pop(context);
                context.go('/gamification');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Add logout logic if needed
                Navigator.pop(context);
                context.go('/');
              },
            ),
          ],
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
                    'Register a Caregiver',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14366E),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(color: Color(0xFF14366E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF14366E)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
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
                  const Text(
                    'Caregiver Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14366E),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Family Member'),
                    value: _isFamily,
                    activeColor: const Color(0xFF14366E),
                    onChanged: (val) {
                      setState(() {
                        _isFamily = val ?? false;
                        if (!_isFamily && !_isProfessional) {
                          _isProfessional = true;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Professional'),
                    value: _isProfessional,
                    activeColor: const Color(0xFF14366E),
                    onChanged: (val) {
                      setState(() {
                        _isProfessional = val ?? false;
                        if (!_isFamily && !_isProfessional) {
                          _isFamily = true;
                        }
                      });
                    },
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
                      onPressed: _submit,
                      child: const Text('Register'),
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
