import 'package:flutter/material.dart';

class TrackingAndMonitoringScreen extends StatelessWidget {
  const TrackingAndMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking & Monitoring'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'This is the Tracking & Monitoring screen.\n Screen is in Progress !😊',
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
