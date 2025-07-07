import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/ai_chat.dart';

class PatientDashboard extends StatefulWidget {
  final int? userId;
  const PatientDashboard({super.key, this.userId});

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
      final authHeaders = await ApiService.getAuthHeaders();
      print(
        'DEBUG: Making patient API call with headers: ${authHeaders.keys.join(', ')}',
      );

      final patientRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}patients/$patientId'),
        headers: authHeaders,
      );
      print('DEBUG: Patient API response status: ${patientRes.statusCode}');
      print('DEBUG: Patient API response body: ${patientRes.body}');

      if (patientRes.statusCode != 200) {
        setState(() {
          error =
              'Failed to load patient details (${patientRes.statusCode}): ${patientRes.body}';
          loading = false;
        });
        return;
      }
      patient = json.decode(patientRes.body);

      // Fetch caregivers
      print(
        'DEBUG: Making caregivers API call with headers: ${authHeaders.keys.join(', ')}',
      );

      final caregiversRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}patients/$patientId/caregivers'),
        headers: authHeaders,
      );
      print(
        'DEBUG: Caregivers API response status: ${caregiversRes.statusCode}',
      );
      print('DEBUG: Caregivers API response body: ${caregiversRes.body}');

      if (caregiversRes.statusCode != 200) {
        setState(() {
          error =
              'Failed to load caregivers (${caregiversRes.statusCode}): ${caregiversRes.body}';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greeting()} ${patient?['firstName'] ?? 'Patient'}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'How are you feeling today?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildMoodSelector(),
                        const Divider(height: 30, thickness: 2),

                        const Text(
                          'How is your pain today?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildPainSelector(),
                        const Divider(height: 30, thickness: 2),

                        ...caregivers.map(
                          (caregiver) => _buildCaregiverCard(caregiver),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () => context.go('/tasks/today'),
                          child: const Text(
                            'View Today\'s Task',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('SOS Call initiated!'),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.phone_in_talk_rounded,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'SOS CALL',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Add some bottom padding to ensure content isn't hidden behind AI chat
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
          // AI Chat Widget
          const AIChat(role: 'patient'),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'emoji': '😡', 'label': 'Angry'},
      {'emoji': '😐', 'label': 'Sad'},
      {'emoji': '😫', 'label': 'Tired'},
      {'emoji': '😨', 'label': 'Fearful'},
      {'emoji': '😑', 'label': 'Neutral'},
      {'emoji': '😊', 'label': 'Happy'},
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.blue.shade900, width: 2)
                          : null,
                    ),
                    child: Text(
                      mood['emoji'] as String,
                      style: const TextStyle(fontSize: 28),
                    ),
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
      {'emoji': '😀', 'label': '1\nNo Pain'},
      {'emoji': '🙂', 'label': '2\nMild'},
      {'emoji': '😐', 'label': '3\nModerate'},
      {'emoji': '😣', 'label': '4\nSevere'},
      {'emoji': '😭', 'label': '5\nWorst Pain'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: pains.map((pain) {
        final isSelected = selectedPain == pain['label'];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPain = pain['label'] as String;
            });
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.red, width: 2)
                      : null,
                ),
                child: Text(
                  pain['emoji'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pain['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCaregiverCard(Map<String, dynamic> caregiver) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.shade900),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Text("D")),
        title: Text(
          '${caregiver['firstName'] ?? ''} ${caregiver['lastName'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: Available'),
            Text('Last Interaction: ${caregiver['lastSeen'] ?? 'Recently'}'),
            if (caregiver['phone'] != null)
              Text('Phone: ${caregiver['phone']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
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
                if (!mounted) return;
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
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'call', child: Text('Call')),
            const PopupMenuItem(value: 'email', child: Text('Email')),
            const PopupMenuItem(value: 'sms', child: Text('Send SMS')),
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
            decoration: BoxDecoration(color: Colors.blue.shade700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30),
                ),
                const SizedBox(height: 8),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.user;
                    final patientName =
                        user?.name ??
                        (patient?['firstName'] != null &&
                                patient?['lastName'] != null
                            ? '${patient!['firstName']} ${patient!['lastName']}'
                            : 'Patient');

                    return Text(
                      patientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const Text('Patient', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ...[
            {
              'icon': Icons.group,
              'title': 'Caregiver Management',
              'route': null,
            },
            {
              'icon': Icons.video_camera_front,
              'title': 'Virtual Check-In',
              'route': null,
            },
            {
              'icon': Icons.medical_services,
              'title': 'TeleHealth',
              'route': null,
            },
            {
              'icon': Icons.note_alt,
              'title': 'Health Care Note',
              'route': null,
            },
            {
              'icon': Icons.analytics,
              'title': 'Analytics',
              'route': '/analytics',
            },
            {
              'icon': Icons.emoji_events,
              'title': 'Gamification',
              'route': '/gamification',
            },
            {
              'icon': Icons.people_alt,
              'title': 'Social Network',
              'route': '/social-feed',
            },
            {'icon': Icons.settings, 'title': 'Settings', 'route': '/settings'},
            {
              'icon': Icons.help_outline,
              'title': 'Help & Support',
              'route': null,
            },
          ].map((item) {
            return ListTile(
              leading: Icon(item['icon'] as IconData),
              title: Text(item['title'] as String),
              onTap: () {
                Navigator.pop(context);
                final route = item['route'] as String?;
                if (route != null) {
                  if (route == '/social-feed') {
                    context.go('$route?userId=${widget.userId ?? 1}');
                  } else if (route == '/analytics') {
                    final user = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).user;
                    final patientId =
                        user?.patientId ?? user?.id ?? widget.userId ?? 1;
                    context.go('$route?patientId=$patientId');
                  } else {
                    context.go(route);
                  }
                }
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
