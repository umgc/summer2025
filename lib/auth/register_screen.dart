import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';
import '/shared/widgets/buttons/primary_button.dart';
import '/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _authService = AuthService();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Trainee';
  final List<String> _roles = ['Admin', 'Designer', 'Trainee'];


  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    try {
     final success = await _authService.signUpUser(
  email: email,
  password: password,
  firstName: firstName,
  lastName: lastName,
  role: _selectedRole, // pass role
);

      
      if (success && mounted) {
        context.push('/confirm', extra: email);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must include at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must include at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must include at least one number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  },
                  child: Image.asset(
                    'assets/images/DeepTrain_Logo_small.webp',
                    height: 40,
                  ),
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/robot.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                        },
                        child: Image.asset(
                          'assets/images/DeepTrain_Logo_small.webp',
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create your DeepTrain account',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'First name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Last name is required' : null,
                      ),
                      const SizedBox(height: 16),
DropdownButtonFormField<String>(
  value: _selectedRole,
  decoration: InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    labelText: 'Select Role',
  ),
  items: _roles.map((role) {
    return DropdownMenuItem<String>(
      value: role,
      child: Text(role),
    );
  }).toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() {
        _selectedRole = value;
      });
    }
  },
),



                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Password must be at least 8 characters, include uppercase, lowercase, and a number.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Sign Up',
                        isLoading: _isLoading,
                        onPressed: _registerUser,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap: () {
                                  if (mounted) GoRouter.of(context).push('/login');
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              if (mounted) GoRouter.of(context).push('/reset-password');
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "By signing up, you agree to DeepTrain's Terms of Service and Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
