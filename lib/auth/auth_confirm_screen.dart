import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';
import '/shared/widgets/buttons/primary_button.dart';

class AuthConfirmScreen extends StatefulWidget {
  final String email;

  const AuthConfirmScreen({super.key, required this.email});

  @override
  State<AuthConfirmScreen> createState() => _AuthConfirmScreenState();
}

class _AuthConfirmScreenState extends State<AuthConfirmScreen> {
  final _codeController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _confirmCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the confirmation code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.confirmUser(widget.email, code);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your account has been verified! Please log in.")),
        );
        context.push('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Confirmation failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
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
                    child: GestureDetector(
                      onTap: () => context.push('/'),
                      child: Image.asset(
                        'assets/images/DeepTrain_Logo_small.webp',
                        height: 50,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'A verification code has been sent to ${widget.email}.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: 'Enter confirmation code',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Confirm Account',
                      isLoading: _isLoading,
                      onPressed: _confirmCode,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.push('/login'),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
