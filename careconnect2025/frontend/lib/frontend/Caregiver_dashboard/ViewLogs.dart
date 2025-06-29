/* import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewLogScreen extends StatefulWidget {
  const ViewLogScreen({super.key});

  @override
  State<ViewLogScreen> createState() => _ViewLogScreenState();
}

class _ViewLogScreenState extends State<ViewLogScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }
//creating function to connect with backend

  Future<void> fetchLogs() async {
    try {
      final response = await http.get(Uri.parse("http://your-backend.com/api/patient/logs"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _logs = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to fetch logs: $e";
        _isLoading = false;
      });
    }
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final timestamp = DateTime.parse(log['timestamp']);
    final formattedDate = "${timestamp.month}/${timestamp.day}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🕒 $formattedDate", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("💊 Medication Taken: ${log['medicationTaken'] ? 'Yes' : 'No'}"),
            Text("🍽️ Meal Taken: ${log['mealTaken'] ?? 'Not recorded'}"),
            Text("😷 Symptoms: ${log['symptoms'] ?? 'None'}"),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Logs'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _logs.isEmpty
          ? const Center(child: Text("No logs found."))
          : ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) => _buildLogCard(_logs[index]),
      ),
    );
  }
}
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewLogScreen extends StatelessWidget {
  // Replace with your actual class name

  final List<Map<String, String>> _logs = [
    {
      "title": "Vitals Check",
      "description": "Blood pressure normal.",
      "date": "June 15",
    },
    {
      "title": "Medication Given",
      "description": "Administered insulin.",
      "date": "June 16",
    },
    {
      "title": "Follow-up",
      "description": "Scheduled next visit.",
      "date": "June 27",
    },
  ];

  ViewLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Logs'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _logs.isEmpty
          ? const Center(child: Text("No logs found."))
          : ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: ListTile(
              title: Text(log["title"] ?? 'Untitled'),
              subtitle: Text(log["description"] ?? 'No description'),
              trailing: Text(log["date"] ?? ''),
            ),
          );
        },
      ),
    );
  }
}
