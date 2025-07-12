import 'package:deeptrainfront/screens/trainee_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '/auth/login_screen.dart';
import '/auth/register_screen.dart';
import '/screens/home_screen.dart';
import '/screens/simulator_screen.dart';
import '/screens/scenario_builder_screen.dart';
import '/screens/admin_dashboard.dart';
import '/screens/designer_dashboard.dart';
import '/screens/dashboard_screen.dart'; 
import '/screens/kpi_dashboard_screen.dart';
import '/state/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final token = ref.watch(jwtTokenProvider);
  final role = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;

      // Allow public pages
      const publicPaths = ['/login', '/signUp', '/reset-password', '/confirm'];
      if (publicPaths.contains(path)) {
        return null;
      }

      // Not logged in
      if (token == null) {
        return '/login';
      }

      // Role-based restrictions
      if (path.startsWith('/admin') && role != 'Admin') {
        return '/unauthorized';
      }
      if (path.startsWith('/designer') && role != 'Designer') {
        return '/unauthorized';
      }
      if (path.startsWith('/trainee') && role != 'Trainee') {
        return '/unauthorized';
      }

      return null; // Allow navigation
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signUp', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/designer', builder: (context, state) => const DesignerDashboardScreen()),
      GoRoute(path: '/trainee', builder: (context, state) => const TraineeDashboardScreen()),
      GoRoute(
  path: '/scenario',
  builder: (context, state) => const ScenarioBuilderScreen(initialDomain: 'Healthcare'),
),

        GoRoute(path: '/simulator', builder: (context, state) => const SimulatorScreen()),
        GoRoute(path: '/Kpi', builder: (context, state) => const KpiDashboardScreen()),
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(
              'Unauthorized access',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
        ),
      ),
    ],
  );
});
