import 'package:flutter/material.dart';
import 'package:care_connect/Caregiver_dashboard/patient_model.dart';
import 'package:care_connect/Schedule_Management/custom_task_scheduling.dart';
import 'package:care_connect/Schedule_Management/pre_defined_care_templates.dart';
import 'package:care_connect/Schedule_Management/caregiver_shift_scheduling.dart';

class ScheduleManagementScreen extends StatefulWidget {
  final Future<List<Patient>> futurePatients;

  const ScheduleManagementScreen({required this.futurePatients, super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  late Future<List<Patient>> futurePatients;

  @override
  void initState() {
    super.initState();
    futurePatients = widget.futurePatients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Management'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        // Schedule Management screen will show a list of patients, and allow caregivers
        // to manage their schedules by using buttons to add pre-defined care templates,
        // create custom task scheduling, choose how the patient will be notified
        // (push, email, and/or SMS), and set reminders and escalation rules. caregivers
        // can also set their shift schedules and availability.
        children: [
          // Display a button to Enter Caregiver Shift Scheduling
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const CaregiverShiftSchedulingScreen(),
                ));
              },
              child: const Text('Enter Caregiver Shift Scheduling'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Patient>>(
              future: futurePatients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading patients.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No patients assigned.'));
                }

                final patients = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      itemCount: patients.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 25),
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.indigo, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.person, size: 40, color: Colors.indigo),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(patient.name,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text('Age: ${patient.age}', style: const TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.pushNamed(context, '/edit');
                                        } else if (value == 'archive') {
                                          Navigator.pushNamed(context, '/archive');
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => PreDefinedCareTemplatesScreen()));
                                    },
                                      child: const Text('Add Pre-defined Care Template'),
                                    ),
                                  ],
                                ),
                                Row(children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => CustomTaskSchedulingScreen()));
                                    },
                                    child: const Text('Add Custom Task'),
                                  ),
                                ],)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
