import 'package:flutter/material.dart';

class SOSNotificationScreen extends StatelessWidget {
  const SOSNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Notification Screen'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(

        child: Text(
          'This is SOS Notification screen.  \n\n Screen is in Progress !😊',
          style: TextStyle(
            fontSize: 18,),
        ),
      ),
    );
  }
}
