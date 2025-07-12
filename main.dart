import 'package:deeptrainfront/screens/about_screen.dart';
import 'package:deeptrainfront/screens/contact_screen.dart';
import 'package:deeptrainfront/screens/features_screen.dart';
import 'package:deeptrainfront/screens/pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'lib/screens/home_screen.dart';
import 'lib/screens/dashboard_screen.dart';
import 'lib/screens/scenario_builder_screen.dart';
import 'lib/screens/simulator_screen.dart';
import 'lib/screens/kpi_dashboard_screen.dart';
import 'lib/auth/login_screen.dart';
import 'lib/auth/register_screen.dart';
import 'lib/auth/auth_confirm_screen.dart';
import 'lib/auth/auth_reset_password.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: 'Builder',
          builder: (context, state) =>
              const ScenarioBuilderScreen(initialDomain: 'Healthcare'),
        ),
        GoRoute(
          path: 'simulator',
          builder: (context, state) => const SimulatorScreen(),
        ),
        GoRoute(
          path: 'kpi',
          builder: (context, state) => const KpiDashboardScreen(),
        ),
      ],
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/signUp',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/features',
      builder: (context, state) => const FeaturesScreen(),
    ),
    GoRoute(
      path: '/pricing',
      builder: (context, state) => const PricingScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/confirm',
      builder: (context, state) {
        final email = state.extra as String;
        return AuthConfirmScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeepTrain',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}
