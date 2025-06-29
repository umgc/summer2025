import 'package:flutter/material.dart';

class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Management'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'This is the Schedule Management screen.\n Screen is in Progress !😊',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
