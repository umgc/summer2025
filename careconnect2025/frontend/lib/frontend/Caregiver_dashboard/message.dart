import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Message Screen',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,

      ),
      body: Center(child: Text('Message Screen is in Progress !😊')),
    );
  }
}
