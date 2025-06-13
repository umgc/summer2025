import 'package:flutter/material.dart';
import 'package:care_connect_app/gamification_screen.dart';


class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final caregivers = [
      {'name': 'Maggie Simpson', 'status': 'Available', 'lastSeen': '15 mins ago'},
      {'name': 'Ryan Simpson', 'status': 'Available', 'lastSeen': '25 mins ago'},
      {'name': 'Jackie Simpson', 'status': 'Available', 'lastSeen': '20 mins ago'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person, size: 30)),
                  SizedBox(height: 8),
                  Text('Patient Name', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Patient', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ...[
              {'icon': Icons.group, 'title': 'Caregiver Management'},
              {'icon': Icons.video_camera_front, 'title': 'Virtual Check-In'},
              {'icon': Icons.medical_services, 'title': 'TeleHealth'},
              {'icon': Icons.note_alt, 'title': 'Health Care Note'},
              {
                'icon': Icons.emoji_events,
                'title': 'Gamification',
                'route': (BuildContext context) {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GamificationScreen()));
                },
              },
              {'icon': Icons.settings, 'title': 'Settings'},
              {'icon': Icons.help_outline, 'title': 'Help & Support'},
            ].map((item) {
              return ListTile(
                leading: Icon(item['icon'] as IconData),
                title: Text(item['title'] as String),
                onTap: () {
                  final Function? routeFn = item['route'] as Function?;
                  if (routeFn != null) {
                    routeFn(context);
                  }
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good Morning !!!  Homer Simpson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),

              const Text('How are you feeling today?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    EmojiLabel(emoji: '😡', label: 'Angry'),
                    EmojiLabel(emoji: '😐', label: 'Sad'),
                    EmojiLabel(emoji: '😫', label: 'Tired'),
                    EmojiLabel(emoji: '😨', label: 'Fearful'),
                    EmojiLabel(emoji: '😑', label: 'Neutral'),
                    EmojiLabel(emoji: '😊', label: 'Happy'),
                  ],
                ),
              ),
              const Divider(height: 30, thickness: 2),

              const Text('How is your pain today?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  PainEmojiLabel(emoji: '😀', label: '1\nNo Pain'),
                  PainEmojiLabel(emoji: '🙂', label: '2\nMild'),
                  PainEmojiLabel(emoji: '😐', label: '3\nModerate'),
                  PainEmojiLabel(emoji: '😣', label: '4\nSevere'),
                  PainEmojiLabel(emoji: '😭', label: '5\nWorst Pain'),
                ],
              ),
              const Divider(height: 30, thickness: 2),

              ...caregivers.map((c) => CaregiverCard(
                name: c['name']!,
                status: c['status']!,
                lastInteraction: c['lastSeen']!,
              )),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {},
                child: const Text(
                  'View Today’s Task',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.red),
                  label: const Text('SOS CALL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Sub-widgets for mood/pain/caregivers (same as before)

class EmojiLabel extends StatelessWidget {
  final String emoji;
  final String label;
  const EmojiLabel({super.key, required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class PainEmojiLabel extends StatelessWidget {
  final String emoji;
  final String label;
  const PainEmojiLabel({super.key, required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class CaregiverCard extends StatelessWidget {
  final String name;
  final String status;
  final String lastInteraction;
  const CaregiverCard({super.key, required this.name, required this.status, required this.lastInteraction});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.blue.shade900), borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        leading: const CircleAvatar(child: Text("D")),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Status: $status\nLast Interaction: $lastInteraction'),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
