import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/ai_chat.dart';
import '../../../../widgets/family_member_card.dart';
import '../../../../widgets/add_family_member_dialog.dart';

class PatientDashboard extends StatefulWidget {
  final int? userId;
  const PatientDashboard({super.key, this.userId});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  Map<String, dynamic>? patient;
  List<Map<String, dynamic>> caregivers = [];
  List<Map<String, dynamic>> familyMembers = [];
  bool loading = true;
  bool isLoading = false;
  String? error;

  // Mood and pain selection (UI only)
  String? selectedMood;
  String? selectedPain;

  bool _isSavingMoodPain = false;
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    fetchPatientAndCaregivers();
    _loadFamilyMembers();
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

  Future<void> _loadFamilyMembers() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final userId = widget.userId ?? user?.patientId ?? user?.id ?? 1;

      print('🔍 Loading family members for userId: $userId');

      final response = await ApiService.getFamilyMembers(userId);

      print('🔍 Family members response: ${response.statusCode}');
      print('🔍 Family members body: ${response.body}');

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            familyMembers = List<Map<String, dynamic>>.from(data);
            isLoading = false;
            error = null;
          });
          print(
            '🔍 Family members loaded successfully: ${familyMembers.length} members',
          );
        } else {
          setState(() {
            error = 'Failed to load family members: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('🔍 Error loading family members: $e');
      if (mounted) {
        setState(() {
          error = 'Error loading family members: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addFamilyMember() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddFamilyMemberDialog(),
    );

    if (result != null) {
      try {
        // Show loading message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adding family member...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        final user = Provider.of<UserProvider>(context, listen: false).user;
        final userId = widget.userId ?? user?.patientId ?? user?.id ?? 1;

        print('🔍 Adding family member for userId: $userId');
        print('🔍 Family member data: $result');

        final response = await ApiService.addFamilyMember(userId, result);

        print('🔍 Add family member response: ${response.statusCode}');
        print('🔍 Add family member body: ${response.body}');

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Family member added successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Force refresh the list
          await _loadFamilyMembers();
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ?? 'Failed to add family member',
          );
        }
      } catch (e) {
        print('🔍 Error adding family member: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
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
                        const SizedBox(height: 16),

                        const Text(
                          'How is your pain today?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildPainSelector(),

                        // Save button (show when both are selected)
                        if (_showSaveButton) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _isSavingMoodPain
                                  ? null
                                  : _saveMoodAndPain,
                              icon: _isSavingMoodPain
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                _isSavingMoodPain
                                    ? 'Saving...'
                                    : 'Save Today\'s Status',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],

                        const Divider(height: 30, thickness: 2),

                        // Caregivers section
                        const Text(
                          'Your Caregivers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...caregivers.map(
                          (caregiver) => _buildCaregiverCard(caregiver),
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 30, thickness: 2),

                        // Family Members section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Family Members',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _addFamilyMember,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Family Member'),
                                ),
                              ],
                            ),
                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (error != null)
                              Text(
                                'Error: $error',
                                style: const TextStyle(color: Colors.red),
                              )
                            else if (familyMembers.isEmpty)
                              const Text('No family members added yet')
                            else
                              ...familyMembers.map(
                                (f) => FamilyMemberCard(
                                  firstName: f['firstName'] ?? '',
                                  lastName: f['lastName'] ?? '',
                                  relationship: f['relationship'] ?? '',
                                  phone: f['phone'] ?? '',
                                  email: f['email'] ?? '',
                                  lastInteraction:
                                      f['lastSeen'] ?? 'Not available',
                                ),
                              ),
                          ],
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

  void _checkSaveButtonVisibility() {
    setState(() {
      _showSaveButton = selectedMood != null && selectedPain != null;
    });
  }

  Future<void> _saveMoodAndPain() async {
    if (selectedMood == null || selectedPain == null) return;

    setState(() {
      _isSavingMoodPain = true;
    });

    try {
      // Convert mood to number value
      final moodValue = _getMoodValueFromLabel(selectedMood!);
      final painValue = _getPainLevelFromLabel(selectedPain!);

      final response = await ApiService.submitMoodAndPainLog(
        moodValue: moodValue,
        painValue: painValue,
        note: 'Daily mood and pain check-in',
        timestamp: DateTime.now(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mood and pain levels saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Reset selections after saving
          setState(() {
            selectedMood = null;
            selectedPain = null;
            _showSaveButton = false;
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to save mood and pain data',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSavingMoodPain = false;
      });
    }
  }

  int _getMoodValueFromLabel(String mood) {
    switch (mood.toLowerCase()) {
      case 'angry':
        return 1;
      case 'sad':
        return 2;
      case 'tired':
        return 3;
      case 'fearful':
        return 4;
      case 'neutral':
        return 5;
      case 'happy':
        return 6;
      default:
        return 5; // Default to neutral
    }
  }

  int _getPainLevelFromLabel(String label) {
    if (label.startsWith('1')) return 1;
    if (label.startsWith('2')) return 2;
    if (label.startsWith('3')) return 3;
    if (label.startsWith('4')) return 4;
    if (label.startsWith('5')) return 5;
    return 1; // Default
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
              _checkSaveButtonVisibility(); // Add this line
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
            _checkSaveButtonVisibility(); // Add this line
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
            {
              'icon': Icons.watch,
              'title': 'Wearables',
              'route': '/wearables',
            },
            {
              'icon': Icons.home_outlined,
              'title': 'Home Monitoring',
              'route': '/home-monitoring',
            },
            {
              'icon': Icons.devices,
              'title': 'Smart Devices',
              'route': '/smart-devices',
            },
            {
              'icon': Icons.medication,
              'title': 'Medication Management',
              'route': '/medication',
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
                    context.go('/social-feed');
                  } else if (route == '/analytics') {
                    final user = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).user;
                    final patientId =
                        user?.patientId ?? user?.id ?? widget.userId ?? 1;
                    context.go('$route?patientId=$patientId');
                  } else if (route == '/wearables') {
                    context.push(route);
                  } else if (route == '/home-monitoring') {
                    context.push(route);
                  } else if (route == '/smart-devices') {
                    context.push(route);
                  } else if (route == '/medication') {
                    context.push(route);
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
