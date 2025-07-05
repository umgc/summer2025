import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "About",
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
              "About DeepTrain",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Empowering Professionals with AI-Driven Learning",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            isMobile
                ? Column(
                    children: [
                      _aboutImage(),
                      const SizedBox(height: 24),
                      _aboutDescription(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _aboutDescription()),
                      const SizedBox(width: 40),
                      Expanded(child: _aboutImage()),
                    ],
                  ),
            const SizedBox(height: 60),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 40),
            const Text(
              "Our Mission",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "DeepTrain's mission is to deliver the future of learning — personalized, data-driven, and highly engaging training experiences for every professional, team, and organization.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 40),
            const Text(
              "Our Values",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _valuesList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _aboutImage() {
    return Image.asset(
      'assets/images/DeepTrainHero.webp',
      height: 500,
      fit: BoxFit.cover,
    );
  }

  Widget _aboutDescription() {
    return const Text(
      "Founded in 2025, DeepTrain is the leader in immersive AI-driven training solutions. "
      "Our platform helps modern learners gain skills faster, apply knowledge in real-world scenarios, "
      "and achieve professional certifications with confidence. We combine proven learning science with "
      "cutting-edge artificial intelligence to transform education for individuals and teams worldwide.",
      style: TextStyle(fontSize: 16, color: Colors.black87),
      textAlign: TextAlign.justify,
    );
  }

  Widget _valuesList() {
    final values = [
      {"title": "Innovation", "description": "Constantly pushing the boundaries of technology and learning."},
      {"title": "Integrity", "description": "Building trust through transparency and responsibility."},
      {"title": "Collaboration", "description": "Empowering teams to learn, grow, and succeed together."},
      {"title": "Excellence", "description": "Delivering high-quality experiences and measurable results."},
    ];

    return Column(
      children: values
          .map(
            (v) => ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF6366F1)),
              title: Text(v["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(v["description"]!),
            ),
          )
          .toList(),
    );
  }
}
