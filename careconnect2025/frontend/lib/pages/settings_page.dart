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
  @override
  Widget build(BuildContext context) {
    print('🔍 SettingsPage: Building settings page');
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final isPatient = user != null && user.role.toUpperCase() == 'PATIENT';

    print('🔍 SettingsPage: User is patient: $isPatient, User: ${user?.name}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              // Use GoRouter to navigate back properly
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          // Save button
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      drawer: const CommonDrawer(currentRoute: '/settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI Configuration Section (Patient only)
          if (isPatient) ...[
            _buildSectionHeader(context, 'AI Assistant'),
            _buildSettingsCard(
              context,
              icon: Icons.smart_toy,
              title: 'AI Configuration',
              subtitle: 'Customize your AI assistant settings',
              onTap: () => context.go('/ai-configuration'),
            ),
            const SizedBox(height: 24),
          ],

          // Billing Section (Caregiver only)
          if (!isPatient) ...[
            _buildSettingsCard(
              context,
              icon: Icons.receipt_long,
              title: 'Billing History',
              subtitle: 'View past invoices and payments',
              onTap: () => context.go('/billing-history'),
            ),
            const SizedBox(height: 24),
          ],

          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          _buildSettingsCard(
            context,
            icon: Icons.notifications,
            title: 'Notification Settings',
            subtitle: 'Configure alerts and reminders',
            onTap: () => context.go('/notification-settings'),
          ),
          _buildSettingsCard(
            context,
            icon: Icons.sms,
            title: 'SMS Settings',
            subtitle: 'Manage SMS notifications',
            onTap: () => context.go('/sms-settings'),
          ),
          const SizedBox(height: 24),

          // Privacy & Security Section
          _buildSectionHeader(context, 'Privacy & Security'),
          _buildSettingsCard(
            context,
            icon: Icons.security,
            title: 'Privacy Settings',
            subtitle: 'Control your data and privacy',
            onTap: () => context.go('/privacy-settings'),
          ),
          _buildSettingsCard(
            context,
            icon: Icons.password,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => context.go('/change-password'),
          ),
          const SizedBox(height: 24),

          // App Preferences Section
          _buildSectionHeader(context, 'App Preferences'),
          _buildThemeCard(context),
          _buildSettingsCard(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Change app language',
            onTap: () => context.go('/language-settings'),
          ),
          const SizedBox(height: 24),

          // Emergency Contacts Section
          _buildSectionHeader(context, 'Emergency'),
          _buildSettingsCard(
            context,
            icon: Icons.emergency,
            title: 'Emergency Contacts',
            subtitle: 'Manage emergency contact information',
            onTap: () => context.go('/emergency-contacts'),
          ),
          const SizedBox(height: 24),

          // Data & Storage Section
          _buildSectionHeader(context, 'Data & Storage'),
          _buildSettingsCard(
            context,
            icon: Icons.backup,
            title: 'Data Backup',
            subtitle: 'Backup and restore your data',
            onTap: () => context.go('/data-backup'),
          ),
          _buildSettingsCard(
            context,
            icon: Icons.delete_sweep,
            title: 'Clear Cache',
            subtitle: 'Clear app cache and temporary files',
            onTap: () => _showClearCacheDialog(context),
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader(context, 'Support'),
          _buildSettingsCard(
            context,
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => context.go('/help-support'),
          ),
          _buildSettingsCard(
            context,
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => context.go('/about'),
          ),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader(context, 'Account'),
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

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Placeholder for save settings functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));

    // Navigate back to dashboard after saving
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      }
    });
  }

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
              // Implement account deletion logic
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
}
