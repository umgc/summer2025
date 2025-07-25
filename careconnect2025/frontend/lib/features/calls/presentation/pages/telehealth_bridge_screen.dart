// TelehealthBridgeScreen with Jitsi integration
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'jitsi_meeting_screen.dart';

class TelehealthBridgeScreen extends StatefulWidget {
  const TelehealthBridgeScreen({super.key});

  @override
  State<TelehealthBridgeScreen> createState() => _TelehealthBridgeScreenState();
}

class _TelehealthBridgeScreenState extends State<TelehealthBridgeScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _appointments = [
    {
      'date': DateTime.now(),
      'time': '10:00 AM',
      'with': 'Dr. Smith',
      'room': 'room_dr_smith_1000'
    },
    {
      'date': DateTime.now(),
      'time': '2:00 PM',
      'with': 'Dr. Johnson',
      'room': 'room_dr_johnson_1400'
    },
    {
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': '9:00 AM',
      'with': 'Dr. Williams',
      'room': 'room_dr_williams_0900'
    },
  ];

  List<Map<String, dynamic>> get _filteredAppointments => _appointments
      .where((appt) => isSameDate(appt['date'], _selectedDate))
      .toList();

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildCalendar() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = isSameDate(date, _selectedDate);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade900 : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(DateFormat('d').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCards() {
    if (_filteredAppointments.isEmpty) {
      return const Center(child: Text('No appointments for this day.'));
    }
    return Column(
      children: _filteredAppointments.map((appt) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('Appointment with ${appt['with']}'),
            subtitle: Text(
                '${DateFormat('yMMMd').format(appt['date'])} at ${appt['time']}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JitsiMeetingScreen(roomName: appt['room']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
              ),
              child: const Text('Join'),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telehealth Bridge'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCalendar(),
            const SizedBox(height: 16),
            Expanded(
                child: SingleChildScrollView(child: _buildAppointmentCards())),
          ],
        ),
      ),
    );
  }
}
