import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_strings.dart'; // For logout button text
import '../constants/app_routes.dart'; // For navigation routes

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch AuthService to react to user changes (e.g., logout)
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.studentDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              // After logout, AuthWrapper in main.dart will redirect to login.
              // We can also ensure by explicitly pushing to login if desired.
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${AppStrings.homeWelcomeMessage} ${user?.username ?? user?.email ?? AppStrings.defaultUserDisplayName}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'You are logged in as a ${user?.role.name.toUpperCase()}!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text('Student specific content goes here.'),
          ],
        ),
      ),
    );
  }
}
