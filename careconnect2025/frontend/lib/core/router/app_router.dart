import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Main screens and authentication
import '../../main.dart'; // For WelcomeScreen
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/password_reset_page.dart';

// Dashboard screens
import '../../features/dashboard/presentation/pages/caregiver_dashboard.dart';
import '../../features/dashboard/presentation/pages/patient_dashboard.dart';

// Payments
import '../../features/payments/presentation/pages/select_package_page.dart';
import '../../features/payments/models/package_model.dart';
import '../../features/payments/presentation/pages/stripe_checkout_page.dart';
import '../../features/payments/presentation/pages/payment_success_page.dart';
import '../../features/payments/presentation/pages/payment_cancel_page.dart';

// Analytics
import '../../features/analytics/analytics_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Welcome/Home screen
    GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),

    // Authentication routes
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const PasswordResetPage(),
    ),

    // Dashboard routes
    GoRoute(
      path: '/dashboard/caregiver',
      builder: (_, __) => const CaregiverDashboard(),
    ),
    GoRoute(
      path: '/dashboard/patient',
      builder: (_, __) => const PatientDashboard(),
    ),

    // Registration routes - TODO: Move to features/auth structure
    GoRoute(
      path: '/register/caregiver',
      builder: (_, __) => const Scaffold(
        appBar: AppBar(title: Text('Caregiver Registration')),
        body: Center(child: Text('Caregiver registration page coming soon')),
      ),
    ),
    GoRoute(
      path: '/register/patient',
      builder: (_, __) => const Scaffold(
        appBar: AppBar(title: Text('Patient Registration')),
        body: Center(child: Text('Patient registration page coming soon')),
      ),
    ),

    // Feature routes - TODO: Move to features structure
    // GoRoute(
    //   path: '/video-call',
    //   builder: (context, state) {
    //     final roomName = state.uri.queryParameters['room'] ?? 'default-room';
    //     return JitsiMeetingScreen(roomName: roomName);
    //   },
    // ),
    // GoRoute(path: '/voice-ai', builder: (_, __) => const VoiceCommandAI()),
    // GoRoute(
    //   path: '/meal-tracking',
    //   builder: (_, __) => const MealTrackingScreen(),
    // ),
    // GoRoute(
    //   path: '/gamification',
    //   builder: (_, __) => const GamificationScreen(),
    // ),
    // GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

    // Payment routes
    GoRoute(
      path: '/select-package',
      builder: (_, __) => const SelectPackagePage(),
    ),
    GoRoute(
      path: '/stripe-checkout',
      builder: (context, state) {
        final pkg = state.extra as PackageModel;
        return StripeCheckoutPage(package: pkg);
      },
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) {
        final sessionId = state.uri.queryParameters['session_id'];
        return PaymentSuccessPage(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/payment-cancel',
      builder: (context, state) => const PaymentCancelPage(),
    ),

    // Analytics route
    GoRoute(
      path: '/analytics',
      builder: (context, state) {
        final patientIdStr = state.uri.queryParameters['patientId'];
        if (patientIdStr == null) {
          return const Scaffold(
            body: Center(child: Text('No patientId provided in the URL.')),
          );
        }
        final patientId = int.tryParse(patientIdStr);
        if (patientId == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid patientId.')),
          );
        }
        return AnalyticsPage(patientId: patientId);
      },
    ),
  ],
);
