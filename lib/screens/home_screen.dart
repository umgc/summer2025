import 'package:deeptrainfront/screens/about_screen.dart';
import 'package:deeptrainfront/screens/contact_screen.dart';
import 'package:deeptrainfront/screens/pricing_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/auth/login_screen.dart';
import '/auth/register_screen.dart';
import '/screens/features_screen.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildAppBar(context, isMobile),
      ),
      body: isMobile ? _buildMobileLayout(context) : _buildWideLayout(context),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isMobile) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 24,
      title: Row(
        children: [
          const Text(
            'DeepTrain',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
              fontSize: 22,
            ),
          ),
          const Spacer(),
          kIsWeb && !isMobile
              ? Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navLink(context, 'Features'),
                      _navLink(context, 'Pricing'),
                      _navLink(context, 'About'),
                      _navLink(context, 'Contact'),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.push('/login');
          },
          child: const Text(
            'Log In',
            style: TextStyle(color: Color(0xFF6366F1)),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Using context.go() for consistency with GoRouter
            context.go('/signUp');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("Get Started →"),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _navLink(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          switch (title) {
            case 'Features':
              context.go('/features'); // Using context.go() for consistency
              break;
            case 'Pricing':
              context.go('/pricing'); // Using context.go() for consistency
              break;
            case 'About':
              context.go('/about'); // Using context.go() for consistency
              break;
            case 'Contact':
              context.go('/contact'); // Using context.go() for consistency
              break;
          }
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: const Color(0xFFFAFAF9),
                padding: const EdgeInsets.fromLTRB(24, 120, 24, 20),
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/images/deeptrain_animation.json',
                      height: 180,
                      repeat: true,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Unlock Your Potential\nwith ",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: "AI-Driven Training",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Transform your learning journey with personalized AI-powered education and cutting-edge tools for modern professionals.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Using context.go() for consistency with GoRouter
                        context.go('/signUp');
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Get Started"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color(0xFFFAFAF9),
            padding: const EdgeInsets.fromLTRB(70, 200, 70, 60),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Unlock Your Potential\nwith ",
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "AI-Driven Training",
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Transform your learning journey with personalized AI-powered education and cutting-edge tools for modern professionals.",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Using context.go() for consistency with GoRouter
                          context.go('/signUp');
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Get Started"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  child: Lottie.asset(
                    'assets/images/deeptrain_animation.json',
                    height: 360,
                    repeat: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFF5F5F4),
            child: _buildFeaturesSection(),
          ),
          Container(
            color: const Color(0xFFF0F0EF),
            child: _buildTestimonialSection(),
          ),
          _buildFooter(context), // FIX: Pass context here
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Powerful Features for Modern Learning",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Discover the tools and capabilities that make DeepTrain the\nultimate platform for AI-driven education and professional development.",
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
                children:
                    [
                          _featureCard(
                            Icons.psychology,
                            "AI-Powered Learning Paths",
                            "Personalized curriculum that adapts to your learning style, pace, and goals using advanced machine learning algorithms.",
                          ),
                          _featureCard(
                            Icons.trending_up,
                            "Real-Time Progress Tracking",
                            "Monitor your advancement with detailed analytics, performance metrics, and intelligent insights to optimize your learning journey.",
                          ),
                          _featureCard(
                            Icons.groups,
                            "Seamless Team Integration",
                            "Collaborate effectively with team members, share progress, and learn together in a unified development environment.",
                          ),
                        ]
                        .map(
                          (child) => SizedBox(
                            width: constraints.maxWidth / columnCount - 24,
                            child: child,
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String description) {
    return Card(
      elevation: 2,
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildTestimonialSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 80, 50, 100),
      child: Column(
        children: [
          const Text(
            "What Our Users Say",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Join thousands of professionals who have accelerated their\ncareers with DeepTrain's AI-powered learning platform.",
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
                children:
                    [
                          _testimonialCard(
                            quote:
                                "DeepTrain transformed how I approach learning new technologies. The AI-powered paths are incredibly intuitive and effective.",
                            name: "Sarah Chen",
                            role: "Senior Developer",
                          ),
                          _testimonialCard(
                            quote:
                                "The real-time progress tracking keeps our entire team aligned and motivated. Best investment we've made in team development.",
                            name: "Marcus Rodriguez",
                            role: "Tech Lead",
                          ),
                          _testimonialCard(
                            quote:
                                "Seamless integration with our workflow. DeepTrain makes continuous learning feel natural and engaging for everyone.",
                            name: "Emily Watson",
                            role: "Product Manager",
                          ),
                        ]
                        .map(
                          (child) => SizedBox(
                            width: constraints.maxWidth / columnCount - 24,
                            child: child,
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _testimonialCard({
    required String quote,
    required String name,
    required String role,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // Ensure card has a background color
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.format_quote, size: 40, color: Color(0xFF6366F1)),
            const SizedBox(height: 16),
            Text(
              '"$quote"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(role, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MODIFIED: _buildFooter now accepts BuildContext
  Widget _buildFooter(BuildContext context) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'DeepTrain',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Empowering professionals with AI-driven learning\nexperiences and cutting-edge development tools for the future of work.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Quick Links',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Removed 'const' from TextButton and its child Text widgets
                    TextButton(
                      onPressed: () => context.go('/about'),
                      child: const Text(
                        'About',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/contact'),
                      child: const Text(
                        'Contact',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/pricing'),
                      child: const Text(
                        'Pricing',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Privacy Policy'),
                            content: const Text(
                              'Your privacy matters to us. DeepTrain collects minimal data to personalize your learning experience and improve our services. We never share your personal information with third parties without your consent.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Terms of Service'),
                            content: const Text(
                              'By using DeepTrain, you agree to our Terms of Service. These terms outline your rights and responsibilities, acceptable use of the platform, and our commitment to providing a secure and effective learning environment. Continued use signifies your acceptance.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            '© 2025 DeepTrain. All rights reserved.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
