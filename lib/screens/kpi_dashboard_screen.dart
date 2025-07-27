import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KpiDashboardScreen extends StatelessWidget {
  const KpiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final correct = extra?['correct'] ?? 0;
    final total = extra?['total'] ?? 0;
    final duration = extra?['duration'] as Duration? ?? Duration.zero;

    final percentage = total > 0 ? (correct / total * 100).toStringAsFixed(1) : "0.0";
    final formattedTime =
        "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('KPI Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text('Simulation Results', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            _KpiCard(title: 'Score Percentage', value: '$percentage%'),
            _KpiCard(title: 'Correct Answers', value: '$correct out of $total'),
            _KpiCard(title: 'Time Taken', value: '$formattedTime (mm:ss)'),
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
        leading: const Icon(Icons.bar_chart),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
