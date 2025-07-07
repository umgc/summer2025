import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontend/caregiver_dashboard.dart';
import 'frontend/caregiver_login_screen.dart';
import 'frontend/login_screen.dart';
import 'frontend/PatientDashboard/patient_main_screen.dart';
import 'frontend/session_manager.dart';
import 'frontend/SetNewPasswordScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  print('main() started');
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  print('dotenv loaded');

  // 👇 Flutter web: check for reset-password on cold start
  final uri = Uri.base; // e.g., http://localhost:3000/reset-password?token=123
  Widget home = const LaunchRouter();
  if (uri.path == '/reset-password' && uri.queryParameters['token'] != null) {
    home = SetNewPasswordScreen(token: uri.queryParameters['token']!);
  }

  runApp(CareConnectApp(homeOverride: home));
}

class CareConnectApp extends StatelessWidget {
  final Widget homeOverride;
  const CareConnectApp({super.key, required this.homeOverride});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: homeOverride, // This shows the correct initial page!
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        if (uri.path == '/reset-password') {
          final token = uri.queryParameters['token'] ?? '';
          return MaterialPageRoute(
            builder: (_) => SetNewPasswordScreen(token: token),
            settings: settings,
          );
        }
        return MaterialPageRoute(builder: (_) => const LaunchRouter());
      },
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const LaunchRouter()),
    );
  }
}

class LaunchRouter extends StatefulWidget {
  const LaunchRouter({super.key});
  @override
  State<LaunchRouter> createState() => _LaunchRouterState();
}

class _LaunchRouterState extends State<LaunchRouter> {
  Widget _redirect = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    print('LaunchRouter initState');
    _initSessionAndRedirect();
  }

  Future<void> _initSessionAndRedirect() async {
    print('initSessionAndRedirect start');
    await SessionManager().restoreSession();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final role = prefs.getString('role');
    if (userId != null && role == 'patient') {
      setState(() {
        _redirect = PatientDashboard(userId: int.parse(userId));
      });
    } else if (userId != null && role == 'caregiver') {
      setState(() {
        _redirect = const CaregiverDashboard();
      });
    } else {
      setState(() {
        _redirect = const WelcomeScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _redirect;
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Text(
                  'CareConnect',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    shadows: [
                      const Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Closer Connections. Better Care',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/banner.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to CareConnect!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "We’re here to help you stay connected, supported, and in control of your care journey. Whether you’re managing a loved one’s health or tracking your own, everything you need is just a tap away.\nLet's get started.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Patient/Care Receiver',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CaregiverLoginScreen()),
                        );
                      },
                      child: const Text(
                        'Care-Giver',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
