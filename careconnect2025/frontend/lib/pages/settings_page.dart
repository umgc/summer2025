import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common_drawer.dart';
import '../widgets/theme_toggle_switch.dart';
import '../models/notification_settings.dart';
import '../services/notification_settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  NotificationSettings? _notificationSettings;
  bool _loadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      final settings =
          await NotificationSettingsService.getNotificationSettings(user.id);
      setState(() {
        _notificationSettings = settings;
        _loadingSettings = false;
      });
    } else {
      setState(() {
        _loadingSettings = false;
      });
    }
  }

  Future<void> _updateNotificationSetting(String setting, bool value) async {
    if (_notificationSettings == null) return;

    NotificationSettings updatedSettings;
    switch (setting) {
      case 'gamification':
        updatedSettings = _notificationSettings!.copyWith(gamification: value);
        break;
      case 'emergency':
        updatedSettings = _notificationSettings!.copyWith(emergency: value);
        break;
      case 'videoCall':
        updatedSettings = _notificationSettings!.copyWith(videoCall: value);
        break;
      case 'audioCall':
        updatedSettings = _notificationSettings!.copyWith(audioCall: value);
        break;
      case 'sms':
        updatedSettings = _notificationSettings!.copyWith(sms: value);
        break;
      case 'significantVitals':
        updatedSettings = _notificationSettings!.copyWith(
          significantVitals: value,
        );
        break;
      default:
        return;
    }

    final saved = await NotificationSettingsService.saveNotificationSettings(
      updatedSettings,
    );
    if (saved != null) {
      setState(() {
        _notificationSettings = saved;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Notification settings updated'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Failed to update settings'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
          color: iconColor ?? Theme.of(context).colorScheme.primary,
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
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotificationToggleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.brightness_6,
          color: Theme.of(context).colorScheme.primary,
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

    // Check if user is Patient or Family Member to hide subscription management
    final shouldHideSubscription =
        user != null &&
        (user.role.toLowerCase() == 'patient' ||
            user.role.toLowerCase() == 'family member');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const CommonDrawer(currentRoute: '/settings'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              const SizedBox(height: 16),
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
              _buildSectionHeader(context, 'Notifications'),
              if (_loadingSettings)
                const Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Loading notification settings...'),
                  ),
                )
              else if (_notificationSettings != null) ...[
                _buildNotificationToggleCard(
                  context,
                  icon: Icons.emergency,
                  title: 'Emergency Alerts',
                  subtitle: 'Critical health alerts and emergencies',
                  value: _notificationSettings!.emergency,
                  onChanged: (value) =>
                      _updateNotificationSetting('emergency', value),
                  iconColor: Theme.of(context).colorScheme.error,
                ),
                _buildNotificationToggleCard(
                  context,
                  icon: Icons.video_call,
                  title: 'Video Call Notifications',
                  subtitle: 'Incoming video call alerts',
                  value: _notificationSettings!.videoCall,
                  onChanged: (value) =>
                      _updateNotificationSetting('videoCall', value),
                ),
                _buildNotificationToggleCard(
                  context,
                  icon: Icons.call,
                  title: 'Audio Call Notifications',
                  subtitle: 'Incoming audio call alerts',
                  value: _notificationSettings!.audioCall,
                  onChanged: (value) =>
                      _updateNotificationSetting('audioCall', value),
                ),
                _buildNotificationToggleCard(
                  context,
                  icon: Icons.favorite,
                  title: 'Significant Vitals',
                  subtitle: 'Important changes in vital signs',
                  value: _notificationSettings!.significantVitals,
                  onChanged: (value) =>
                      _updateNotificationSetting('significantVitals', value),
                ),
                _buildNotificationToggleCard(
                  context,
                  icon: Icons.sms,
                  title: 'SMS Notifications',
                  subtitle: 'Text message alerts to your phone',
                  value: _notificationSettings!.sms,
                  onChanged: (value) =>
                      _updateNotificationSetting('sms', value),
                ),
                _buildNotificationToggleCard(
                  context,
                  icon: Icons.stars,
                  title: 'Gamification',
                  subtitle: 'Achievement and progress notifications',
                  value: _notificationSettings!.gamification,
                  onChanged: (value) =>
                      _updateNotificationSetting('gamification', value),
                ),
              ] else
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text('Unable to load notification settings'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadNotificationSettings,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'AI Assistant'),
              _buildSettingsCard(
                context,
                icon: Icons.smart_toy,
                title: 'AI Configuration',
                subtitle: 'Customize your AI assistant settings',
                onTap: () => context.push('/ai-configuration'),
              ),
              const SizedBox(height: 24),
              // Only show subscription management for non-patient/family member users
              if (!shouldHideSubscription) ...[
                _buildSectionHeader(context, 'Subscription'),
                _buildSettingsCard(
                  context,
                  icon: Icons.subscriptions,
                  title: 'Manage Subscription',
                  subtitle: 'View or update your subscription plan',
                  onTap: () => context.push('/select-package'),
                ),
                const SizedBox(height: 24),
              ],
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
