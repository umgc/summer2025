import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'caregiver_login_screen.dart';
import 'patient_dashboard.dart'; // Make sure this import path is correct
import 'caregiver_dashboard.dart'; // Optional if you want to route caregivers

void main() {
  runApp(const CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LaunchRouter(), // 👈 Entry point based on login status
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
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final role = prefs.getString('role');

    if (userId != null && role == 'patient') {
      setState(() {
        _redirect = PatientDashboard(userId: int.parse(userId));
      });
    } else if (userId != null && role == 'caregiver') {
      setState(() {
        _redirect = const CaregiverDashboard(); // You can pass userId here if needed
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
