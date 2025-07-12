import 'package:flutter/material.dart';

class KpiDashboardScreen extends StatelessWidget {
  const KpiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // 👈 shows back arrow if possible
        title: const Text('KPI Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Live KPIs', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            _KpiCard(title: 'CPI (Cost Performance Index)', value: '1.13'),
            _KpiCard(title: 'SPI (Schedule Performance Index)', value: '0.97'),
            _KpiCard(title: 'Accuracy Rate', value: '89.5%'),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.trending_up),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
