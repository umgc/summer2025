import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../config/router/app_router.dart';
import 'theme_toggle_switch.dart';

class CommonDrawer extends StatelessWidget {
  final String currentRoute;

  const CommonDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final isPatient = user?.role?.toUpperCase() == 'PATIENT';
    final isCaregiver =
        user?.role?.toUpperCase() == 'CAREGIVER' ||
        user?.role?.toUpperCase() == 'FAMILY_LINK' ||
        user?.role?.toUpperCase() == 'ADMIN';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color:
                        Theme.of(context).appBarTheme.foregroundColor ??
                        Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.role ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        (Theme.of(context).appBarTheme.foregroundColor ??
                                Theme.of(context).colorScheme.onPrimary)
                            .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Dashboard - always visible
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            isActive: currentRoute == '/dashboard',
            onTap: () {
              Navigator.pop(context);
              navigateToDashboard(context);
            },
          ),

          // Caregiver-specific menu items
          if (isCaregiver) ...[
            _buildDrawerItem(
              context,
              icon: Icons.person_add,
              title: 'Add Patient',
              route: '/add-patient',
              isActive: currentRoute == '/add-patient',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.payment,
              title: 'Subscription Management',
              route: '/select-package',
              isActive: currentRoute == '/select-package',
            ),
          ],

          // Analytics removed as requested
          _buildDrawerItem(
            context,
            icon: Icons.emoji_events,
            title: 'Gamification',
            route: '/gamification',
            isActive: currentRoute == '/gamification',
          ),

          _buildDrawerItem(
            context,
            icon: Icons.people_alt,
            title: 'Social Feed',
            route: '/social-feed',
            isActive: currentRoute == '/social-feed',
            onTap: () {
              Navigator.pop(context);
              final userId = user?.id ?? 1;
              context.go('/social-feed?userId=$userId');
            },
          ),

          // Device integration items
          _buildDrawerItem(
            context,
            icon: Icons.watch,
            title: 'Wearables',
            route: '/wearables',
            isActive: currentRoute == '/wearables',
          ),

          _buildDrawerItem(
            context,
            icon: Icons.home_outlined,
            title: 'Home Monitoring',
            route: '/home-monitoring',
            isActive: currentRoute == '/home-monitoring',
          ),

          _buildDrawerItem(
            context,
            icon: Icons.devices,
            title: 'Smart Devices',
            route: '/smart-devices',
            isActive: currentRoute == '/smart-devices',
          ),

          _buildDrawerItem(
            context,
            icon: Icons.medication,
            title: 'Medication Management',
            route: '/medication',
            isActive: currentRoute == '/medication',
          ),

          const Divider(),

          // Theme Toggle
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  color: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const ThemeToggleSwitch(showIcon: false, showLabel: false),
              ],
            ),
          ),

          const Divider(),

          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            iconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
            onTap: () async {
              Navigator.pop(context);
              // Logout action
              await userProvider.clearUser();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    bool isActive = false,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.primaryColor
        : (textColor ??
              theme.textTheme.bodyLarge?.color ??
              theme.colorScheme.onSurface);
    final bgColor = isActive ? theme.primaryColor.withOpacity(0.1) : null;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive
            ? theme.primaryColor
            : (iconColor ?? theme.colorScheme.onSurface),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: bgColor,
      onTap:
          onTap ??
          (route != null
              ? () {
                  Navigator.pop(context);
                  context.go(route);
                }
              : null),
    );
  }
}
