//Create a drawer for a navigation menu that can be used across the app
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/config/utils/responsive_utils.dart';
import 'package:care_connect_app/config/utils/web_utils.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final isFamilyMember = user?.role == 'FAMILY_MEMBER';

        return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue.shade700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.name ?? 'User Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isFamilyMember ? 'Family Member' : 'Caregiver',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Gamification'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/gamification');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Subscription Management'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/subscription-management');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(isFamilyMember ? 'My Patients' : 'Patients'),
                  onTap: () {
                    Navigator.pop(context);
                    if (isFamilyMember) {
                      context.go('/family-patients');
                    } else {
                      context.go('/patients');
                    }
                  },
                ),
                // Only show these options for caregivers
                if (!isFamilyMember) ...[
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Register Patient'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/register/patient');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Subscribe'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/select-package');
                    },
                  ),
                ],
                // Show read-only badge for family members
                if (isFamilyMember)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Read-only access',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/settings');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!context.mounted) return;
                    context.go('/');
                  },
                ),
              ],
            ),
          );
      },
    );
  }
}