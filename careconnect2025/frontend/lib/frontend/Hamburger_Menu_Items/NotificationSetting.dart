import 'package:flutter/material.dart';

class NotificationSettingScreen extends StatelessWidget {
  const NotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Setting '),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(

        child: Text(
          'This is the Notification Setting screen. \nUser will select the Notification Channel. \n\n Screen is in Progress !😊',
          style: TextStyle(
            fontSize: 18,),
        ),
      ),
    );
  }
}
