import 'package:flutter/material.dart';

class HealthCareNotesScreen extends StatelessWidget {
  const HealthCareNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Care Notes'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(

        child: Text(
          'This is the Health Care notes screen. \n All the documents pertaining to patients will be here. \n\n Screen is in Progress !😊',
          style: TextStyle(
              fontSize: 18,),
        ),
      ),
    );
  }
}
