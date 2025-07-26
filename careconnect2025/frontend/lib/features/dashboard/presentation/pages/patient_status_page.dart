import 'package:flutter/material.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';
import 'package:care_connect_app/features/analytics/models/dashboard_analytics_model.dart';
import 'package:care_connect_app/widgets/responsive_container.dart';
import 'package:care_connect_app/widgets/enhanced_patient_notes_widget.dart';

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

  Widget _buildInfoSection(
    String title,
    IconData icon,
    List<Widget> children, {
    Widget? customContent,
  }) {
    return Card(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent,
            ] else if (children.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...children,
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'No information available',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.visible,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
    );
  }

  Widget _buildMedicalInfoSection() {
    final hasAllergies = patient!.allergies?.isNotEmpty == true;
    final hasVitalConditions = patient!.vitalConditions?.isNotEmpty == true;

    // Safely extract medications from various possible sources
    String? medications;

    // Try to get medications from vitalConditions
    if (hasVitalConditions &&
        patient!.vitalConditions!.containsKey('medications')) {
      final medicationsValue = patient!.vitalConditions!['medications'];
      if (medicationsValue != null && medicationsValue.toString().isNotEmpty) {
        medications = medicationsValue.toString();
      }
    }

    // Try to get medications from patient direct property if available
    // This would be if the patient model has a medications field directly

    final hasMedications = medications?.isNotEmpty == true;

    // Check if we have any medical information to display
    if (!hasAllergies && !hasVitalConditions && !hasMedications) {
      return _buildInfoSection(
        'Medical Information',
        Icons.medical_information,
        [],
      );
    }

    final children = <Widget>[];

    // Add allergies (always show)
    final allergiesText = hasAllergies
        ? (patient!.allergies is List
              ? (patient!.allergies as List).join(', ')
              : patient!.allergies.toString())
        : 'No allergies listed';
    children.add(_buildInfoRow('Allergies', allergiesText));

    // Add medications if available
    if (hasMedications) {
      children.add(_buildInfoRow('Current Medications', medications!));
    }

    // Add vital signs if available
    if (hasVitalConditions) {
      final vitals = patient!.vitalConditions!;

      // Safely check and add each vital sign
      if (vitals.containsKey('heartRate') && vitals['heartRate'] != null) {
        final heartRate = vitals['heartRate'].toString();
        if (heartRate.isNotEmpty && heartRate != 'null') {
          children.add(_buildInfoRow('Heart Rate', '$heartRate bpm'));
        }
      }

      if (vitals.containsKey('bloodPressure') &&
          vitals['bloodPressure'] != null) {
        final bloodPressure = vitals['bloodPressure'].toString();
        if (bloodPressure.isNotEmpty && bloodPressure != 'null') {
          children.add(_buildInfoRow('Blood Pressure', '$bloodPressure mmHg'));
        }
      }

      if (vitals.containsKey('temperature') && vitals['temperature'] != null) {
        final temperature = vitals['temperature'].toString();
        if (temperature.isNotEmpty && temperature != 'null') {
          children.add(_buildInfoRow('Temperature', '$temperature°F'));
        }
      }

      if (vitals.containsKey('oxygenSaturation') &&
          vitals['oxygenSaturation'] != null) {
        final oxygenSat = vitals['oxygenSaturation'].toString();
        if (oxygenSat.isNotEmpty && oxygenSat != 'null') {
          children.add(_buildInfoRow('Oxygen Saturation', '$oxygenSat%'));
        }
      }

      // Add any other vital conditions that might be present
      vitals.forEach((key, value) {
        if (value != null &&
            value.toString().isNotEmpty &&
            value.toString() != 'null' &&
            ![
              'heartRate',
              'bloodPressure',
              'temperature',
              'oxygenSaturation',
              'medications',
            ].contains(key)) {
          // Format the key to be more readable
          final formattedKey = key
              .replaceAllMapped(
                RegExp(r'([A-Z])'),
                (match) => ' ${match.group(1)}',
              )
              .toLowerCase()
              .split(' ')
              .map(
                (word) => word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1)}'
                    : '',
              )
              .join(' ');

          children.add(_buildInfoRow(formattedKey, value.toString()));
        }
      });
    }

    return _buildInfoSection(
      'Medical Information',
      Icons.medical_information,
      children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient header - responsive layout
            isMobile
                ? Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          (patient!.profileImageUrl ??
                              'https://randomuser.me/api/portraits/men/32.jpg'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${patient!.firstName} ${patient!.lastName}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          if (patient!.dob.isNotEmpty)
                            Text(
                              'Age: ${_calculateAge(patient!.dob)}',
                              textAlign: TextAlign.center,
                            ),
                          if (patient!.phone.isNotEmpty)
                            Text(
                              'Phone: ${patient!.phone}',
                              textAlign: TextAlign.center,
                            ),
                          if (patient!.email.isNotEmpty)
                            Text(
                              'Email: ${patient!.email}',
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(
                          (patient!.profileImageUrl ??
                              'https://randomuser.me/api/portraits/men/32.jpg'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
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
                            if (patient!.dob.isNotEmpty)
                              Text('Age: ${_calculateAge(patient!.dob)}'),
                            if (patient!.phone.isNotEmpty)
                              Text('Phone: ${patient!.phone}'),
                            if (patient!.email.isNotEmpty)
                              Text('Email: ${patient!.email}'),
                          ],
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            // Content sections with responsive layout
            isMobile
                ? Column(
                    children: [
                      // Patient Information Section
                      _buildInfoSection('Patient Information', Icons.person, [
                        if (patient!.relationship.isNotEmpty)
                          _buildInfoRow('Relationship', patient!.relationship),
                        if (patient!.gender != null &&
                            patient!.gender!.isNotEmpty)
                          _buildInfoRow('Gender', patient!.gender!),
                        if (patient!.dob.isNotEmpty)
                          _buildInfoRow('Date of Birth', patient!.dob),
                      ]),
                      const SizedBox(height: 16),
                      // Address Section
                      if (patient!.address != null) ...[
                        _buildInfoSection('Address', Icons.location_on, [
                          if (patient!.address!.line1?.isNotEmpty == true)
                            _buildInfoRow(
                              'Address',
                              '${patient!.address!.line1}${patient!.address!.line2?.isNotEmpty == true ? '\n${patient!.address!.line2}' : ''}',
                            ),
                          if (patient!.address!.city?.isNotEmpty == true)
                            _buildInfoRow('City', patient!.address!.city!),
                          if (patient!.address!.state?.isNotEmpty == true)
                            _buildInfoRow('State', patient!.address!.state!),
                          if (patient!.address!.zip?.isNotEmpty == true)
                            _buildInfoRow('ZIP Code', patient!.address!.zip!),
                        ]),
                        const SizedBox(height: 16),
                      ],
                      // Medical Information Section
                      _buildMedicalInfoSection(),
                      const SizedBox(height: 16),
                      // Vitals Summary Section
                      _buildInfoSection(
                        'Vitals Summary (Past 7 Days)',
                        Icons.favorite,
                        [],
                        customContent: buildVitalsSummary(vitals),
                      ),
                      const SizedBox(height: 16),
                      // Medical Notes Section - Full width on mobile
                      EnhancedPatientNotesWidget(
                        patientId: patient!.id,
                        showCompactView: false,
                        initialItemCount: 3,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Patient Information Section
                      _buildInfoSection('Patient Information', Icons.person, [
                        if (patient!.relationship.isNotEmpty)
                          _buildInfoRow('Relationship', patient!.relationship),
                        if (patient!.gender != null &&
                            patient!.gender!.isNotEmpty)
                          _buildInfoRow('Gender', patient!.gender!),
                        if (patient!.dob.isNotEmpty)
                          _buildInfoRow('Date of Birth', patient!.dob),
                      ]),
                      const SizedBox(height: 24),
                      // Address Section
                      if (patient!.address != null) ...[
                        _buildInfoSection('Address', Icons.location_on, [
                          if (patient!.address!.line1?.isNotEmpty == true)
                            _buildInfoRow(
                              'Address',
                              '${patient!.address!.line1}${patient!.address!.line2?.isNotEmpty == true ? '\n${patient!.address!.line2}' : ''}',
                            ),
                          if (patient!.address!.city?.isNotEmpty == true)
                            _buildInfoRow('City', patient!.address!.city!),
                          if (patient!.address!.state?.isNotEmpty == true)
                            _buildInfoRow('State', patient!.address!.state!),
                          if (patient!.address!.zip?.isNotEmpty == true)
                            _buildInfoRow('ZIP Code', patient!.address!.zip!),
                        ]),
                        const SizedBox(height: 24),
                      ],
                      // Medical Information Section
                      _buildMedicalInfoSection(),
                      const SizedBox(height: 24),
                      // Vitals Summary Section
                      _buildInfoSection(
                        'Vitals Summary (Past 7 Days)',
                        Icons.favorite,
                        [],
                        customContent: buildVitalsSummary(vitals),
                      ),
                      const SizedBox(height: 24),
                      // Medical Notes Section
                      EnhancedPatientNotesWidget(
                        patientId: patient!.id,
                        showCompactView: false,
                        initialItemCount: 3,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildVitalsSummary(DashboardAnalytics? vitals) {
    if (vitals == null) {
      return Text(
        'No vitals data available for summary.',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vitals.avgHeartRate != null)
          _buildVitalRow(
            'Heart Rate',
            '${vitals.avgHeartRate!.toStringAsFixed(1)} bpm',
          ),
        if (vitals.avgSpo2 != null)
          _buildVitalRow('SpO₂', '${vitals.avgSpo2!.toStringAsFixed(1)}%'),
        if (vitals.avgSystolic != null)
          _buildVitalRow(
            'Systolic BP',
            '${vitals.avgSystolic!.toStringAsFixed(1)} mmHg',
          ),
        if (vitals.avgDiastolic != null)
          _buildVitalRow(
            'Diastolic BP',
            '${vitals.avgDiastolic!.toStringAsFixed(1)} mmHg',
          ),
        if (vitals.avgWeight != null)
          _buildVitalRow(
            'Weight',
            '${vitals.avgWeight!.toStringAsFixed(1)} lbs',
          ),
        if (vitals.adherenceRate != null)
          _buildVitalRow(
            'Adherence Rate',
            '${vitals.adherenceRate!.toStringAsFixed(1)}%',
          ),
      ],
    );
  }

  Widget _buildVitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
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
