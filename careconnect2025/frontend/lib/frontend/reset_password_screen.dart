import 'package:flutter/material.dart';
import 'package:care_connect_app/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String role;
  const ResetPasswordScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool isLoading = false;
  String? message;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      await AuthService.forgotPassword(
        _emailController.text.trim(),
        widget.role, // <-- Pass the role from the widget!
      );
      setState(() {
        message = 'If your account exists, you will receive a reset link via email.';
      });
    } catch (error) {
      setState(() {
        message = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to receive a password reset link.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Reset Link'),
              ),
            ),
            const SizedBox(height: 16),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.contains('receive')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
