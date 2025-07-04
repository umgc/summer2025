import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../../config/constants/api_constants.dart';
import '../../../../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email.text.trim(), 'password': _pwd.text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final int userId = data['id'];
        final String role = data['role'] ?? '';
        final String token = data['token'] ?? '';
        final int? patientId = data['patientId'];
        final int? caregiverId = data['caregiverId'];

        // Save user info to Provider
        Provider.of<UserProvider>(context, listen: false).setUser(
          UserSession(
            id: userId,
            role: role,
            token: token,
            patientId: patientId,
            caregiverId: caregiverId,
          ),
        );

        if (role == 'CAREGIVER') {
          context.go('/dashboard/caregiver');
        } else if (role == 'PATIENT') {
          context.go('/dashboard/patient');
        } else {
          setState(() {
            _error = 'Unknown user role: $role';
          });
        }
      } else {
        setState(() {
          _error = 'Login failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Care Connect',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Closer Connections. Better Care',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              const Text(
                'Log In',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pwd,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _busy ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                  child: _busy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Log in',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.go('/reset-password'),
                child: const Text('Forgot your password?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
