import 'package:flutter/material.dart';

class CancelScreen extends StatelessWidget {
  const CancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CareConnect"),
        centerTitle: true,
        backgroundColor: const Color(0xFF14366E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              "SOS Request Cancelled",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Your caregiver has not been alerted."),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14366E),
                foregroundColor: Colors.white,
              ),
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
