import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final router = GoRouter.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isMobile ? _buildDrawer(router) : null,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        automaticallyImplyLeading: isMobile,
        title: const Text(
          "DeepTrain Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isMobile ? _buildMobileLayout() : _buildWebLayout(router),
    );
  }

  Widget _buildDrawer(GoRouter router) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF6366F1)),
            child: Image(
              image: AssetImage('assets/images/DeepTrain_Logo_small.webp'),
              height: 60,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => router.go('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text("Builder"),
            onTap: () => router.go('/builder'),
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text("Simulator"),
            onTap: () => router.go('/simulator'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text("KPI Dashboard"),
            onTap: () => router.go('/kpi'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log Out"),
            onTap: () => router.go('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard("Tasks Completed", "255"),
          const SizedBox(height: 16),
          _summaryCard("Upcoming Tasks", "67"),
          const SizedBox(height: 16),
          _chartCard(),
          const SizedBox(height: 16),
          _scenariosList(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              height: 80,
              width: 80,
              child: Lottie.asset('assets/images/deeptrain_animation.json'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(GoRouter router) {
    return Row(
      children: [
        Container(
          width: 220,
          color: const Color(0xFF6366F1),
          child: Column(
            children: [
              const DrawerHeader(
                child: Image(
                  image: AssetImage('assets/images/DeepTrain_Logo_small.webp'),
                  height: 60,
                ),
              ),
              ListTile(
                textColor: Colors.white,
                iconColor: Colors.white,
                leading: const Icon(Icons.build),
                title: const Text("Scenario Builder"),
                onTap: () => router.go('/builder'),
              ),
              ListTile(
                textColor: Colors.white,
                iconColor: Colors.white,
                leading: const Icon(Icons.smart_toy),
                title: const Text("Simulator"),
                onTap: () => router.go('/simulator'),
              ),
              ListTile(
                textColor: Colors.white,
                iconColor: Colors.white,
                leading: const Icon(Icons.analytics),
                title: const Text("KPI Dashboard"),
                onTap: () => router.go('/kpi'),
              ),
              const Divider(color: Colors.white),
              ListTile(
                textColor: Colors.white,
                iconColor: Colors.white,
                leading: const Icon(Icons.logout),
                title: const Text("Log Out"),
                onTap: () => router.go('/'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _summaryCard("Tasks Completed", "255")),
                      const SizedBox(width: 12),
                      Expanded(child: _summaryCard("Upcoming Tasks", "67")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _chartCard(),
                  const SizedBox(height: 16),
                  _scenariosList(),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: Lottie.asset('assets/images/deeptrain_animation.json'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, color: Color(0xFF6366F1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: const Color(0xFF6366F1),
                  spots: const [
                    FlSpot(0, 1),
                    FlSpot(1, 2),
                    FlSpot(2, 1.5),
                    FlSpot(3, 3),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scenariosList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Scenarios",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text("Scenario 1"),
              subtitle: Text("Last run: 2 days ago"),
            ),
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text("Scenario 2"),
              subtitle: Text("Last run: 5 days ago"),
            ),
          ],
        ),
      ),
    );
  }
}
