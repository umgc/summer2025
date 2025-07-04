// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
// import 'dart:io';
import 'package:care_connect_app/widgets/user_avatar.dart';
import 'upload_avatar_screen.dart';
import 'package:care_connect_app/config/env_constant.dart';

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
    final resolvedUrl = profileImageUrl != null && profileImageUrl!.isNotEmpty
        ? '${getBackendBaseUrl()}$profileImageUrl'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            UserAvatar(imageUrl: profileImageUrl, radius: 40),
            const SizedBox(height: 10),
            Text(
              name ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload Avatar'),
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
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                // TODO: Implement password change screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
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
