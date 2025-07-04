import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/patient_model.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/config/constants/api_constants.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaregiverDashboard extends StatefulWidget {
  final int caregiverId;
  const CaregiverDashboard({super.key, this.caregiverId = 1});

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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}caregivers/${user.caregiverId}/patients',
        ),
      );
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
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}analytics/vitals?patientId=$patientId&days=7',
        ),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Caregiver Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Caregiver', style: TextStyle(color: Colors.white70)),
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
              leading: const Icon(Icons.people),
              title: const Text('Social Network'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString('userId');
                Navigator.pop(context);
                if (userId != null) {
                  context.go('/social-feed?userId=$userId');
                } else {
                  context.go('/social-feed?userId=1');
                }
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
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                context.go('/');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
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
                      const Text(
                        'No patients found',
                        style: TextStyle(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.blue.shade900,
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
                                      const Icon(Icons.more_vert),
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
                                          padding: EdgeInsets.only(bottom: 12),
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

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _dashboardButton(
                                        context,
                                        Icons.view_list,
                                        'View Logs',
                                        () => ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'View Logs feature coming soon!',
                                                ),
                                              ),
                                            ),
                                      ),
                                      _dashboardButton(
                                        context,
                                        Icons.call,
                                        'Call',
                                        () => ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Calling ${patient.phone} (simulated)',
                                                ),
                                              ),
                                            ),
                                      ),
                                      _dashboardButton(
                                        context,
                                        Icons.message,
                                        'Message',
                                        () => ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Message feature coming soon!',
                                                ),
                                              ),
                                            ),
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.smart_toy),
        label: const Text('Ask AI'),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI Assistant feature coming soon!')),
        ),
      ),
    );
  }

  Widget _dashboardButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
