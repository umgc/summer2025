import 'package:flutter/material.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pricing",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Choose the Right Plan for Your Team",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Whether you're a solo learner or a growing organization, DeepTrain has flexible pricing to suit your needs.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              LayoutBuilder(builder: (context, constraints) {
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
                    _pricingCard(
                      title: "Starter",
                      price: "\$19/mo",
                      features: [
                        "Access to all basic lessons",
                        "Interactive quizzes",
                        "Limited scenarios",
                        "Email support",
                      ],
                      highlight: false,
                    ),
                    _pricingCard(
                      title: "Professional",
                      price: "\$49/mo",
                      features: [
                        "Everything in Starter",
                        "Unlimited scenarios",
                        "Team collaboration tools",
                        "Priority support",
                      ],
                      highlight: true,
                    ),
                    _pricingCard(
                      title: "Enterprise",
                      price: "Contact Us",
                      features: [
                        "Custom integrations",
                        "Advanced analytics",
                        "Dedicated account manager",
                        "Enterprise-grade security",
                      ],
                      highlight: false,
                    ),
                  ].map((child) => SizedBox(width: constraints.maxWidth / columnCount - 24, child: child)).toList(),
                );
              }),
              const SizedBox(height: 60),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 40),
              const Text(
                "Questions about pricing or custom solutions?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact sales coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Contact Sales"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pricingCard({
    required String title,
    required String price,
    required List<String> features,
    bool highlight = false,
  }) {
    return Card(
      elevation: highlight ? 8 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: highlight ? const Color(0xFF6366F1) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: highlight ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: highlight ? Colors.white : const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map((f) => Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: highlight ? Colors.white : Color(0xFF6366F1), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                  color: highlight ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Add signup or payment action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: highlight ? Colors.white : const Color(0xFF6366F1),
                foregroundColor: highlight ? const Color(0xFF6366F1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}
