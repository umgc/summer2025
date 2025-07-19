import 'dart:convert';

import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../widgets/ai_chat.dart';
import '../../models/patient_model.dart';

class CaregiverDashboard extends StatefulWidget {
  final String userRole;
  final int? patientId;
  final int caregiverId;

  const CaregiverDashboard({
    super.key,
    this.userRole = 'CAREGIVER',
    this.patientId,
    this.caregiverId = 1,
  });

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  List<Patient> patients = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  @override
  void didUpdateWidget(CaregiverDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh patients when widget updates
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) {
        setState(() {
          error = 'User not logged in.';
          loading = false;
        });
        return;
      }
      final response = await ApiService.getCaregiverPatients(
        user.caregiverId ?? 0,
      ).timeout(const Duration(seconds: 180));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          patients = data.map((e) => Patient.fromJson(e)).toList();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load patients';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchPatientVitals(int patientId) async {
    try {
      final response = await ApiService.getPatientVitals(
        patientId,
      ).timeout(const Duration(seconds: 180));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Failed to fetch vitals: ${response.body}');
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  String formatDate(String dob) {
    try {
      final date = DateTime.parse(dob);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dob;
    }
  }

  Widget buildVitalsSummary(List<Map<String, dynamic>> vitals) {
    if (vitals.isEmpty) {
      return const SizedBox.shrink();
    }

    double avg(List<num> values) =>
        values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

    final heartRates = vitals.map((e) => (e['heartRate'] as num)).toList();
    final spo2s = vitals.map((e) => (e['spo2'] as num)).toList();
    final systolics = vitals.map((e) => (e['systolic'] as num)).toList();
    final diastolics = vitals.map((e) => (e['diastolic'] as num)).toList();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, size: 16, color: Colors.red.shade600),
              const SizedBox(width: 4),
              const Text(
                'Recent Vitals (7 days)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HR: ${avg(heartRates).toStringAsFixed(0)} bpm',
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                'SpO₂: ${avg(spo2s).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                'BP: ${avg(systolics).toStringAsFixed(0)}/${avg(diastolics).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFamilyMember =
        Provider.of<UserProvider>(context).user?.role == 'FAMILY_MEMBER';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Caregiver Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      // Replace the existing drawer in the build method with this:
      drawer: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          final isFamilyMember = user?.role == 'FAMILY_MEMBER';

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
                      Text(
                        user?.name ?? 'User Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isFamilyMember ? 'Family Member' : 'Caregiver',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Gamification'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/gamification');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Subscription Management'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/subscription-management');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(isFamilyMember ? 'My Patients' : 'Patients'),
                  onTap: () {
                    Navigator.pop(context);
                    if (isFamilyMember) {
                      context.go('/family-patients');
                    } else {
                      context.go('/patients');
                    }
                  },
                ),
                // Only show these options for caregivers
                if (!isFamilyMember) ...[
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Register Patient'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/register/patient');
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
                ],
                // Show read-only badge for family members
                if (isFamilyMember)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Read-only access',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/settings');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!context.mounted) return;
                    context.go('/');
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text(error!))
                  : patients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isFamilyMember
                                ? 'No accessible patients'
                                : 'No patients found',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first patient to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/register/patient'),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Register New Patient'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
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
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Add patient button at the top
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/register/patient'),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Register New Patient'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        // Patient list
                        Expanded(
                          child: ListView.builder(
                            itemCount: patients.length,
                            itemBuilder: (context, index) {
                              final patient = patients[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.blue.shade900),
                                ),
                                margin: const EdgeInsets.only(bottom: 20),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            child: Text(
                                              (patient.firstName.isNotEmpty
                                                      ? patient.firstName[0]
                                                      : 'P')
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${patient.firstName} ${patient.lastName}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'DOB: ${formatDate(patient.dob)}',
                                                ),
                                                Text('Phone: ${patient.phone}'),
                                                Text(
                                                  'Relationship: ${patient.relationship}',
                                                ),
                                              ],
                                            ),
                                          ),

                                          /* //Adding the PopupMenuButton
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                Navigator.pushNamed(context, '/edit', arguments: patient.linkId);
                                              } else if (value == 'archive') {
                                                Navigator.pushNamed(context, '/archive', arguments: patient.linkId);
                                              } else if (value == 'inviteFamilyMember') {
                                                Navigator.pushNamed(context, '/invite_Family_Member');
                                              } else if (value == 'MediaScreen') {
                                                Navigator.pushNamed(context, '/MediaScreen');
                                              }
                                            },
                                            itemBuilder: (BuildContext context) => const [
                                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                                              PopupMenuItem(value: 'archive', child: Text('Archive')),
                                              PopupMenuItem(value: 'inviteFamilyMember', child: Text('Invite Family Member')),
                                              PopupMenuItem(value: 'MediaScreen', child: Text('Media Upload')),
                                            ],
                                          ), */
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Vitals summary for this patient
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                        future: fetchPatientVitals(patient.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: LinearProgressIndicator(),
                                            );
                                          }
                                          if (snapshot.hasData &&
                                              snapshot.data!.isNotEmpty) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: buildVitalsSummary(
                                                snapshot.data!,
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),

                                      // Responsive button layout
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          // If width is too small, use 2x2 grid
                                          if (constraints.maxWidth < 380) {
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _dashboardButton(
                                                        context,
                                                        Icons.analytics,
                                                        'Analytics',
                                                        () => context.go(
                                                          '/analytics?patientId=${patient.id}',
                                                        ),
                                                        isAnalytics: true,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: _dashboardButton(
                                                        context,
                                                        Icons.view_list,
                                                        'View Logs',
                                                        () =>
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'View Logs feature coming soon!',
                                                                ),
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _dashboardButton(
                                                        context,
                                                        Icons.call,
                                                        'Call',
                                                        () {
                                                          final String
                                                          patientName =
                                                              '${patient.firstName} ${patient.lastName}';
                                                          final String roomId =
                                                              'room-${patient.id}'; // or any room ID logic you use

                                                          context.go(
                                                            '/mobile-web-call?patientName=${Uri.encodeComponent(patientName)}&roomId=${Uri.encodeComponent(roomId)}',
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: _dashboardButton(
                                                        context,
                                                        Icons.message,
                                                        'Message',
                                                        () =>
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Message feature coming soon!',
                                                                ),
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          } else {
                                            // Use single row for wider screens
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: _dashboardButton(
                                                    context,
                                                    Icons.analytics,
                                                    'Analytics',
                                                    () => context.go(
                                                      '/analytics?patientId=${patient.id}',
                                                    ),
                                                    isAnalytics: true,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: _dashboardButton(
                                                    context,
                                                    Icons.view_list,
                                                    'View Logs',
                                                    () =>
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'View Logs feature coming soon!',
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: _dashboardButton(
                                                    context,
                                                    Icons.call,
                                                    'Call',
                                                    () {
                                                      final String patientName =
                                                          '${patient.firstName} ${patient.lastName}';
                                                      final String roomId =
                                                          'room-${patient.id}'; // or any room ID logic you use

                                                      context.go(
                                                        '/mobile-web-call?patientName=${Uri.encodeComponent(patientName)}&roomId=${Uri.encodeComponent(roomId)}',
                                                      );
                                                    },
                                                  ),
                                                ),

                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: _dashboardButton(
                                                    context,
                                                    Icons.message,
                                                    'Message',
                                                    () =>
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Message feature coming soon!',
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // AI Chat Widget
          const AIChat(role: 'caregiver'),
        ],
      ),
    );
  }

  Widget _dashboardButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isAnalytics = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16), // Reduced from 18 to 16
      label: Text(
        label,
        style: const TextStyle(fontSize: 11), // Reduced from 12 to 11
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isAnalytics
            ? Colors.green.shade700
            : Colors.blue.shade900,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ), // Reduced padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(0, 32), // Set minimum height
      ),
    );
  }
}
