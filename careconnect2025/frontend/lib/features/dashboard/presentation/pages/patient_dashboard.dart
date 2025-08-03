/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/ai_chat_improved.dart';
import '../../../../widgets/family_member_card.dart';
import '../../../../widgets/add_family_member_dialog.dart';
import '../../../../widgets/responsive_container.dart';
import 'package:care_connect_app/services/communication_service.dart';

import '../../../calls/presentation/pages/pages/callRequestService.dart';
import '../../../calls/presentation/pages/pages/navigation_helpers.dart';

class PatientDashboard extends StatefulWidget {
  final int? userId;
  final String patientName;
  const PatientDashboard({super.key, this.userId, required this.patientName});

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
    if (widget.userId != null) {
      listenForIncomingCall(widget.userId.toString());

    }
  }
  //Listen for Firestore call documents with status 'incoming'
  void listenForIncomingCall(String userId) {
    FirebaseFirestore.instance
        .collection('calls')
        .where('callee', isEqualTo: userId)
        .where('status', isEqualTo: 'incoming')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final callData = snapshot.docs.first.data();
        final callerId = callData['caller'] ?? '';
        final roomId = callData['roomId'] ?? '';
        showIncomingCallDialog(callerId, roomId, userId);
      }
    });
  }

  // Dialog asking the patient to accept the incoming call
  void showIncomingCallDialog(String callerId, String roomId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: Text('Caregiver is calling you (ID: $callerId)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToCallPage(
                context: context,

                userId: userId,

                displayName: widget.patientName, userRole: '', roomId: '',
              );
            },
            child: const Text('Accept'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchPatientAndCaregivers() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final int? patientId = user?.patientId;
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
      final userId = widget.userId ?? user?.patientId ?? 1;

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
        final userId = widget.userId ?? user?.patientId ?? 1;

        print('🔍 Adding family member for userId: $userId');
        print('🔍 Family member data: $result');

        final response = await ApiService.addFamilyMember(userId, result);

        print('🔍 Add family member response: ${response.statusCode}');
        print('🔍 Add family member body: ${response.body}');

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Family member added successfully!'),
                backgroundColor: AppTheme.success,
                duration: const Duration(seconds: 2),
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
              backgroundColor: AppTheme.error,
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBarHelper.createAppBar(context, title: 'Patient Dashboard'),
      drawer: const CommonDrawer(currentRoute: '/dashboard'),
      // Add floating action button for AI Chat
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.chat_bubble_outline),
        onPressed: () {
          final double sheetHeight = MediaQuery.of(context).size.height * 0.75;
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            builder: (context) => SizedBox(
              height: sheetHeight,
              child: const AIChat(role: 'patient', isModal: true),
            ),
          );
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : SafeArea(
              child: SingleChildScrollView(
                child: ResponsiveContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${greeting()} ${patient?['firstName'] ?? 'Patient'}!',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'How are you feeling today?',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      _buildMoodSelector(),
                      const SizedBox(height: 16),

                      Text(
                        'How is your pain today?',
                        style: theme.textTheme.titleMedium,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
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
                              backgroundColor: AppTheme.success,
                              foregroundColor: theme.colorScheme.onPrimary,
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
                      Text(
                        'Your Caregivers',
                        style: theme.textTheme.titleMedium,
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
                            // Use emergency number for SOS
                            CommunicationService.makePhoneCall('911', context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('SOS Call initiated!'),
                                backgroundColor: Colors.red,
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
    final caregiverId = caregiver['id'] ?? 'caregiver-unknown';
    final caregiverName = '${caregiver['firstName'] ?? 'First'} ${caregiver['lastName'] ?? 'Last'}';
    final patientId = patient?['id']?.toString() ?? 'patient-unknown';
    final patientName = '${patient?['firstName'] ?? 'First'} ${patient?['lastName'] ?? 'Last'}';
    final roomId = 'room-$caregiverId';
    final displayName = patientName;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.shade900),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          tooltip: 'Call $caregiverName',
          onPressed: () {
            // Trigger navigateToCallPage directly when phone icon is pressed
            navigateToCallPage(
              context: context,
              userRole: 'patient', // User role (patient)
              userId: patientId,   // Patient ID
              roomId: roomId,      // Room ID (for unique call session)
              displayName: displayName, // Patient's name to display during the call
            );
          },
        ),
        title: Text(
          caregiverName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: Available', style: TextStyle(color: Colors.black)),
            Text(
              'Last Interaction: ${caregiver['lastSeen'] ?? 'Recently'}',
              style: TextStyle(color: Colors.black),
            ),
            if (caregiver['phone'] != null)
              Text('Phone: ${caregiver['phone']}', style: TextStyle(color: Colors.black)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            final phone = caregiver['phone'];
            final email = caregiver['email'];

            if (value == 'call' || value == 'videocall') {
              final caregiverId = caregiver['id'] ?? 'caregiver-unknown';
              final patientId = patient?['id']?.toString() ?? 'patient-unknown';
              final roomId = 'room-$caregiverId';
              final patientName = '${patient?['firstName'] ?? 'First'} ${patient?['lastName'] ?? 'Last'}';

              sendCallRequest(
                fromUserId: patientId,
                toUserId: caregiverId,
                roomId: roomId,
              );
              navigateToCallPage(
                context: context,
                userRole: 'patient',
                userId: patientId,
                roomId: roomId,
                displayName: displayName,
              );
            } else if (value == 'email') {
              final uri = Uri(
                scheme: 'mailto',
                path: email,
                queryParameters: {
                  'subject': 'CareConnect Inquiry',
                  'body': 'Hello $caregiverName,\n\nI’d like to connect with you.',
                },
              );
              // Uncomment to launch email client
              // if (await canLaunchUrl(uri)) {
              //   await launchUrl(uri);
              // } else {
              //   if (!context.mounted) return;
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('Could not launch email client.')),
              //   );
              // }
            } else if (value == 'sms' && phone != null) {
              _showSendMessageDialog(context, caregiver);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'call', child: Text('Call')),
            PopupMenuItem(value: 'videocall', child: Text('Video Call')),
            PopupMenuItem(value: 'email', child: Text('Email')),
            PopupMenuItem(value: 'sms', child: Text('Send SMS')),
          ],
        ),
      ),
    );
  }


  // Add this method to handle sending messages
  void _showSendMessageDialog(
    BuildContext context,
    Map<String, dynamic> caregiver,
  ) {
    final TextEditingController messageController = TextEditingController();
    final String name = '${caregiver['firstName']} ${caregiver['lastName']}';
    final String phone = caregiver['phone'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send message to $name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Write your message here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Use CommunicationService for SMS
                CommunicationService.sendSMS(
                  phone,
                  context,
                  message: messageController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
*/


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';  // Import for URL Launcher (commented out for phone call)
import '../../../../widgets/ai_chat_improved.dart';
import '../../../../widgets/family_member_card.dart';
import '../../../../widgets/add_family_member_dialog.dart';
import '../../../../widgets/responsive_container.dart';
import 'package:care_connect_app/services/communication_service.dart';

import '../../../calls/presentation/pages/pages/callRequestService.dart';
import '../../../calls/presentation/pages/pages/navigation_helpers.dart';

class PatientDashboard extends StatefulWidget {
  final int? userId;
  final String patientName;
  const PatientDashboard({super.key, this.userId, required this.patientName});

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
    if (widget.userId != null) {
      listenForIncomingCall(widget.userId.toString());
    }
  }


  // Greeting method based on time of day
  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  // Listen for Firestore call documents with status 'incoming'
  void listenForIncomingCall(String userId) {
    FirebaseFirestore.instance
        .collection('calls')
        .where('callee', isEqualTo: userId)
        .where('status', isEqualTo: 'incoming')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final callData = snapshot.docs.first.data();
        final callerId = callData['caller'] ?? '';
        final roomId = callData['roomId'] ?? '';
        showIncomingCallDialog(callerId, roomId, userId);
      }
    });
  }

  // Dialog asking the patient to accept the incoming call
  void showIncomingCallDialog(String callerId, String roomId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: Text('Caregiver is calling you (ID: $callerId)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToCallPage(
                context: context,
                userId: userId,
                displayName: widget.patientName,
                userRole: '', // You can adjust based on user role
                roomId: roomId,
              );
            },
            child: const Text('Accept'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  // Fetch Patient and Caregivers
  Future<void> fetchPatientAndCaregivers() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final int? patientId = user?.patientId;
      if (patientId == null) {
        setState(() {
          error = 'User not logged in.';
          loading = false;
        });
        return;
      }

      // Fetch patient details
      final authHeaders = await ApiService.getAuthHeaders();
      final patientRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}patients/$patientId'),
        headers: authHeaders,
      );

      if (patientRes.statusCode != 200) {
        setState(() {
          error = 'Failed to load patient details (${patientRes.statusCode}): ${patientRes.body}';
          loading = false;
        });
        return;
      }
      patient = json.decode(patientRes.body);

      // Fetch caregivers
      final caregiversRes = await http.get(
        Uri.parse('${ApiConstants.baseUrl}patients/$patientId/caregivers'),
        headers: authHeaders,
      );

      if (caregiversRes.statusCode != 200) {
        setState(() {
          error = 'Failed to load caregivers (${caregiversRes.statusCode}): ${caregiversRes.body}';
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

  // Load Family Members
  Future<void> _loadFamilyMembers() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final userId = widget.userId ?? user?.patientId ?? 1;

      final response = await ApiService.getFamilyMembers(userId);

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            familyMembers = List<Map<String, dynamic>>.from(data);
            isLoading = false;
            error = null;
          });
        } else {
          setState(() {
            error = 'Failed to load family members: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        error = 'Error loading family members: $e';
        isLoading = false;
      });
    }
  }

  // Navigate to the Call Page
  void navigateToCallPage({
    required BuildContext context,
    required String userRole,
    required String userId,
    required String roomId,
    required String displayName,
  }) {
    final encodedUserId = Uri.encodeComponent(userId);
    final encodedRoomId = Uri.encodeComponent(roomId);
    final encodedDisplayName = Uri.encodeComponent(displayName);

    final path = '/call-page/$userRole/$encodedUserId/$encodedRoomId/$encodedDisplayName';
    print("Navigating to: $path"); // Optional debug
    context.go(path); // This is how navigation is handled via GoRouter
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBarHelper.createAppBar(context, title: 'Patient Dashboard'),
      drawer: const CommonDrawer(currentRoute: '/dashboard'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and mood/pain selectors
                Text(
                  '${greeting()} ${patient?['firstName'] ?? 'Patient'}!',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'How are you feeling today?',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                _buildMoodSelector(),
                const SizedBox(height: 16),
                Text(
                  'How is your pain today?',
                  style: theme.textTheme.titleMedium,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
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
                        backgroundColor: AppTheme.success,
                        foregroundColor: theme.colorScheme.onPrimary,
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
                Text(
                  'Your Caregivers',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ...caregivers.map(
                      (caregiver) => _buildCaregiverCard(caregiver),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mood and pain selection
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

  // Pain level selection
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

  // Save Mood and Pain Status
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

  Widget _buildCaregiverCard(Map<String, dynamic> caregiver) {
    final caregiverId = caregiver['id'] ?? 'caregiver-unknown';
    final caregiverName = '${caregiver['firstName'] ?? 'First'} ${caregiver['lastName'] ?? 'Last'}';
    final patientId = patient?['id']?.toString() ?? 'patient-unknown';
    final patientName = '${patient?['firstName'] ?? 'First'} ${patient?['lastName'] ?? 'Last'}';
    final roomId = 'room-$caregiverId';
    final displayName = patientName;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.shade900),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          tooltip: 'Call $caregiverName',
          onPressed: () {
            // Trigger navigateToCallPage directly when phone icon is pressed
            navigateToCallPage(
              context: context,
              userRole: 'patient', // User role (patient)
              userId: patientId,   // Patient ID
              roomId: roomId,      // Room ID (for unique call session)
              displayName: displayName, // Patient's name to display during the call
            );
          },
        ),
        title: Text(
          caregiverName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: Available', style: TextStyle(color: Colors.black)),
            Text(
              'Last Interaction: ${caregiver['lastSeen'] ?? 'Recently'}',
              style: TextStyle(color: Colors.black),
            ),
            if (caregiver['phone'] != null)
              Text('Phone: ${caregiver['phone']}', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
