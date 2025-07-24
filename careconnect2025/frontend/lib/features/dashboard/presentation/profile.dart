import 'package:flutter/material.dart';

class PatientProfileSheet extends StatelessWidget {
  const PatientProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> patientDetails = {
      'Full Name': 'Jane Doe',
      'Age': '45',
      'Sex': 'Female',
      'Address': '123 Wellness St, Ellicott City, MD',
      'Occupation': 'Teacher',
      'Medications': 'Lisinopril, Metformin',
      'Allergies': 'Penicillin',
      'Primary Care Doctor': 'Dr. John Smith',
      'Primary Caregiver': 'Spouse: Alex Doe',
      'Emergency Contact': 'Alex Doe - (555) 123-4567',
      'Insurance Provider': 'HealthFirst Insurance',
      'Insurance Policy Number': 'HF-987654321',
      'Medical History': 'Hypertension, Type 2 Diabetes',
      'Blood Type': 'O+',
    };

    final name = patientDetails['Full Name'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text('Patient Profile'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Scrollbar(
        thumbVisibility: true,
        radius: const Radius.circular(8),
        thickness: 6,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            buildSectionHeader('🧍 Personal Information'),
            ...fields(patientDetails, ['Age', 'Sex', 'Address', 'Occupation']),

            buildSectionHeader('💊 Medical Information'),
            ...fields(patientDetails, ['Medications', 'Allergies', 'Medical History', 'Blood Type']),

            buildSectionHeader('👩‍⚕️ Care & Contact'),
            ...fields(patientDetails, ['Primary Care Doctor', 'Primary Caregiver', 'Emergency Contact']),

            buildSectionHeader('📋 Insurance'),
            ...fields(patientDetails, ['Insurance Provider', 'Insurance Policy Number']),
          ],
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  List<Widget> fields(Map<String, String> data, List<String> keys) {
    return keys
        .where((key) => data.containsKey(key))
        .map((key) => Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.indigo),
        title: Text(
          key,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        subtitle: Text(
          data[key]!,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    ))
        .toList();
  }
}

