import 'package:flutter/material.dart';

class TeleHealthBridgeScreen extends StatelessWidget {
  const TeleHealthBridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TeleHealth Bridge'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(

        child: Text(
          'This is the TeleHealth Bridge screen.  \n\n Screen is in Progress !😊',
          style: TextStyle(
            fontSize: 18,),
        ),
      ),
    );
  }
}
