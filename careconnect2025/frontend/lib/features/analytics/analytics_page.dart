import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'models/vital_model.dart';
import 'models/dashboard_analytics_model.dart';
import 'web_utils.dart'
    if (dart.library.html) 'web_utils_web.dart'
    as web_utils;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../widgets/ai_chat.dart';

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
  int selectedDays = 7; // Default to 7 days

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
      final authHeaders = await ApiService.getAuthHeaders();
      final vitalsResp = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}analytics/vitals?patientId=${widget.patientId}&days=$selectedDays',
            ),
            headers: authHeaders,
          )
          .timeout(
            const Duration(seconds: 180),
            onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
          );
      final dashboardResp = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}analytics/dashboard?patientId=${widget.patientId}&days=$selectedDays',
            ),
            headers: authHeaders,
          )
          .timeout(
            const Duration(seconds: 180),
            onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
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
    try {
      if (type == 'csv') {
        await _exportToCsv();
      } else if (type == 'pdf') {
        await _exportToPdf();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type export completed successfully!'),
          backgroundColor: Colors.green.shade600,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _exportToCsv() async {
    // Create CSV content
    StringBuffer csvContent = StringBuffer();
    csvContent.writeln(
      'Date,Heart Rate (bpm),SpO2 (%),Systolic (mmHg),Diastolic (mmHg),Weight (lbs)',
    );

    for (var vital in vitals) {
      csvContent.writeln(
        '${vital.timestamp.toIso8601String()},${vital.heartRate},${vital.spo2},${vital.systolic},${vital.diastolic},${vital.weight}',
      );
    }

    // Add summary data
    csvContent.writeln('');
    csvContent.writeln('Summary Data');
    if (dashboard != null) {
      csvContent.writeln(
        'Adherence Rate,%,${dashboard!.adherenceRate?.toStringAsFixed(1) ?? 'N/A'}',
      );
      csvContent.writeln(
        'Avg Heart Rate,bpm,${dashboard!.avgHeartRate?.toStringAsFixed(1) ?? 'N/A'}',
      );
      csvContent.writeln(
        'Avg SpO2,%,${dashboard!.avgSpo2?.toStringAsFixed(1) ?? 'N/A'}',
      );
      csvContent.writeln(
        'Avg Systolic,mmHg,${dashboard!.avgSystolic?.toStringAsFixed(1) ?? 'N/A'}',
      );
      csvContent.writeln(
        'Avg Diastolic,mmHg,${dashboard!.avgDiastolic?.toStringAsFixed(1) ?? 'N/A'}',
      );
      csvContent.writeln(
        'Avg Weight,lbs,${dashboard!.avgWeight?.toStringAsFixed(1) ?? 'N/A'}',
      );
    }

    final fileName =
        'patient_${widget.patientId}_analytics_${selectedDays}days_${DateTime.now().millisecondsSinceEpoch}.csv';

    if (kIsWeb) {
      final bytes = utf8.encode(csvContent.toString());
      web_utils.downloadFile(fileName, bytes);
    }
  }

  Future<void> _exportToPdf() async {
    // Create a PDF document
    final pdf = pw.Document();

    // Add page to PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'PATIENT ANALYTICS REPORT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Patient ID: ${widget.patientId}'),
              pw.Text('Period: Last $selectedDays days'),
              pw.Text(
                'Generated: ${DateTime.now().toString().substring(0, 19)}',
              ),
              pw.SizedBox(height: 20),

              if (dashboard != null) ...[
                pw.Header(level: 1, child: pw.Text('HEALTH SUMMARY')),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Period: ${dashboard!.periodStart?.month ?? '?'}/${dashboard!.periodStart?.day ?? '?'} - ${dashboard!.periodEnd?.month ?? '?'}/${dashboard!.periodEnd?.day ?? '?'}',
                ),
                pw.Text(
                  'Adherence Rate: ${dashboard!.adherenceRate?.toStringAsFixed(1) ?? 'N/A'}%',
                ),
                pw.Text(
                  'Avg Heart Rate: ${dashboard!.avgHeartRate?.toStringAsFixed(1) ?? 'N/A'} bpm',
                ),
                pw.Text(
                  'Avg SpO₂: ${dashboard!.avgSpo2?.toStringAsFixed(1) ?? 'N/A'}%',
                ),
                pw.Text(
                  'Avg Systolic: ${dashboard!.avgSystolic?.toStringAsFixed(1) ?? 'N/A'} mmHg',
                ),
                pw.Text(
                  'Avg Diastolic: ${dashboard!.avgDiastolic?.toStringAsFixed(1) ?? 'N/A'} mmHg',
                ),
                pw.Text(
                  'Avg Weight: ${dashboard!.avgWeight?.toStringAsFixed(1) ?? 'N/A'} lbs',
                ),
                pw.SizedBox(height: 20),
              ],

              pw.Header(level: 1, child: pw.Text('DETAILED VITALS DATA')),
              pw.SizedBox(height: 10),

              // Create table for vitals data
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Date',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Heart Rate',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'SpO₂',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Blood Pressure',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Weight',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Data rows
                  ...vitals
                      .map(
                        (vital) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                vital.timestamp.toString().substring(0, 10),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('${vital.heartRate} bpm'),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('${vital.spo2}%'),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '${vital.systolic}/${vital.diastolic}',
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('${vital.weight} lbs'),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    final fileName =
        'patient_${widget.patientId}_analytics_${selectedDays}days_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (kIsWeb) {
      final bytes = await pdf.save();
      web_utils.downloadFile(fileName, bytes);
    }
  }

  /*
  // COMMENTED OUT API-BASED EXPORT
  Future<void> exportFileFromAPI(String type) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      final from = vitals.isNotEmpty ? vitals.first.timestamp : DateTime.now();
      final to = vitals.isNotEmpty ? vitals.last.timestamp : DateTime.now();
      final fromStr = Uri.encodeComponent(from.toIso8601String());
      final toStr = Uri.encodeComponent(to.toIso8601String());
      
      final url = '${ApiConstants.baseUrl}analytics/export/$type?patientId=${widget.patientId}&from=$fromStr&to=$toStr';
      
      final response = await http.get(
        Uri.parse(url),
        headers: authHeaders,
      );
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final fileName = 'patient_${widget.patientId}_analytics_${DateTime.now().millisecondsSinceEpoch}.$type';
        
        if (kIsWeb) {
          web_utils.downloadFile(fileName, bytes);
        }
      }
    } catch (e) {
      // Error handling
    }
  }
  */

  void _onFilterChanged(int days) {
    setState(() {
      selectedDays = days;
    });
    fetchAnalytics();
  }

  String _getHealthDataContext() {
    if (vitals.isEmpty && dashboard == null) {
      return "No health data available for analysis.";
    }

    StringBuffer context = StringBuffer();
    context.writeln("PATIENT HEALTH DATA SUMMARY (Last $selectedDays days):");
    context.writeln(
      "Note: Personal identifiers have been removed for privacy.",
    );
    context.writeln("");

    // Add dashboard summary if available
    if (dashboard != null) {
      context.writeln("OVERVIEW METRICS:");
      context.writeln(
        "• Adherence Rate: ${dashboard!.adherenceRate?.toStringAsFixed(1) ?? 'N/A'}%",
      );
      context.writeln(
        "• Average Heart Rate: ${dashboard!.avgHeartRate?.toStringAsFixed(1) ?? 'N/A'} bpm",
      );
      context.writeln(
        "• Average SpO₂: ${dashboard!.avgSpo2?.toStringAsFixed(1) ?? 'N/A'}%",
      );
      context.writeln(
        "• Average Blood Pressure: ${dashboard!.avgSystolic?.toStringAsFixed(1) ?? 'N/A'}/${dashboard!.avgDiastolic?.toStringAsFixed(1) ?? 'N/A'} mmHg",
      );
      context.writeln(
        "• Average Weight: ${dashboard!.avgWeight?.toStringAsFixed(1) ?? 'N/A'} lbs",
      );
      context.writeln("");
    }

    // Add recent vitals data (limit to last 10 entries for context)
    if (vitals.isNotEmpty) {
      context.writeln("RECENT VITAL SIGNS:");
      final recentVitals = vitals.take(10).toList();
      for (var vital in recentVitals) {
        context.writeln(
          "• ${vital.timestamp.toString().substring(0, 10)}: HR ${vital.heartRate}bpm, SpO₂ ${vital.spo2}%, BP ${vital.systolic}/${vital.diastolic}mmHg, Weight ${vital.weight}lbs",
        );
      }
      if (vitals.length > 10) {
        context.writeln("... and ${vitals.length - 10} more entries");
      }
      context.writeln("");
    }

    // Add trends and patterns
    if (vitals.length > 1) {
      final firstVital = vitals.last; // oldest
      final lastVital = vitals.first; // newest

      context.writeln("TRENDS OVER PERIOD:");
      context.writeln(
        "• Heart Rate: ${firstVital.heartRate}bpm → ${lastVital.heartRate}bpm (${lastVital.heartRate - firstVital.heartRate > 0 ? '+' : ''}${lastVital.heartRate - firstVital.heartRate})",
      );
      context.writeln(
        "• SpO₂: ${firstVital.spo2}% → ${lastVital.spo2}% (${lastVital.spo2 - firstVital.spo2 > 0 ? '+' : ''}${lastVital.spo2 - firstVital.spo2})",
      );
      context.writeln(
        "• Weight: ${firstVital.weight}lbs → ${lastVital.weight}lbs (${lastVital.weight - firstVital.weight > 0 ? '+' : ''}${(lastVital.weight - firstVital.weight).toStringAsFixed(1)})",
      );
      context.writeln("");
    }

    context.writeln("You can ask questions about:");
    context.writeln("• Health trends and patterns");
    context.writeln("• Normal ranges and what values mean");
    context.writeln("• Potential health concerns or improvements");
    context.writeln("• Medication adherence insights");
    context.writeln("• Lifestyle recommendations");
    context.writeln("• Data interpretation and analysis");

    return context.toString();
  }

  Widget _buildAIAssistantCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AI Health Assistant',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ask questions about this patient\'s health data and get AI-powered insights:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You can ask about:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Health trends and patterns interpretation\n'
                      '• Whether values are within normal ranges\n'
                      '• Potential health concerns or improvements\n'
                      '• Medication adherence insights\n'
                      '• Lifestyle and care recommendations\n'
                      '• Overall health progress assessment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sample questions:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildSuggestionChip('Interpret trends'),
                  _buildSuggestionChip('Normal ranges'),
                  _buildSuggestionChip('Health concerns'),
                  _buildSuggestionChip('Recommendations'),
                  _buildSuggestionChip('Adherence analysis'),
                  _buildSuggestionChip('Progress summary'),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Click "Ask AI" to start a conversation about the patient\'s health data',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.privacy_tip,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Personal identifiers are excluded for privacy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.green.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [7, 14, 21, 30].map((days) {
        final isSelected = selectedDays == days;
        return FilterChip(
          label: Text('$days days'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              _onFilterChanged(days);
            }
          },
          selectedColor: Colors.blue.shade600.withValues(alpha: 0.2),
          checkmarkColor: Colors.blue.shade600,
          labelStyle: TextStyle(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildChart(
    String title,
    List<FlSpot> spots, {
    double minY = 0,
    double maxY = 200,
    Color? primaryColor,
    String? unit,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor ?? Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  if (unit != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (primaryColor ?? Colors.blue.shade600)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor ?? Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: primaryColor ?? Colors.blue.shade600,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: spots.length <= 10,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                radius: 4,
                                color: primaryColor ?? Colors.blue.shade600,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (primaryColor ?? Colors.blue.shade600)
                              .withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
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
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.month}/${date.day}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          },
                          reservedSize: 32,
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use responsive aspect ratio and cross count based on screen width
        double aspectRatio;
        int crossAxisCount;

        if (constraints.maxWidth < 350) {
          // Very small screens: single column
          aspectRatio = 6.0;
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 450) {
          // Small screens: higher aspect ratio for 2 columns
          aspectRatio = 4.5;
          crossAxisCount = 2;
        } else {
          // Normal screens: standard 2 columns
          aspectRatio = 3.5;
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          crossAxisSpacing: crossAxisCount == 1 ? 0 : 8,
          mainAxisSpacing: 8,
          children: [
            _buildSummaryItem(
              'Adherence Rate',
              '${dashboard!.adherenceRate?.toStringAsFixed(1) ?? 'N/A'}%',
              Icons.check_circle,
            ),
            _buildSummaryItem(
              'Avg Heart Rate',
              '${dashboard!.avgHeartRate?.toStringAsFixed(0) ?? 'N/A'} bpm',
              Icons.favorite,
            ),
            _buildSummaryItem(
              'Avg SpO₂',
              '${dashboard!.avgSpo2?.toStringAsFixed(1) ?? 'N/A'}%',
              Icons.air,
            ),
            _buildSummaryItem(
              'Avg Blood Pressure',
              '${dashboard!.avgSystolic?.toStringAsFixed(0) ?? 'N/A'}/${dashboard!.avgDiastolic?.toStringAsFixed(0) ?? 'N/A'}',
              Icons.monitor_heart,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust sizing based on available width
        double iconSize = constraints.maxWidth < 150 ? 10 : 12;
        double titleFontSize = constraints.maxWidth < 150 ? 8 : 9;
        double valueFontSize = constraints.maxWidth < 150 ? 10 : 12;
        double padding = constraints.maxWidth < 150 ? 4 : 6;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: iconSize,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Patient Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Patient Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchAnalytics,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Prepare chart data with different colors for each chart
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Patient Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Refresh button
          IconButton(
            onPressed: loading ? null : fetchAnalytics,
            icon: Icon(
              Icons.refresh,
              color: loading ? Colors.white54 : Colors.white,
            ),
            tooltip: 'Refresh Data',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => exportFile('pdf'),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => exportFile('csv'),
              icon: const Icon(Icons.table_chart, size: 18),
              label: const Text('CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome header
                      Text(
                        'Analytics Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Patient health metrics and trends',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Filter chips
                      Row(
                        children: [
                          Text(
                            'Time Range:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFilterChips()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // AI Assistant Card
                      _buildAIAssistantCard(),

                      const SizedBox(height: 24),

                      // Summary Card
                      if (dashboard != null)
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade700,
                                  Colors.blue.shade500,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.analytics,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Health Summary',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                // Use shorter format for narrow screens
                                                if (constraints.maxWidth <
                                                    200) {
                                                  return Text(
                                                    'Last $selectedDays days',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 13,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  );
                                                } else {
                                                  return Text(
                                                    'Period: Last $selectedDays days (${dashboard!.periodStart?.month ?? '?'}/${dashboard!.periodStart?.day ?? '?'} - ${dashboard!.periodEnd?.month ?? '?'}/${dashboard!.periodEnd?.day ?? '?'})',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildSummaryGrid(),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Charts Section
                      Text(
                        'Detailed Charts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),

                      buildChart(
                        'Heart Rate',
                        heartRateSpots,
                        minY: 50,
                        maxY: 120,
                        primaryColor: Colors.red.shade600,
                        unit: 'bpm',
                      ),
                      buildChart(
                        'SpO₂',
                        spo2Spots,
                        minY: 90,
                        maxY: 100,
                        primaryColor: Colors.blue.shade600,
                        unit: '%',
                      ),
                      buildChart(
                        'Systolic Blood Pressure',
                        systolicSpots,
                        minY: 100,
                        maxY: 140,
                        primaryColor: Colors.orange.shade600,
                        unit: 'mmHg',
                      ),
                      buildChart(
                        'Diastolic Blood Pressure',
                        diastolicSpots,
                        minY: 60,
                        maxY: 100,
                        primaryColor: Colors.purple.shade600,
                        unit: 'mmHg',
                      ),
                      buildChart(
                        'Weight',
                        weightSpots,
                        minY: 100,
                        maxY: 250,
                        primaryColor: Colors.green.shade600,
                        unit: 'lbs',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Loading overlay for filter changes
                if (loading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading analytics data...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // AI Chat Widget for analytics context
          AIChat(role: 'analytics', healthDataContext: _getHealthDataContext()),
        ],
      ),
    );
  }
}
