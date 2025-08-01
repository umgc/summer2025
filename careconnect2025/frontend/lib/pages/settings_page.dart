import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common_drawer.dart';
import '../widgets/theme_toggle_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).iconTheme.color,
          size: 24,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.brightness_6,
          color: Theme.of(context).iconTheme.color,
          size: 24,
        ),
        title: Text(
          'Dark Mode',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Toggle between light and dark theme',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const ThemeToggleSwitch(showIcon: false, showLabel: false),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all temporary files and cache data. The app may take longer to load content initially after clearing cache.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Cache cleared successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Account deletion requested. Please contact support.',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: const []),
      drawer: const CommonDrawer(currentRoute: '/settings'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // Apply horizontal padding
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child:
                          (user != null &&
                              user.name != null &&
                              user.name!.isNotEmpty)
                          ? Text(
                              user.name![0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (user != null &&
                              user.name != null &&
                              user.name!.isNotEmpty)
                          ? user.name!
                          : 'User',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      (user != null && user.email.isNotEmpty) ? user.email : '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _buildSectionHeader(context, 'Appearance'),
              _buildThemeCard(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'AI Assistant'),
              _buildSettingsCard(
                context,
                icon: Icons.smart_toy,
                title: 'AI Configuration',
                subtitle: 'Customize your AI assistant settings',
                onTap: () => context.push(
                  '/ai-configuration',
                ), // Use push for back button support
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Subscription'),
              _buildSettingsCard(
                context,
                icon: Icons.subscriptions,
                title: 'Manage Subscription',
                subtitle: 'View or update your subscription plan',
                onTap: () => context.push(
                  '/select-package',
                ), // Use push for back button support
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'General'),
              _buildSettingsCard(
                context,
                icon: Icons.cleaning_services,
                title: 'Clear Cache',
                subtitle: 'Remove temporary files and cache data',
                onTap: () => _showClearCacheDialog(context),
              ),
              _buildSettingsCard(
                context,
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                onTap: () => _showSignOutDialog(context),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
              ),
              _buildSettingsCard(
                context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () => _showDeleteAccountDialog(context),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
