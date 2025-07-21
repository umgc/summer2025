import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:care_connect_app/widgets/responsive_container.dart';

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
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.5), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular icon with background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
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
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            maxWidth:
                1200, // Set a max width to prevent stretching on wide screens
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Text(
                  'CareConnect',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    shadows: const [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 2.5,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Closer Connections. Better Care',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
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
                // Use LayoutBuilder to create a responsive row/column for cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Use row for wider screens, column for narrow screens
                    final useRow = constraints.maxWidth >= 700;

                    return useRow
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Changed from stretch to start
                            children: [
                              Expanded(
                                // Use Expanded instead of SizedBox with fixed width
                                child: _buildUserTypeCard(
                                  context,
                                  title: 'Patient/Care Receiver',
                                  icon: Icons.person,
                                  description:
                                      'Access your health data, communicate with caregivers, and track your care plan. Patients must be registered by a caregiver.',
                                  color: Theme.of(context).primaryColor,
                                  onTap: () {
                                    context.go(
                                      '/login',
                                      extra: {'userType': 'patient'},
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                // Use Expanded instead of SizedBox with fixed width
                                child: _buildUserTypeCard(
                                  context,
                                  title: 'Caregiver',
                                  icon: Icons.health_and_safety,
                                  description:
                                      'Monitor patients, manage care plans, and coordinate with other caregivers',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  onTap: () {
                                    context.go(
                                      '/login',
                                      extra: {'userType': 'caregiver'},
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildUserTypeCard(
                                context,
                                title: 'Patient/Care Receiver',
                                icon: Icons.person,
                                description:
                                    'Access your health data, communicate with caregivers, and track your care plan. Patients must be registered by a caregiver.',
                                color: Theme.of(context).primaryColor,
                                onTap: () {
                                  context.go(
                                    '/login',
                                    extra: {'userType': 'patient'},
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildUserTypeCard(
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
                            ],
                          );
                  },
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                // Centered sign up button with better styling
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth = constraints.maxWidth < 600
                        ? constraints.maxWidth
                        : 300.0;
                    return Center(
                      child: SizedBox(
                        width: buttonWidth,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.go('/signup');
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('New Caregiver? Sign up here'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
