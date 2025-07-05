import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Contact",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Get in Touch with DeepTrain",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "We’d love to hear from you. Fill out the form below, and our team will get back to you shortly.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            isMobile
                ? _buildContactForm(context)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildContactDetails()),
                      const SizedBox(width: 40),
                      Expanded(child: _buildContactForm(context)),
                    ],
                  ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "DeepTrain Headquarters",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("123 AI Learning Lane"),
        Text("Innovation City, Tech State 98765"),
        SizedBox(height: 16),
        Text("Email: support@deeptrain.ai"),
        Text("Phone: +1 (555) 123-4567"),
        SizedBox(height: 24),
        Text(
          "Business Hours",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("Monday - Friday: 9:00 AM - 6:00 PM"),
        Text("Saturday - Sunday: Closed"),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final messageController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Your Name",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: "Your Email",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: messageController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: "Your Message",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // For now, just show a thank-you snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message sent! We will get back to you shortly.')),
            );
            nameController.clear();
            emailController.clear();
            messageController.clear();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Send Message"),
        ),
      ],
    );
  }
}
