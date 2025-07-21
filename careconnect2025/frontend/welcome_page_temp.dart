import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Widget _buildUserTypeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.5), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    color: Theme.of(context).primaryColor,
                    shadows: const [
                      Shadow(
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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "We're here to help you stay connected, supported, and in control of your care journey. Whether you're managing a loved one's health or tracking your own, everything you need is just a tap away.\nLet's get started.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: _buildUserTypeCard(
                        context,
                        title: 'Patient/Care Receiver',
                        icon: Icons.person,
                        description:
                            'Access your health data, communicate with caregivers, and track your care plan. Patients must be registered by a caregiver.',
                        color: Theme.of(context).primaryColor,
                        onTap: () {
                          context.go('/login', extra: {'userType': 'patient'});
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUserTypeCard(
                        context,
                        title: 'Caregiver',
                        icon: Icons.health_and_safety,
                        description:
                            'Monitor patients, manage care plans, and coordinate with other caregivers',
                        color: Theme.of(context).colorScheme.secondary,
                        onTap: () {
                          context.go(
                            '/login',
                            extra: {'userType': 'caregiver'},
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    context.go('/signup');
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('New Caregiver? Sign up here'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
