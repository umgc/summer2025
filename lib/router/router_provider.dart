import 'package:deeptrainfront/screens/kpi_dashboard_screen.dart';
import 'package:deeptrainfront/screens/scenario_builder_screen.dart';
import 'package:deeptrainfront/screens/simulator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/auth/login_screen.dart';
import '/auth/register_screen.dart';
import '/auth/auth_confirm_screen.dart';
import '/auth/auth_reset_password.dart';

import '/screens/home_screen.dart';
import '/screens/admin_dashboard.dart';
import '/screens/designer_dashboard.dart';
import '/screens/trainee_dashboard.dart';


import '/state/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final token = ref.watch(jwtTokenProvider);
  final role = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthPage = [
        '/login',
        '/signUp',
        '/confirm',
        '/reset-password',
      ].contains(path);

      // Not logged in and trying to access a protected route
      if (token == null && !isAuthPage && path != '/') {
        return '/login';
      }

      // Logged in but trying to access wrong dashboard
      if (token != null) {
        if (path == '/' || isAuthPage) {
          // 👇 Redirect to role-based dashboard
          if (role == 'Admin') return '/admin';
          if (role == 'Designer') return '/designer';
          if (role == 'Trainee') return '/trainee';
        }

        if (path == '/admin' && role != 'Admin') return '/unauthorized';
        if (path == '/designer' && role != 'Designer') return '/unauthorized';
        if (path == '/trainee' && role != 'Trainee') return '/unauthorized';
      }

      return null; // allow
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signUp', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/confirm', builder: (context, state) {
        final email = state.extra as String;
        return AuthConfirmScreen(email: email);
      }),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
     GoRoute(
  path: '/scenario',
  builder: (context, state) => const ScenarioBuilderScreen(initialDomain: 'Healthcare'),
),

      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/designer', builder: (context, state) => const DesignerDashboardScreen()),
      GoRoute(path: '/trainee', builder: (context, state) => const TraineeDashboardScreen()),
      GoRoute(path: '/simulator', builder: (context, state) => const SimulatorScreen()),
      GoRoute(path: '/Kpi', builder: (context, state) => const KpiDashboardScreen()),
      
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Unauthorized access')),
        ),
      ),
    ],
  );
});
