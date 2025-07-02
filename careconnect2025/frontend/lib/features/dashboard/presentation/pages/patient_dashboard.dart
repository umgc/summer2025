import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  Map<String, dynamic>? patient;
  List<Map<String, dynamic>> caregivers = [];
  bool loading = true;
  String? error;

  // Mood and pain selection (UI only)
  String? selectedMood;
  String? selectedPain;

  @override
  void initState() {
    super.initState();
    fetchPatientAndCaregivers();
  }

  Future<void> fetchPatientAndCaregivers() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final int? patientId = user?.patientId ?? user?.id;
      if (patientId == null) {
        setState(() {
          error = 'User not logged in.';
          loading = false;
        });
        return;
      }

      // Fetch patient details
      final patientRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}patients/$patientId'),
        headers: {'Accept': 'application/json'},
      );
      if (patientRes.statusCode != 200) {
        setState(() {
          error = 'Failed to load patient details';
          loading = false;
        });
        return;
      }
      patient = json.decode(patientRes.body);

      // Fetch caregivers
      final caregiversRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}patients/$patientId/caregivers'),
        headers: {'Accept': 'application/json'},
      );
      if (caregiversRes.statusCode != 200) {
        setState(() {
          error = 'Failed to load caregivers';
          loading = false;
        });
        return;
      }
      caregivers = List<Map<String, dynamic>>.from(
        json.decode(caregiversRes.body),
      );

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF14366E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${greeting()}, ${patient?['firstName'] ?? ''}!',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF14366E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "How are you feeling today?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMoodSelector(),
                            const SizedBox(height: 16),
                            const Text(
                              "How is your pain today?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPainSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "My Caregivers",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14366E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...caregivers.map(_buildCaregiverCard).toList(),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF14366E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                context.go('/tasks/today');
                              },
                              child: const Text('View Today\'s Tasks'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              // SOS call logic placeholder
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('SOS Call initiated!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone, size: 32),
                            label: const Text('SOS'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Angry'},
      {'icon': Icons.sentiment_dissatisfied, 'label': 'Sad'},
      {'icon': Icons.sentiment_neutral, 'label': 'Tired'},
      {'icon': Icons.sentiment_very_satisfied, 'label': 'Happy'},
      {'icon': Icons.sentiment_satisfied, 'label': 'Neutral'},
      {'icon': Icons.sentiment_satisfied_alt, 'label': 'Fearful'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: moods.map((mood) {
          final isSelected = selectedMood == mood['label'];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMood = mood['label'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: const Color(0xFF14366E), width: 2)
                    : null,
              ),
              child: Column(
                children: [
                  Icon(
                    mood['icon'] as IconData,
                    size: 32,
                    color: const Color(0xFF14366E),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood['label'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPainSelector() {
    final pains = [
      {'icon': Icons.sentiment_very_satisfied, 'label': 'No Pain'},
      {'icon': Icons.sentiment_satisfied, 'label': 'Mild'},
      {'icon': Icons.sentiment_neutral, 'label': 'Moderate'},
      {'icon': Icons.sentiment_dissatisfied, 'label': 'Severe'},
      {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Worst'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pains.map((pain) {
          final isSelected = selectedPain == pain['label'];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPain = pain['label'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: Column(
                children: [
                  Icon(
                    pain['icon'] as IconData,
                    size: 32,
                    color: Colors.red[700],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pain['label'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCaregiverCard(Map<String, dynamic> caregiver) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: const NetworkImage(
            'https://randomuser.me/api/portraits/lego/2.jpg',
          ), // Placeholder
        ),
        title: Text(
          '${caregiver['firstName']} ${caregiver['lastName']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${caregiver['phone'] ?? 'N/A'}'),
            Text('Email: ${caregiver['email'] ?? 'N/A'}'),
            if (caregiver['professional'] != null)
              Text(
                'Experience: ${caregiver['professional']['yearsExperience']} yrs',
              ),
            if (caregiver['caregiverType'] != null)
              Text('Type: ${caregiver['caregiverType']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF14366E)),
          onSelected: (value) async {
            final phone = caregiver['phone'];
            final email = caregiver['email'];
            if (value == 'call' && phone != null) {
              final uri = Uri(scheme: 'tel', path: phone);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            } else if (value == 'email' && email != null) {
              final uri = Uri(
                scheme: 'mailto',
                path: email,
                queryParameters: {
                  'subject': 'CareConnect Inquiry',
                  'body': 'Hello...',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not launch email client.'),
                  ),
                );
              }
            } else if (value == 'sms' && phone != null) {
              final uri = Uri(scheme: 'sms', path: phone);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            } else if (value == 'details') {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    '${caregiver['firstName']} ${caregiver['lastName']}',
                  ),
                  content: Text(
                    'Email: $email\nPhone: $phone\nType: ${caregiver['caregiverType']}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'call', child: Text('Call')),
            const PopupMenuItem(value: 'email', child: Text('Email')),
            const PopupMenuItem(value: 'sms', child: Text('Send SMS')),
            const PopupMenuItem(value: 'details', child: Text('View Details')),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF14366E)),
            child: const Text(
              'Patient Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/dashboard/patient');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Task Scheduling'),
            onTap: () {
              Navigator.pop(context);
              context.go('/taskscheduling');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat & Calls'),
            onTap: () {
              Navigator.pop(context);
              context.go('/chatandcalls');
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('AI Assistant'),
            onTap: () {
              Navigator.pop(context);
              context.go('/aiassistant');
            },
          ),
          ListTile(
            leading: const Icon(Icons.watch),
            title: const Text('Fitbit Integration'),
            onTap: () {
              Navigator.pop(context);
              context.go('/fitbit');
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Emergency SOS'),
            onTap: () {
              Navigator.pop(context);
              context.go('/sos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Subscribe'),
            onTap: () {
              Navigator.pop(context);
              context.go('/select-package');
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Achievements'),
            onTap: () {
              Navigator.pop(context);
              context.go('/gamification');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
