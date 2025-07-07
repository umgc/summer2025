import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'upload_avatar_screen.dart';
import 'package:care_connect_app/main.dart';

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
    // Generate correct image URL for web/mobile.
    String? resolvedUrl;
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      if (kIsWeb) {
        resolvedUrl = 'http://localhost:8080$profileImageUrl';
      } else {
        resolvedUrl = 'http://10.0.2.2:8080$profileImageUrl';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Avatar display: fallback to icon if null
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: (resolvedUrl != null) ? NetworkImage(resolvedUrl) : null,
              child: (resolvedUrl == null)
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
