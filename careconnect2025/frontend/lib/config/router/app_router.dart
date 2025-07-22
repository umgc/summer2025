//import 'package:care_connect_app/features/dashboard/presentation/pages/archive_patient.dart';
//import 'package:care_connect_app/features/dashboard/presentation/pages/invite_family_member.dart';
//import 'package:care_connect_app/features/dashboard/presentation/pages/media_upload.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/home_monitoring_screen.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/medication_management.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/smart_devices.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/wearables_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/analytics/analytics_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/oauth_callback_page.dart';
import '../../features/auth/presentation/pages/password_reset_page.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart'; // ADD THIS IMPORT
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/calls/presentation/pages/mobile_web_call.dart';
import '../../features/dashboard/presentation/pages/caregiver_dashboard.dart';
//import '../../features/dashboard/presentation/pages/edit_patient.dart';
import '../../features/dashboard/presentation/pages/patient_dashboard.dart';
import '../../features/gamification/presentation/pages/caregiver_gamification_landingpage.dart';
import '../../features/gamification/presentation/pages/gamification_screen.dart';
import '../../features/onboarding/presentation/pages/patient_registration.dart';
import '../../features/payments/models/package_model.dart';
import '../../features/payments/presentation/pages/payment_cancel_page.dart';
import '../../features/payments/presentation/pages/payment_success_page.dart';
import '../../features/payments/presentation/pages/select_package_page.dart';
import '../../features/payments/presentation/pages/stripe_checkout_page.dart';
import '../../features/payments/presentation/pages/subscription_management_page.dart';
import '../../features/social/presentation/pages/main_feed_screen.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../../providers/user_provider.dart';

/// Helper function to navigate to the appropriate dashboard based on user role
void navigateToDashboard(BuildContext context, {String? role}) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userRole = role ?? userProvider.user?.role;

  if (userRole == null) {
    // If no role is found, redirect to login with the last known userType if available
    final lastUserType =
        userProvider.user != null && userProvider.user!.role != null
        ? userProvider.user!.role.toLowerCase()
        : 'patient';
    context.go('/login', extra: {'userType': lastUserType});
    return;
  }

  context.go('/dashboard?role=$userRole');
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final urlRole = state.uri.queryParameters['role'];

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final sessionRole = userProvider.user?.role;

        final userRole = urlRole ?? sessionRole;

        if (userRole == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        switch (userRole.toUpperCase()) {
          case 'PATIENT':
            return const PatientDashboard();
          case 'CAREGIVER':
          case 'FAMILY_LINK':
          case 'ADMIN':
            return const CaregiverDashboard();
          default:
            // Unknown role, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login');
            });
            return const Scaffold(
              body: Center(
                child: Text('Unknown user role. Redirecting to login...'),
              ),
            );
        }
      },
    ),
    GoRoute(
      path: '/dashboard/patient',
      builder: (context, state) {
        final userIdStr = state.uri.queryParameters['userId'];
        final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
        return PatientDashboard(userId: userId); // Pass userId if provided
      },
    ),

    // Caregiver dashboard route (backend redirects)
    GoRoute(
      path: '/dashboard/caregiver',
      builder: (context, state) {
        final caregiverIdStr = state.uri.queryParameters['caregiverId'];
        final patientIdStr = state.uri.queryParameters['patientId'];
        final userRole = state.uri.queryParameters['userRole'] ?? 'CAREGIVER';

        final caregiverId = caregiverIdStr != null
            ? int.tryParse(caregiverIdStr)
            : 1;
        final patientId = patientIdStr != null
            ? int.tryParse(patientIdStr)
            : null;

        return CaregiverDashboard(
          userRole: userRole,
          patientId: patientId,
          caregiverId: caregiverId ?? 1,
        );
      },
    ),
    // Add a redirect route for authenticated users going to root
    GoRoute(
      path: '/home',
      redirect: (context, state) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userRole = userProvider.user?.role;

        if (userRole != null) {
          return '/dashboard?role=$userRole';
        }
        return '/';
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
        return MainFeedScreen();
      },
    ),
    GoRoute(
      path: '/select-package',
      builder: (_, __) => const SelectPackagePage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/setup-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        // Add redirect if no token
        if (token == null || token.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Invalid or missing reset token'),
                  SizedBox(height: 16),
                  BackButton(color: Colors.blue),
                ],
              ),
            ),
          );
        }
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
    GoRoute(path: '/wearables', builder: (_, __) => const WearablesScreen()),
    GoRoute(
      path: '/home-monitoring',
      builder: (_, __) => const HomeMonitoringScreen(),
    ),
    GoRoute(
      path: '/smart-devices',
      builder: (_, __) => const SmartDevicesScreen(),
    ),
    GoRoute(
      path: '/medication',
      builder: (_, __) => const MedicationManagementScreen(),
    ),

    /*GoRoute(
      path: '/edit',
      builder: (context, state) {
        final patientId = state.uri.queryParameters['patientId'] ?? '';
        return EditScreen(linkId: patientId);
      },
    ),*/
    /*GoRoute(
      path: '/archive',
      builder: (_, __) => const ArchiveScreen(linkId: ''),
    ),*/

    /*GoRoute(
      path: '/invite_Family_Member',
      builder: (_, __) => const InviteFamilyMemberScreen(),
    ),*/

    //GoRoute(path: '/MediaScreen', builder: (_, __) => const MediaScreen()),
    GoRoute(
      path: '/mobile-web-call',
      builder: (context, state) {
        // Retrieve the query parameters
        final patientName =
            state.uri.queryParameters['patientName'] ?? 'Unknown';
        final roomId = state.uri.queryParameters['roomId'] ?? 'Unknown';

        // Return the CallScreen widget and pass the parameters
        return CallScreen(
          patientName: patientName,
          roomId: roomId,
          isCaller: true, // Adjust this flag as needed
        );
      },
    ),

    GoRoute(
      path: '/subscription-management',
      builder: (context, state) => const SubscriptionManagementPage(),
    ),
  ],
);
