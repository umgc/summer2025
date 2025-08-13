import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.textLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.health_and_safety,
                size: 60,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryDarkTheme
                    : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'CareConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connecting Care, Empowering Lives',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.videoCallTextSecondary,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textLight),
            ),
            const SizedBox(height: 16),
            const Text(
              'Initializing services...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.videoCallTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
