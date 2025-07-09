import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/oauth_callback_page.dart';
import '../../features/dashboard/presentation/pages/caregiver_dashboard.dart';
import '../../features/dashboard/presentation/pages/patient_dashboard.dart';
import '../../features/onboarding/presentation/pages/patient_registration.dart';
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/payments/presentation/pages/select_package_page.dart';
import '../../features/auth/presentation/pages/password_reset_page.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart'; // ADD THIS IMPORT
import '../../features/payments/models/package_model.dart';
import '../../features/social/presentation/pages/main_feed_screen.dart';
import '../../features/gamification/presentation/pages/caregiver_gamification_landingpage.dart';
import '../../features/gamification/presentation/pages/gamification_screen.dart';
import '../../features/payments/presentation/pages/stripe_checkout_page.dart';
import '../../features/analytics/analytics_page.dart';
import '../../features/payments/presentation/pages/payment_success_page.dart';
import '../../features/payments/presentation/pages/payment_cancel_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(
      path: '/dashboard/caregiver',
      builder: (_, __) => const CaregiverDashboard(),
    ),
    GoRoute(
      path: '/dashboard/patient',
      builder: (context, state) {
        final userIdStr = state.uri.queryParameters['userId'];
        final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
        return PatientDashboard(userId: userId);
      },
    ),
    GoRoute(
      path: '/register/caregiver',
      builder: (_, __) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/register/caregiver/payment',
      builder: (_, __) => const CaregiverRegistrationFlowPage(),
    ),
    GoRoute(
      path: '/register/patient',
      builder: (_, __) => const PatientRegistrationPage(),
    ),
    GoRoute(
      path: '/social-feed',
      builder: (context, state) {
        final userIdStr = state.uri.queryParameters['userId'];
        final userId = userIdStr != null ? int.tryParse(userIdStr) : 1;
        return MainFeedScreen(userId: userId ?? 1);
      },
    ),
    GoRoute(
      path: '/select-package',
      builder: (_, __) => const SelectPackagePage(),
    ),
    // FIX: Use ResetPasswordScreen for requesting reset link
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const ResetPasswordScreen(),
    ),
    // FIX: Use PasswordResetPage for setting new password with token
    GoRoute(
      path: '/reset',
      builder: (context, state) {
        final token = state
            .uri
            .queryParameters['token']; // FIX: queryParameters not queryParams
        return PasswordResetPage(token: token);
      },
    ),
    // FIX: Remove duplicate, keep only one gamification route
    GoRoute(
      path: '/gamification',
      builder: (_, __) => const GamificationScreen(),
    ),
    GoRoute(
      path: '/caregiver-gamification',
      builder: (_, __) => CaregiverGamificationLandingScreen(),
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
        final isRegistration =
            state.uri.queryParameters['registration'] == 'complete';
        return PaymentSuccessPage(
          sessionId: sessionId,
          isRegistration: isRegistration,
        );
      },
    ),
    GoRoute(
      path: '/payment-cancel',
      builder: (context, state) {
        final isRegistration =
            state.uri.queryParameters['registration'] == 'complete';
        return PaymentCancelPage(isRegistration: isRegistration);
      },
    ),
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
    GoRoute(
      path: '/oauth/callback',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        final user = state.uri.queryParameters['user'];
        final error = state.uri.queryParameters['error'];
        return OAuthCallbackPage(token: token, user: user, error: error);
      },
    ),
  ],
);
