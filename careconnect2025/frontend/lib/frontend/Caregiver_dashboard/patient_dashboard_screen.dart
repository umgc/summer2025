import 'package:flutter/material.dart';
import 'AddPatients.dart';
import '../Hamburger_Menu_Items/HealthCareNotes.dart';
import '../Hamburger_Menu_Items/NotificationSetting.dart';
import '../Hamburger_Menu_Items/SOSNotification.dart';
import '../Hamburger_Menu_Items/TeleHealthBridge.dart';
import '../Hamburger_Menu_Items/TrackingAndMonitoring.dart';
import 'ViewLogs.dart';
import 'askAI.dart';
import 'call.dart';           // Make sure this is the call.dart with CallScreen having both roomName and patientName
import 'message.dart';
import 'patient_model.dart';
import 'patient_mock_service.dart';
import 'edit.dart';
import 'archive.dart';
import '../Hamburger_Menu_Items/Billing Management.dart';
import '../Hamburger_Menu_Items/Schedule Management.dart';
import 'invite_Family_Member.dart';

class PatientDashboardScreen extends StatefulWidget {
  final String caregiverEmail;

  const PatientDashboardScreen({required this.caregiverEmail, super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  late Future<List<Patient>> futurePatients;

  @override
  void initState() {
    super.initState();
    futurePatients = fetchPatientsForCaregiver(widget.caregiverEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caregiver Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('Main Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Billing and Subscription Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillingAndSubscriptionManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScheduleManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Tracking & Monitoring'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrackingAndMonitoringScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Notification Setting'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationSettingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('TeleHealth Bridge'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeleHealthBridgeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Health Care Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HealthCareNotesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notification_important),
              title: const Text('SOS Notification'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SOSNotificationScreen()),
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddPatientScreen()));
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.indigo, width: 3),
                    ),
                    child: const Center(child: Icon(Icons.add, size: 40, color: Colors.indigo)),
                  ),
                ),
              ],
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
                                const SizedBox(height: 8),
                                Text('Last Interaction: ${patient.lastInteraction}'),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => ViewLogScreen()));
                                      },
                                      child: const Text('View Logs'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CallScreen(
                                              roomName: "patient_${patient.name.replaceAll(' ', '_')}",
                                              patientName: patient.name,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Call'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => MessageScreen()));
                                      },
                                      child: const Text('Message'),
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
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AskAIScreen()));
          },
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Text(
            'Ask AI',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
