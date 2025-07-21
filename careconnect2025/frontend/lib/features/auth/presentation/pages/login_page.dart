import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../providers/user_provider.dart';
import '../../../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  bool _busy = false;
  bool _googleSignInBusy = false;
  String? _error;

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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
      final user = await AuthService.login(
        _email.text.trim(),
        _pwd.text,
        role: 'patient', // Default to patient, could be made dynamic
      );

      print('✅ Parsed user: id=${user.id}, name=${user.name}, role=${user.role}');

      // Save user info to Provider
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      // Save user info Persistently
      await secureStorage.write(key: 'userId', value: user.id.toString());
      await secureStorage.write(key: 'name', value: user.name);
      await secureStorage.write(key: 'email', value: user.email);
      await secureStorage.write(key: 'role', value: user.role);

      // Add a small delay to ensure JWT token is fully saved before navigation
      await Future.delayed(const Duration(milliseconds: 100));

      switch (user.role.toUpperCase()) {
        case 'CAREGIVER':
          context.go('/dashboard?role=CAREGIVER');
          break;
        case 'PATIENT':
          context.go('/dashboard/patient');
          break;
        case 'FAMILY_MEMBER':
          context.go('/dashboard?role=FAMILY_MEMBER');
          break;
        default:
          setState(() {
            _error = 'Unknown user role: ${user.role}';
          });
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed: $e';
      });
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _googleSignInBusy = true;
      _error = null;
    });

    try {
      final user = await AuthService.loginWithGoogle();

      // Save user info to Provider
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      // Save user info Persistently
      await secureStorage.write(key: 'userId', value: user.id.toString());
      await secureStorage.write(key: 'name', value: user.name);
      await secureStorage.write(key: 'email', value: user.email);
      await secureStorage.write(key: 'role', value: user.role);

      // Add a small delay to ensure JWT token is fully saved before navigation
      await Future.delayed(const Duration(milliseconds: 100));

      switch (user.role.toUpperCase()) {
        case 'CAREGIVER':
          context.go('/dashboard/caregiver');
          break;
        case 'PATIENT':
          context.go('/dashboard/patient');
          break;
        default:
          setState(() {
            _error = 'Unknown user role: ${user.role}';
          });
      }
    } catch (e) {
      setState(() {
        _error = 'Google Sign-In failed: $e';
      });
    } finally {
      setState(() => _googleSignInBusy = false);
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _googleSignInBusy ? null : _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    elevation: 1,
                    shadowColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _googleSignInBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google "G" logo representation
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
