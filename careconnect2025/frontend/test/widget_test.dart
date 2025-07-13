// Comprehensive Flutter widget tests for CareConnect app
// This test suite covers all major components under lib/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

// Core imports
import 'package:care_connect_app/main.dart';
import 'package:care_connect_app/providers/user_provider.dart';

// Feature imports
import 'package:care_connect_app/features/welcome/presentation/pages/welcome_page.dart';
import 'package:care_connect_app/features/auth/presentation/pages/login_page.dart';
import 'package:care_connect_app/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:care_connect_app/features/auth/presentation/pages/password_reset_page.dart';
import 'package:care_connect_app/features/dashboard/presentation/pages/caregiver_dashboard.dart';
import 'package:care_connect_app/features/dashboard/presentation/pages/patient_dashboard.dart';
import 'package:care_connect_app/features/dashboard/presentation/pages/patient_status_page.dart';
import 'package:care_connect_app/features/analytics/analytics_page.dart';
import 'package:care_connect_app/features/payments/presentation/pages/select_package_page.dart';
import 'package:care_connect_app/features/payments/presentation/pages/payment_success_page.dart';
import 'package:care_connect_app/features/payments/presentation/pages/payment_cancel_page.dart';
import 'package:care_connect_app/features/social/presentation/pages/main_feed_screen.dart';
import 'package:care_connect_app/features/social/presentation/pages/friend_requests_screen.dart';
import 'package:care_connect_app/features/social/presentation/pages/new_post_screen.dart';
import 'package:care_connect_app/features/gamification/presentation/pages/gamification_screen.dart';
import 'package:care_connect_app/features/gamification/presentation/pages/achievement_detail_screen.dart';
import 'package:care_connect_app/features/health/presentation/pages/meal_tracking_screen.dart';
import 'package:care_connect_app/features/health/presentation/pages/symptom_tracker_screen.dart';
import 'package:care_connect_app/features/profile/presentation/pages/settings_screen.dart';

// Model imports
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';
import 'package:care_connect_app/features/payments/models/package_model.dart';
import 'package:care_connect_app/features/analytics/models/vital_model.dart';

// Service imports
import 'package:care_connect_app/services/auth_service.dart';
import 'package:care_connect_app/services/session_manager.dart';
import 'package:care_connect_app/services/gamification_service.dart';

// Widget imports
import 'package:care_connect_app/widgets/user_avatar.dart';

void main() {
  // Set up test environment
  setUpAll(() async {
    // Initialize DotEnv for tests
    dotenv.testLoad(
      fileInput: '''
CC_BASE_URL_WEB=http://localhost:8080/v1/api/
CC_BASE_URL_ANDROID=http://10.0.2.2:8080/v1/api/
CC_BASE_URL_OTHER=http://localhost:8080/v1/api/
CC_BACKEND_TOKEN=test_token
deepSeek_uri=https://api.deepseek.com/v1/chat/completions
deepSeek_key=test_key
STRIPE_PUBLISHABLE_KEY=test_key
    ''',
    );
  });

  group('Core App Tests', () {
    testWidgets('CareConnect app loads successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const CareConnectApp(),
        ),
      );

      // Verify the app loads without errors
      expect(find.byType(MaterialApp), findsOneWidget);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Check that the app title is correct
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('CareConnect'));
    });

    testWidgets('CareConnect app has WelcomePage', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const CareConnectApp(),
        ),
      );

      // Verify WelcomePage exists
      expect(find.byType(WelcomePage), findsOneWidget);
    });
  });

  group('Welcome & Auth Tests', () {
    testWidgets('WelcomePage displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomePage()));

      expect(find.text('CareConnect'), findsOneWidget);
      expect(find.text('Closer Connections. Better Care'), findsOneWidget);
      expect(find.text('Welcome to CareConnect!'), findsOneWidget);
      expect(find.text('Patient/Care Receiver'), findsOneWidget);
      expect(find.text('Care-Giver'), findsOneWidget);
    });

    testWidgets('LoginPage displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.text('Care Connect'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('SignUpScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(Stepper), findsOneWidget);
    });

    testWidgets('PasswordResetPage renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PasswordResetPage()));

      expect(find.byType(PasswordResetPage), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(FilledButton), findsWidgets);
    });
  });

  group('Dashboard Tests', () {
    testWidgets('CaregiverDashboard renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CaregiverDashboard()));

      expect(find.byType(CaregiverDashboard), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('PatientDashboard renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PatientDashboard()));

      expect(find.byType(PatientDashboard), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('PatientStatusPage renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          child: const MaterialApp(home: PatientStatusPage()),
        ),
      );

      expect(find.byType(PatientStatusPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Analytics Tests', () {
    testWidgets('AnalyticsPage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalyticsPage(patientId: 1)),
      );

      expect(find.byType(AnalyticsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Payment Tests', () {
    testWidgets('SelectPackagePage renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SelectPackagePage()));

      expect(find.byType(SelectPackagePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('PaymentSuccessPage renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/payment-success',
            routes: [
              GoRoute(
                path: '/payment-success',
                builder: (context, state) => const PaymentSuccessPage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('Login')),
              ),
              GoRoute(
                path: '/dashboard/patient',
                builder: (context, state) =>
                    const Scaffold(body: Text('Dashboard')),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(PaymentSuccessPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Wait for animations and timers to complete
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('PaymentCancelPage renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PaymentCancelPage()));

      expect(find.byType(PaymentCancelPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Social Feature Tests', () {
    testWidgets('MainFeedScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: MainFeedScreen(userId: 1)),
      );

      expect(find.byType(MainFeedScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('FriendRequestsScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: FriendRequestsScreen(userId: 1)),
      );

      expect(find.byType(FriendRequestsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('NewPostScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NewPostScreen(userId: 1)),
      );

      expect(find.byType(NewPostScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Gamification Tests', () {
    testWidgets('GamificationScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GamificationScreen()));

      expect(find.byType(GamificationScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AchievementDetailScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AchievementDetailScreen(achievements: [])),
      );

      expect(find.byType(AchievementDetailScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Health Feature Tests', () {
    testWidgets('MealTrackingScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MealTrackingScreen()));

      expect(find.byType(MealTrackingScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SymptomTrackerScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SymptomTrackerScreen()));

      expect(find.byType(SymptomTrackerScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Profile Tests', () {
    testWidgets('SettingsScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Model Tests', () {
    test('Patient model creates correctly', () {
      final patient = Patient(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '555-1234',
        dob: '1990-01-01',
        relationship: 'self',
        address: Address(
          line1: '123 Main St',
          city: 'Anytown',
          state: 'NY',
          zip: '12345',
        ),
      );

      expect(patient.id, 1);
      expect(patient.firstName, 'John');
      expect(patient.lastName, 'Doe');
      expect(patient.email, 'john@example.com');
      expect(patient.address?.line1, '123 Main St');
    });

    test('PackageModel creates correctly', () {
      final package = PackageModel(
        id: 'basic-plan',
        name: 'Basic Plan',
        priceCents: 2999,
        description: 'Basic features',
      );

      expect(package.id, 'basic-plan');
      expect(package.name, 'Basic Plan');
      expect(package.priceCents, 2999);
      expect(package.description, 'Basic features');
    });

    test('Vital creates correctly', () {
      final vital = Vital(
        patientId: 1,
        timestamp: DateTime.now(),
        heartRate: 72.0,
        spo2: 98.0,
        systolic: 120,
        diastolic: 80,
        weight: 70.5,
      );

      expect(vital.patientId, 1);
      expect(vital.heartRate, 72.0);
      expect(vital.spo2, 98.0);
      expect(vital.systolic, 120);
      expect(vital.diastolic, 80);
      expect(vital.weight, 70.5);
    });

    test('Address creates correctly', () {
      final address = Address(
        line1: '123 Main St',
        line2: 'Apt 4B',
        city: 'Anytown',
        state: 'NY',
        zip: '12345',
        phone: '555-1234',
      );

      expect(address.line1, '123 Main St');
      expect(address.line2, 'Apt 4B');
      expect(address.city, 'Anytown');
      expect(address.state, 'NY');
      expect(address.zip, '12345');
      expect(address.phone, '555-1234');
    });
  });

  group('Service Tests', () {
    test('AuthService exists and has required methods', () {
      expect(AuthService.login, isA<Function>());
      expect(AuthService.register, isA<Function>());
      expect(AuthService.logout, isA<Function>());
    });

    test('SessionManager can be instantiated', () {
      final sessionManager = SessionManager();
      expect(sessionManager, isNotNull);
      expect(sessionManager.restoreSession, isA<Function>());
    });

    test('GamificationService can be instantiated', () {
      final gamificationService = GamificationService();
      expect(gamificationService, isNotNull);
    });
  });

  group('Provider Tests', () {
    test('UserProvider manages user state correctly', () {
      final userProvider = UserProvider();

      expect(userProvider.user, isNull);

      final user = UserSession(
        id: 1,
        role: 'PATIENT',
        token: 'test_token',
        email: 'testme@sample.com',
        patientId: 1,
      );

      userProvider.setUser(user);
      expect(userProvider.user, isNotNull);
      expect(userProvider.user!.id, 1);
      expect(userProvider.user!.role, 'PATIENT');

      userProvider.clearUser();
      expect(userProvider.user, isNull);
    });
  });

  group('Widget Tests', () {
    testWidgets('UserAvatar renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              imageUrl: null,
            ), // No image URL to avoid network calls in tests
          ),
        ),
      );

      expect(find.byType(UserAvatar), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(
        find.byIcon(Icons.person),
        findsOneWidget,
      ); // Should show person icon when no image
    });
  });
}
