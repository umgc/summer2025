import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';
import 'package:care_connect_app/features/analytics/models/dashboard_analytics_model.dart';

class PatientStatusPage extends StatefulWidget {
  const PatientStatusPage({super.key});

  @override
  State<PatientStatusPage> createState() => _PatientStatusPageState();
}

class _PatientStatusPageState extends State<PatientStatusPage> {
  Patient? patient;
  DashboardAnalytics? vitals;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
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
      final patientId = user.id;

      // Fetch patient profile
      final authHeaders = await ApiService.getAuthHeaders();
      final profileRes = await http.get(
        Uri.parse('${ApiConstants.users}/$patientId'),
        headers: authHeaders,
      );
      if (profileRes.statusCode != 200) {
        setState(() {
          error = 'Failed to load patient profile';
          loading = false;
        });
        return;
      }
      final patientData = json.decode(profileRes.body);
      patient = Patient.fromJson(patientData);

      // Fetch vitals summary
      final vitalsRes = await http.get(
        Uri.parse(
          '${ApiConstants.analytics}/dashboard?patientId=$patientId&days=7',
        ),
        headers: authHeaders,
      );
      if (vitalsRes.statusCode != 200) {
        setState(() {
          error = 'Failed to load vitals summary';
          loading = false;
        });
        return;
      }
      final vitalsData = json.decode(vitalsRes.body);
      vitals = DashboardAnalytics.fromJson(vitalsData);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Status',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF14366E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
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
            // ... other menu items ...
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : patient == null
          ? const Center(child: Text('No patient data found.'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(
                          (patient!.profileImageUrl ??
                              'https://randomuser.me/api/portraits/men/32.jpg'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${patient!.firstName} ${patient!.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF14366E),
                            ),
                          ),
                          Text('Age: ${_calculateAge(patient!.dob)}'),
                          Text('Phone: ${patient!.phone}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Current Condition',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF14366E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patient!.relationship,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF14366E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${patient!.address?.line1 ?? ''} ${patient!.address?.line2 ?? ''}\n'
                    '${patient!.address?.city ?? ''}, ${patient!.address?.state ?? ''} ${patient!.address?.zip ?? ''}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  buildVitalsSummary(vitals),
                ],
              ),
            ),
    );
  }

  Widget buildVitalsSummary(DashboardAnalytics? vitals) {
    if (vitals == null) {
      return const Text('No vitals data available for summary.');
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vitals Summary (Past 7 Days)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Heart Rate: avg ${vitals.avgHeartRate?.toStringAsFixed(1) ?? 'N/A'} bpm',
            ),
            Text('SpO₂: avg ${vitals.avgSpo2?.toStringAsFixed(1) ?? 'N/A'}%'),
            Text(
              'Blood Pressure (Systolic): avg ${vitals.avgSystolic?.toStringAsFixed(1) ?? 'N/A'} mmHg',
            ),
            Text(
              'Blood Pressure (Diastolic): avg ${vitals.avgDiastolic?.toStringAsFixed(1) ?? 'N/A'} mmHg',
            ),
            Text(
              'Weight: avg ${vitals.avgWeight?.toStringAsFixed(1) ?? 'N/A'} lbs',
            ),
            Text(
              'Adherence Rate: ${vitals.adherenceRate?.toStringAsFixed(1) ?? 'N/A'}%',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(String? dob) {
    if (dob == null) return 0;
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        final birthDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        final today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        return age;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
