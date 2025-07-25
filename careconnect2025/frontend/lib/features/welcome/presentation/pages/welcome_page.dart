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
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Create distinct color schemes for better contrast
    final bgColor = isPrimary ? color : color.withAlpha(25);
    final textColor = isPrimary ? Colors.white : color;
    final iconColor = isPrimary ? Colors.white : color;
    final buttonBgColor = isPrimary ? Colors.white.withAlpha(51) : color;
    final buttonTextColor = isPrimary ? Colors.white : Colors.white;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : 500, // Constrain card width
      ),
      height: isMobile ? 120 : 140, // Fixed compact height
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [color, color.withAlpha(204)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [color.withAlpha(25), color.withAlpha(51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(128),
          width: isPrimary ? 0 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                // Icon section
                Container(
                  width: isMobile ? 50 : 60,
                  height: isMobile ? 50 : 60,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withAlpha(51)
                        : color.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: isMobile ? 24 : 30, color: iconColor),
                ),
                const SizedBox(width: 16),
                // Text section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          color: textColor.withAlpha(204),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Login button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: buttonBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          color: buttonTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: buttonTextColor,
                        size: isMobile ? 14 : 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background image layer
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay for better text readability
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor.withAlpha(
                    153,
                  ), // 0.6 opacity (reduced from 0.9)
                  theme.scaffoldBackgroundColor.withAlpha(
                    128,
                  ), // 0.5 opacity (reduced from 0.8)
                  theme.scaffoldBackgroundColor.withAlpha(
                    102,
                  ), // 0.4 opacity (reduced from 0.7)
                ],
              ),
            ),
          ),
          // Content layer
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile
                        ? double.infinity
                        : 600, // Constrain overall width
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 16 : 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Layered header with backdrop for better readability
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230), // 0.9 opacity
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26), // 0.1 opacity
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'CareConnect',
                              style: TextStyle(
                                fontSize: isMobile ? 32 : 42,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withAlpha(
                                      51,
                                    ), // 0.2 opacity
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Closer Connections. Better Care',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  179,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose your role to get started',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  153,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 32 : 40),

                      // CareGiver card with primary styling
                      _buildUserTypeCard(
                        context,
                        title: 'CareGiver',
                        icon: Icons.health_and_safety,
                        description:
                            'Monitor patients, manage care plans, coordinate care',
                        color: theme.colorScheme.primary,
                        isPrimary: true,
                        onTap: () {
                          context.go(
                            '/login',
                            extra: {'userType': 'caregiver'},
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // CareReceiver card with secondary styling
                      _buildUserTypeCard(
                        context,
                        title: 'CareReceiver',
                        icon: Icons.person,
                        description:
                            'Access health data, communicate with caregivers',
                        color: theme.colorScheme.secondary,
                        isPrimary: false,
                        onTap: () {
                          context.go('/login', extra: {'userType': 'patient'});
                        },
                      ),
                      SizedBox(height: isMobile ? 32 : 40),

                      // Compact sign up section with backdrop
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 400,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(217), // 0.85 opacity
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26), // 0.1 opacity
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'New CareGiver?',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  print(
                                    '🔍 Sign up button pressed',
                                  ); // Debug print
                                  try {
                                    context.go('/signup');
                                  } catch (e) {
                                    print('🔍 Navigation error: $e');
                                  }
                                },
                                icon: Icon(
                                  Icons.person_add,
                                  size: isMobile ? 18 : 20,
                                  color: theme.colorScheme.primary,
                                ),
                                label: Text(
                                  'Sign Up Here',
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 14 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                  backgroundColor: theme.colorScheme.primary
                                      .withAlpha(13), // 0.05 opacity
                                  // Add material tap target size to ensure proper touch handling
                                  tapTargetSize: MaterialTapTargetSize.padded,
                                  // Ensure button is properly sized
                                  minimumSize: Size(
                                    double.infinity,
                                    isMobile ? 48 : 56,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
