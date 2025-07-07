import 'package:flutter/material.dart';
import 'package:care_connect_app/services/auth_service.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String token;
  const SetNewPasswordScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool isLoading = false;
  String? message;

  @override
  Widget build(BuildContext context) {
    // Get token from URL
    final token = Uri.base.queryParameters['token'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Set your new password', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  if (_passwordController.text != _confirmController.text) {
                    setState(() {
                      message = "Passwords do not match!";
                    });
                    return;
                  }
                  setState(() {
                    isLoading = true;
                    message = null;
                  });
                  try {
                    await AuthService.resetPassword(token, _passwordController.text.trim());
                    setState(() {
                      message = "Password reset successfully! You can now log in.";
                    });
                  } catch (e) {
                    setState(() {
                      message = e.toString().replaceFirst('Exception: ', '');
                    });
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Set Password'),
              ),
            ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  message!,
                  style: TextStyle(
                    color: message!.contains('success') ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
