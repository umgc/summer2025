import 'package:flutter/material.dart';
import '/auth/register_screen.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Features",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "DeepTrain Features",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Explore the cutting-edge capabilities that make DeepTrain the best AI-powered training platform for modern professionals.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  int columnCount = constraints.maxWidth > 1000
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _featureCard(
                        icon: Icons.psychology,
                        title: "AI-Driven Personalization",
                        description:
                            "Our adaptive engine tailors courses and scenarios to each learner’s unique needs, boosting engagement and retention.",
                      ),
                      _featureCard(
                        icon: Icons.show_chart,
                        title: "Real-Time Progress Tracking",
                        description:
                            "Monitor your growth with interactive dashboards, actionable feedback, and predictive analytics.",
                      ),
                      _featureCard(
                        icon: Icons.group,
                        title: "Team Collaboration",
                        description:
                            "Empower your teams to learn together, track shared milestones, and encourage a culture of continuous improvement.",
                      ),
                      _featureCard(
                        icon: Icons.extension,
                        title: "Interactive Scenario Simulation",
                        description:
                            "Engage in realistic branching scenarios to develop decision-making skills and problem-solving confidence.",
                      ),
                      _featureCard(
                        icon: Icons.verified,
                        title: "Certifications & Badges",
                        description:
                            "Gain recognized certificates and digital badges that showcase your achievements and skills.",
                      ),
                      _featureCard(
                        icon: Icons.lock,
                        title: "Enterprise-Grade Security",
                        description:
                            "Protect data with best-in-class security, encryption, and compliance for peace of mind.",
                      ),
                    ].map((child) => SizedBox(width: constraints.maxWidth / columnCount - 24, child: child)).toList(),
                  );
                },
              ),
              const SizedBox(height: 60),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 40),
              const Text(
                "Ready to unlock your team's potential?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                 Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const RegisterScreen()),
);

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Get Started Now"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF6366F1),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
