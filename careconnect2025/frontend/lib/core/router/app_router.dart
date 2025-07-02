import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/caregiver_dashboard.dart';
import '../../features/dashboard/presentation/pages/patient_dashboard.dart';
import '../../features/onboarding/presentation/pages/caregiver_registration.dart';
import '../../features/onboarding/presentation/pages/patient_registration.dart';
import '../../features/calls/presentation/pages/chatandcalls.dart';
import '../../features/chatbot/presentation/pages/aiassitant.dart';
import '../../features/scheduling/presentation/pages/taskscheduling.dart';
import '../../features/deviceintegration/presentation/pages/fitbitintegration.dart';
import '../../features/immergencyalert/presentation/pages/sos.dart';
import '../../features/payments/presentation/pages/select_package_page.dart';
import '../../features/auth/presentation/pages/password_reset_page.dart';
import '../../features/payments/models/package_model.dart';
import '../../features/gamification/presentation/gamification_dashboard_page.dart';
import '../../features/immergencyalert/presentation/pages/caregiver_sos_altert.dart';
import '../../features/immergencyalert/presentation/pages/patient_location_widget.dart';
import '../../features/payments/presentation/pages/stripe_checkout_page.dart';
import 'package:careconnectpt_fe/features/analytics/analytics_page.dart';
import 'package:careconnectpt_fe/features/payments/presentation/pages/payment_success_page.dart';
import 'package:careconnectpt_fe/features/payments/presentation/pages/payment_cancel_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(
      path: '/dashboard/caregiver',
      builder: (_, __) => const CaregiverDashboard(),
    ),
    GoRoute(
      path: '/dashboard/patient',
      builder: (_, __) => const PatientDashboard(),
    ),
    GoRoute(
      path: '/register/caregiver',
      builder: (_, __) => const CaregiverRegistrationPage(),
    ),
    GoRoute(
      path: '/register/patient',
      builder: (_, __) => const PatientRegistrationPage(),
    ),
    GoRoute(
      path: '/chatandcalls',
      builder: (_, __) => const ChatAndCallsPage(),
    ),
    GoRoute(path: '/aiassistant', builder: (_, __) => const AIAssistantPage()),
    GoRoute(
      path: '/taskscheduling',
      builder: (_, __) => const TaskSchedulingPage(),
    ),
    GoRoute(path: '/fitbit', builder: (_, __) => const FitbitIntegrationPage()),
    GoRoute(path: '/sos', builder: (_, __) => const SOSPage()),
    GoRoute(
      path: '/select-package',
      builder: (_, __) => const SelectPackagePage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const PasswordResetPage(),
    ),
    GoRoute(
      path: '/gamification',
      builder: (_, __) => const GamificationDashboardPage(),
    ),
    GoRoute(
      path: '/caregiver-sos',
      builder: (_, __) => const CaregiverSOSAlertPage(),
    ),
    GoRoute(
      path: '/patientlocation',
      builder: (context, state) => const PatientLocationWidget(),
    ),
    GoRoute(
      path: '/select-package',
      builder: (context, state) => const SelectPackagePage(),
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
