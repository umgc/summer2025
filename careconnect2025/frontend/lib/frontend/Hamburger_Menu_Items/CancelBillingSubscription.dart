import 'package:flutter/material.dart';

class CancelSubscriptionScreen extends StatelessWidget {
  const CancelSubscriptionScreen({super.key});


  //creating the cancellaton confirmation steps
  void _confirmCancellation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Confirm Cancellation",
          style: TextStyle(color: Colors.indigo),
          ),
          content: const Text("Are you sure you want to cancel your subscription?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(ctx).pop(); // Closing dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Subscription has been cancelled."),
                  ),
                );
                },
              child: const Text("Yes, Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
//creating frontend view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cancel Subscription"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "Cancelling your subscription will remove access to premium features.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _confirmCancellation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
                child: const Text(
                  "Cancel My Subscription",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
