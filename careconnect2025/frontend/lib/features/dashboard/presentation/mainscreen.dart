
import '../../dashboard/presentation/sosscreen.dart';
import 'package:flutter/material.dart';

import 'cancelscreen.dart';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule dialog after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEmergencyDialog();
    });
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text("Emergency SOS"),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Are you sure you want to send an alert to your caregiver?\nThey will be notified of your location.",
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CancelScreen()),
              );
            },
            child: Text("Cancel", style: TextStyle(color: Colors.purple)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SosScreen()),
              );
            },
            child: Text("Yes, Send SOS", style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CarConnect"),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text(
          "Emergency screen loaded",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
