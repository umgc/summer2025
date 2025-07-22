import 'package:flutter/material.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';
import 'package:care_connect_app/features/analytics/models/dashboard_analytics_model.dart';
import 'package:care_connect_app/config/router/app_router.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:care_connect_app/widgets/responsive_container.dart';

class PatientStatusPage extends StatefulWidget {
  final int? patientId;
  const PatientStatusPage({super.key, this.patientId});

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
      // Use the patientId passed to the widget if available,
      // otherwise get it from the current user
      int? patientId;
      final user = Provider.of<UserProvider>(context, listen: false).user;

      if (user == null) {
        setState(() {
          error = 'User not logged in.';
          loading = false;
        });
        return;
      }

      if (widget.patientId != null) {
        patientId = widget.patientId;
        print('🔍 Using patientId from route parameter: $patientId');
      } else {
        patientId = user.patientId;
        print('🔍 Using patientId from user object: $patientId');
      }

      if (patientId == null) {
        setState(() {
          error = 'No patient ID available';
          loading = false;
        });
        return;
      }

      // Determine the appropriate API URL based on user role
      final authHeaders = await ApiService.getAuthHeaders();
      final String apiUrl;

      // If the user is a caregiver, use the caregivers endpoint
      if (user.role.toUpperCase() == 'CAREGIVER' ||
          user.role.toUpperCase() == 'FAMILY_LINK') {
        final caregiverId = user.caregiverId;
        apiUrl =
            '${ApiConstants.baseUrl}caregivers/$caregiverId/patients/$patientId';
        print('🔍 Using caregiver-specific endpoint: $apiUrl');
      } else {
        // If the user is a patient, use the users endpoint
        apiUrl = '${ApiConstants.users}/$patientId';
        print('🔍 Using standard users endpoint: $apiUrl');
      }

      // Fetch patient profile
      final profileRes = await http.get(
        Uri.parse(apiUrl),
        headers: authHeaders,
      );
      if (profileRes.statusCode != 200) {
        setState(() {
          error =
              'Failed to load patient profile. Status: ${profileRes.statusCode}';
          loading = false;
        });
        print('🔍 API Error: ${profileRes.statusCode} - ${profileRes.body}');
        return;
      }

      // Decode the response
      final responseData = json.decode(profileRes.body);
      print('🔍 API Response: $responseData');

      // Extract patient data - handle different response structures
      final Map<String, dynamic> patientData;

      if (user.role.toUpperCase() == 'CAREGIVER' ||
          user.role.toUpperCase() == 'FAMILY_LINK') {
        // For caregiver endpoint, the patient data may be nested
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('patient')) {
          patientData = responseData['patient'] as Map<String, dynamic>;
        } else {
          // If not nested, use the response as is
          patientData = responseData as Map<String, dynamic>;
        }
      } else {
        // For patient/user endpoint, use response directly
        patientData = responseData as Map<String, dynamic>;
      }

      patient = Patient.fromJson(patientData);

      // Fetch vitals summary - always use analytics endpoint
      final vitalsUrl =
          '${ApiConstants.analytics}/dashboard?patientId=$patientId&days=7';
      print('🔍 Fetching vitals from: $vitalsUrl');

      final vitalsRes = await http.get(
        Uri.parse(vitalsUrl),
        headers: authHeaders,
      );

      if (vitalsRes.statusCode != 200) {
        setState(() {
          error =
              'Failed to load vitals summary. Status: ${vitalsRes.statusCode}';
          loading = false;
        });
        print(
          '🔍 Vitals API Error: ${vitalsRes.statusCode} - ${vitalsRes.body}',
        );
        return;
      }

      final vitalsData = json.decode(vitalsRes.body);
      vitals = DashboardAnalytics.fromJson(vitalsData);

      setState(() {
        loading = false;
      });
    } catch (e) {
      print('🔍 Error fetching patient data: $e');
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
        title: Text(
          'Patient Status',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      drawer: const CommonDrawer(currentRoute: '/patient-status'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : patient == null
          ? const Center(child: Text('No patient data found.'))
          : SingleChildScrollView(
              child: ResponsiveContainer(
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text('Age: ${_calculateAge(patient!.dob)}'),
                            Text('Phone: ${patient!.phone}'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Current Condition',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      patient!.relationship,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
