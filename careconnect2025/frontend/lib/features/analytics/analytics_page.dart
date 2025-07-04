import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:care_connect_app/config/constants/api_constants.dart';
import 'models/vital_model.dart';
import 'models/dashboard_analytics_model.dart';

class AnalyticsPage extends StatefulWidget {
  final int patientId;
  const AnalyticsPage({super.key, required this.patientId});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Vital> vitals = [];
  DashboardAnalytics? dashboard;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final vitalsResp = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}analytics/vitals?patientId=${widget.patientId}&days=7',
        ),
      );
      final dashboardResp = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}analytics/dashboard?patientId=${widget.patientId}&days=7',
        ),
      );

      if (vitalsResp.statusCode == 200 && dashboardResp.statusCode == 200) {
        final vitalsJson = json.decode(vitalsResp.body) as List;
        final dashboardJson = json.decode(dashboardResp.body);

        setState(() {
          vitals = vitalsJson.map((e) => Vital.fromJson(e)).toList();
          dashboard = DashboardAnalytics.fromJson(dashboardJson);
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch analytics data';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  Future<void> exportFile(String type) async {
    final from = vitals.isNotEmpty ? vitals.first.timestamp : DateTime.now();
    final to = vitals.isNotEmpty ? vitals.last.timestamp : DateTime.now();
    final fromStr = Uri.encodeComponent(from.toIso8601String());
    final toStr = Uri.encodeComponent(to.toIso8601String());
    final url =
        '${ApiConstants.baseUrl}analytics/export/$type?patientId=${widget.patientId}&from=$fromStr&to=$toStr';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget buildChart(
    String title,
    List<FlSpot> spots, {
    double minY = 0,
    double maxY = 200,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= vitals.length) {
                            return const SizedBox();
                          }
                          final date = vitals[idx].timestamp;
                          return Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: Center(child: Text(error!)),
      );
    }

    // Prepare chart data
    List<FlSpot> heartRateSpots = [
      for (int i = 0; i < vitals.length; i++)
        FlSpot(i.toDouble(), vitals[i].heartRate),
    ];
    List<FlSpot> spo2Spots = [
      for (int i = 0; i < vitals.length; i++)
        FlSpot(i.toDouble(), vitals[i].spo2),
    ];
    List<FlSpot> systolicSpots = [
      for (int i = 0; i < vitals.length; i++)
        FlSpot(i.toDouble(), vitals[i].systolic.toDouble()),
    ];
    List<FlSpot> diastolicSpots = [
      for (int i = 0; i < vitals.length; i++)
        FlSpot(i.toDouble(), vitals[i].diastolic.toDouble()),
    ];
    List<FlSpot> weightSpots = [
      for (int i = 0; i < vitals.length; i++)
        FlSpot(i.toDouble(), vitals[i].weight),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => exportFile('pdf'),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Export CSV',
            onPressed: () => exportFile('csv'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (dashboard != null)
            Card(
              color: Colors.blue[50],
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary (${dashboard!.periodStart?.month ?? '?'}/${dashboard!.periodStart?.day ?? '?'} - ${dashboard!.periodEnd?.month ?? '?'}/${dashboard!.periodEnd?.day ?? '?'})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adherence Rate: ${dashboard!.adherenceRate?.toStringAsFixed(1) ?? 'N/A'}%',
                    ),
                    Text(
                      'Avg Heart Rate: ${dashboard!.avgHeartRate?.toStringAsFixed(1) ?? 'N/A'} bpm',
                    ),
                    Text(
                      'Avg SpO₂: ${dashboard!.avgSpo2?.toStringAsFixed(1) ?? 'N/A'}%',
                    ),
                    Text(
                      'Avg Systolic: ${dashboard!.avgSystolic?.toStringAsFixed(1) ?? 'N/A'} mmHg',
                    ),
                    Text(
                      'Avg Diastolic: ${dashboard!.avgDiastolic?.toStringAsFixed(1) ?? 'N/A'} mmHg',
                    ),
                    Text(
                      'Avg Weight: ${dashboard!.avgWeight?.toStringAsFixed(1) ?? 'N/A'} lbs',
                    ),
                  ],
                ),
              ),
            ),
          buildChart('Heart Rate (bpm)', heartRateSpots, minY: 50, maxY: 120),
          buildChart('SpO₂ (%)', spo2Spots, minY: 90, maxY: 100),
          buildChart('Systolic (mmHg)', systolicSpots, minY: 100, maxY: 140),
          buildChart('Diastolic (mmHg)', diastolicSpots, minY: 60, maxY: 100),
          buildChart('Weight (lbs)', weightSpots, minY: 100, maxY: 250),
        ],
      ),
    );
  }
}
