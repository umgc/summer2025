import 'package:flutter/material.dart';
import 'caregiver_gamification_screen.dart'; // Your detail screen

class CaregiverGamificationLandingScreen extends StatelessWidget {
  final List<Map<String, dynamic>> patients = [
    {
      'name': 'Homer Simpson',
      'level': 4,
      'xp': 450,
      'streak': '3 days',
      'badges': 3,
      'lastActive': 'Today',
    },
    {
      'name': 'Maggie Simpson',
      'level': 2,
      'xp': 120,
      'streak': '1 day',
      'badges': 1,
      'lastActive': 'Yesterday',
    },
    {
      'name': 'Bart Simpson',
      'level': 3,
      'xp': 310,
      'streak': '2 days',
      'badges': 2,
      'lastActive': 'Today',
    },
  ];

  CaregiverGamificationLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Engagement'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CaregiverGamificationScreen(patientName: patient['name']),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Level: ${patient['level']}  |  XP: ${patient['xp']}'),
                    Text('Streak: ${patient['streak']}  |  Badges: ${patient['badges']}'),
                    Text('Last Active: ${patient['lastActive']}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
