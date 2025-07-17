import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../models/patient_model.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../widgets/ai_chat.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Card(
            child: ListTile(
              title: Text('${patient.firstName} ${patient.lastName}'),
              subtitle: Text('DOB: ${patient.dob}'),
              trailing: ElevatedButton(
                onPressed: () {
                  final patientName = patient.firstName;
                  final roomId =
                      "careconnect_${patientName.replaceAll(' ', '_')}";
                  // Navigate to WebEmotionDetector when the call button is clicked
                  context.go(
                    '/mobile-web-call?patientName=${Uri.encodeComponent(patientName)}&roomId=${Uri.encodeComponent(roomId)}',
                  );
                },
                child: const Text("Start Call"),
              ),
            ),
          );
        },
      ),
    );
  }
}
