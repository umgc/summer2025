import 'package:care_connect_app/features/integrations/presentation/pages/home_monitoring_screen.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/medication_management.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/smart_devices.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/wearables_screen.dart';
import 'package:care_connect_app/features/calls/presentation/pages/jitsi_meeting_screen.dart';
import 'package:care_connect_app/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:care_connect_app/pages/profile_page.dart';
import 'package:care_connect_app/pages/settings_page.dart';
import 'package:care_connect_app/pages/ai_configuration_page.dart';
import 'package:care_connect_app/pages/file_management_page.dart';
import 'package:care_connect_app/widgets/hybrid_video_call_widget.dart';
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
import '../../features/payments/presentation/pages/subscription_management_page.dart';
import '../../features/dashboard/presentation/pages/add_patient_screen.dart';
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
import '../../features/dashboard/presentation/pages/patient_status_page.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';

/// Helper function to navigate to the appropriate dashboard based on user role
void navigateToDashboard(BuildContext context, {String? role}) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userRole = role ?? userProvider.user?.role;

  if (userRole == null) {
    // If no role is found, redirect to login with the last known userType if available
    final lastUserType = userProvider.user != null
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
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final extra = state.extra;
        String? userType;

        if (extra != null &&
            extra is Map<String, dynamic> &&
            extra.containsKey('userType')) {
          userType = extra['userType'];
        }

        return LoginPage(userType: userType);
      },
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) {
        // We're now using a single caregiver sign up screen
        return const SignUpScreen(userType: 'caregiver');
      },
    ),
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
      builder: (_, __) => const SignUpScreen(userType: 'caregiver'),
    ),
    GoRoute(
      path: '/register/caregiver/payment',
      builder: (_, __) => const CaregiverRegistrationFlowPage(),
    ),
    GoRoute(
      path: '/register/patient',
      builder: (_, __) => const PatientRegistrationPage(),
    ),
    GoRoute(path: '/add-patient', builder: (_, __) => const AddPatientScreen()),
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
      builder: (context, state) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user;
        final userId = state.uri.queryParameters['userId'];
        final stripeCustomerId = state.uri.queryParameters['stripeCustomerId'];

        // If we have userId and stripeCustomerId, this is part of the registration flow
        // Or if user is a patient, show the original select package page
        // Otherwise show the subscription management page for existing caregivers
        if ((userId != null && stripeCustomerId != null) ||
            (user != null && user.role.toUpperCase() == 'PATIENT')) {
          return SelectPackagePage(
            userId: userId,
            stripeCustomerId: stripeCustomerId,
          );
        } else {
          return const SubscriptionManagementPage();
        }
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (_, __) => const SubscriptionManagementPage(),
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
        // Get userId and stripeCustomerId from query parameters if available
        final userId = state.uri.queryParameters['userId'];
        final stripeCustomerId = state.uri.queryParameters['stripeCustomerId'];
        return StripeCheckoutPage(
          package: pkg,
          userId: userId,
          stripeCustomerId: stripeCustomerId,
        );
      },
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) {
        final sessionId = state.uri.queryParameters['session_id'];
        final isRegistration =
            state.uri.queryParameters['registration'] == 'complete';
        final fromPortal = state.uri.queryParameters['portal'] == 'update';
        return PaymentSuccessPage(
          sessionId: sessionId,
          isRegistration: isRegistration,
          fromPortal: fromPortal,
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
      path: '/patient/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final patientId = int.tryParse(idStr ?? '');

        if (patientId == null) {
          // Instead of showing an error screen, redirect back to dashboard
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final userRole = userProvider.user?.role;

          // Show error message but stay logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Invalid patient ID')));

            // Redirect to appropriate dashboard based on role
            if (userRole != null) {
              Future.delayed(const Duration(milliseconds: 500), () {
                context.go('/dashboard?role=$userRole');
              });
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Redirecting...'),
              backgroundColor: const Color(0xFF14366E),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return PatientStatusPage(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) {
        final patientIdStr = state.uri.queryParameters['patientId'];
        if (patientIdStr == null || int.tryParse(patientIdStr) == null) {
          // Instead of showing an error screen, redirect back to dashboard
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final userRole = userProvider.user?.role;

          // Show error message but stay logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid or missing patient ID')),
            );

            // Redirect to appropriate dashboard based on role
            if (userRole != null) {
              Future.delayed(const Duration(milliseconds: 500), () {
                context.go('/dashboard?role=$userRole');
              });
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Redirecting...'),
              backgroundColor: const Color(0xFF14366E),
            ),
            body: const Center(child: CircularProgressIndicator()),
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
    GoRoute(
      path: '/video-call',
      builder: (context, state) {
        final patientIdStr = state.uri.queryParameters['patientId'];
        final patientName = state.uri.queryParameters['patientName'];

        if (patientIdStr == null || patientName == null) {
          // Instead of showing an error screen, redirect back to dashboard
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final userRole = userProvider.user?.role;

          // Show error message but stay logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Missing patient information for video call'),
              ),
            );

            // Redirect to appropriate dashboard based on role
            if (userRole != null) {
              Future.delayed(const Duration(milliseconds: 500), () {
                context.go('/dashboard?role=$userRole');
              });
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Redirecting...'),
              backgroundColor: const Color(0xFF14366E),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final patientId = int.tryParse(patientIdStr);
        if (patientId == null) {
          // Handle invalid patient ID
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final userRole = userProvider.user?.role;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid patient ID for video call'),
              ),
            );

            if (userRole != null) {
              Future.delayed(const Duration(milliseconds: 500), () {
                context.go('/dashboard?role=$userRole');
              });
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Redirecting...'),
              backgroundColor: const Color(0xFF14366E),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Import and use JitsiMeetingScreen here
        // Create a unique room name based on patientId and current timestamp
        final roomName =
            "patient_${patientId}_${DateTime.now().millisecondsSinceEpoch}";

        return JitsiMeetingScreen(roomName: roomName);
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
    GoRoute(
      path: '/profile-settings',
      builder: (_, __) => const ProfileSettingsPage(),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    GoRoute(
      path: '/file-management',
      builder: (_, __) => const FileManagementPage(),
    ),
    GoRoute(
      path: '/ai-configuration',
      builder: (_, __) => const AIConfigurationPage(),
    ),

    // Video Call Test Route
    GoRoute(
      path: '/video-call-test',
      builder: (_, __) => const VideoCallTestPage(),
    ),

    // Handle routes from legacy menus
    GoRoute(
      path: '/taskscheduling',
      redirect: (context, state) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userRole = userProvider.user?.role;
        return '/dashboard?role=$userRole';
      },
    ),
    GoRoute(
      path: '/chatandcalls',
      redirect: (context, state) {
        return '/dashboard?tab=calls';
      },
    ),
    GoRoute(
      path: '/aiassistant',
      redirect: (context, state) {
        return '/dashboard?tab=ai';
      },
    ),
    GoRoute(
      path: '/fitbit',
      redirect: (context, state) {
        return '/wearables';
      },
    ),
    GoRoute(
      path: '/sos',
      redirect: (context, state) {
        return '/dashboard?tab=emergency';
      },
    ),
  ],
);
