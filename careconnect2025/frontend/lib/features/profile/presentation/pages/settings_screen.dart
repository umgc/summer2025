// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
// import 'dart:io';
import 'package:care_connect_app/widgets/user_avatar.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'upload_avatar_screen.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? name;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('userName') ?? 'User';
      profileImageUrl = prefs.getString('profileImageUrl');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarHelper.createAppBar(context, title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            UserAvatar(imageUrl: profileImageUrl, radius: 40),
            const SizedBox(height: 10),
            Text(name ?? '', style: theme.textTheme.titleLarge),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload Avatar'),
              style: AppTheme.primaryButtonStyle,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadAvatarScreen()),
                );
                await loadUserInfo(); // Refresh after returning
              },
            ),
            const SizedBox(height: 30),
            const Divider(),
            ListTile(
              leading: Icon(Icons.lock, color: theme.colorScheme.primary),
              title: Text('Change Password', style: theme.textTheme.bodyLarge),
              onTap: () {
                // TODO: Implement password change screen
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                'Logout',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;

                // Navigate to welcome page and clear the navigation stack
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
