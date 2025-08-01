import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: isMobile ? _buildDrawer(context) : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('DeepTrain', style: TextStyle(color: Colors.black)),
        actions: [
          const Icon(Icons.notifications, color: Colors.black),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            onSelected: (value) {
              switch (value) {
                case 'account':
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Account Details'),
                      content: const Text('Email: user@example.com\nRole: Admin'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                  break;
                case 'password':
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Change Password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Current Password'),
                          ),
                          TextField(
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'New Password'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password change requested')),
                            );
                          },
                          child: const Text('Change'),
                        )
                      ],
                    ),
                  );
                  break;
                case 'notifications':
                  showDialog(
                    context: context,
                    builder: (_) => StatefulBuilder(
                      builder: (context, setState) {
                        bool notificationsEnabled = true;
                        return AlertDialog(
                          title: const Text('Notifications'),
                          content: SwitchListTile(
                            title: const Text('Enable Notifications'),
                            value: notificationsEnabled,
                            onChanged: (val) {
                              setState(() => notificationsEnabled = val);
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            )
                          ],
                        );
                      },
                    ),
                  );
                  break;
                case 'privacy':
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Privacy & Terms'),
                      content: const Text(
                        'By using this app you agree to our Privacy Policy and Terms of Service.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                  break;
                case 'logout':
                  GoRouter.of(context).go('/');
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'account',
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.person),
                  title: Text('Account Details'),
                ),
              ),
              PopupMenuItem(
                value: 'password',
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.lock),
                  title: Text('Change Password'),
                ),
              ),
              PopupMenuItem(
                value: 'notifications',
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.notifications),
                  title: Text('Notifications'),
                ),
              ),
              PopupMenuItem(
                value: 'privacy',
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Privacy & Terms'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) _buildDrawer(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildRevenueSection(),
                  const SizedBox(height: 20),
                  _buildAvailableDriversTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final router = GoRouter.of(context);
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        children: [
          const DrawerHeader(
            child: Text("Designer Panel", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Scenario Designer"),
             onTap: () => router.push('/scenario'),
          ),
          ListTile(
            leading: const Icon(Icons.drive_eta),
            title: const Text("Simulator"),
             onTap: () => router.push('/simulator'),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("KPI Dashboard"),
            onTap: () => router.push('/Kpi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard("Scenario Completed", "7", Colors.orange),
        _buildStatCard("Simulation Average", "87", Colors.green),
        _buildStatCard("Simulation in Progress", "3", Colors.red),
        _buildStatCard("Scheduled Simulations", "13", Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kpi Data Chart", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 500,
                              getTitlesWidget: (value, _) {
                                return Text('10', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Jan');
                                  case 1:
                                    return const Text('Feb');
                                  case 2:
                                    return const Text('Mar');
                                  case 3:
                                    return const Text('Apr');
                                  case 4:
                                    return const Text('May');
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.blue,
                            spots: const [
                              FlSpot(0, 1123),
                              FlSpot(1, 989),
                              FlSpot(2, 1005),
                              FlSpot(3, 1540),
                              FlSpot(4, 1110),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Today's Scores", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("%100", style: TextStyle(color: Colors.red, fontSize: 16)),
                  SizedBox(height: 8),
                  Text("Last 7 days"),
                  Text("%87", style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                  Text("Last 30 days"),
                  Text("%91", style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                  Text("Last 12 months"),
                  Text("%90", style: TextStyle(color: Colors.red)),
                  Text("Last 3 years"),
                  Text("%0", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAvailableDriversTable() {
    final drivers = List.generate(5, (index) => {
      'name': 'John Doe',
      'phone': '1234567890',
      'location': 'New York',
      'Score': '87'
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Simulations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("Name")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Phone")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Location")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Score")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Action")),
                  ],
                ),
                ...drivers.map((driver) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text(driver['name']!)),
                    Padding(padding: const EdgeInsets.all(8), child: Text(driver['phone']!)),
                    Padding(padding: const EdgeInsets.all(8), child: Text(driver['location']!)),
                    Padding(padding: const EdgeInsets.all(8), child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(driver['Score']!)
                      ],
                    )),
                    Padding(padding: const EdgeInsets.all(8), child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Load Scenario"),
                    )),
                  ]
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}