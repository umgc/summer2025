import 'package:flutter/material.dart';

class CaregiverGamificationScreen extends StatelessWidget {
  final String patientName;

  const CaregiverGamificationScreen({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    final patientGamificationData = {
      'name': patientName,
      'badges': ['3-Day Streak', 'Hydration Hero', 'Early Riser'],
      'xp': 450,
      'level': 4,
      'streak': 3,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Engagement Summary'),
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Patient: ${patientGamificationData['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text('XP: ${patientGamificationData['xp']}'),
                subtitle: Text('Level: ${patientGamificationData['level']}'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                title: const Text('Current Streak'),
                subtitle: Text('${patientGamificationData['streak']} days'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Earned Badges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: (patientGamificationData['badges'] as List<String>).map((badge) {
                return Chip(
                  label: Text(badge),
                  avatar: const Icon(Icons.emoji_events, color: Colors.amber),
                  backgroundColor: Colors.blue.shade50,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Engagement Overview (Chart Placeholder)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('Chart Goes Here')),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Encouragement sent!")),
                );
              },
              icon: const Icon(Icons.thumb_up),
              label: const Text("Send Encouragement"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
