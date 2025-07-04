import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final List<String> defaultSymptoms = [
    'Fever',
    'Cough',
    'Fatigue',
    'Headache',
    'Nausea',
    'Sore throat',
    'Shortness of breath'
  ];

  final List<SymptomEntry> history = [];
  String? selectedSymptom;
  final TextEditingController customSymptomController = TextEditingController();
  double severity = 1;
  DateTime? occurrenceTime;
  File? selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitEntry() {
    final symptom = selectedSymptom ?? customSymptomController.text.trim();
    if (symptom.isEmpty || occurrenceTime == null) return;

    final newEntry = SymptomEntry(
      symptom: symptom,
      severity: severity,
      timestamp: occurrenceTime!,
      image: selectedImage,
    );

    setState(() {
      history.insert(0, newEntry);
      // reset form
      selectedSymptom = null;
      customSymptomController.clear();
      severity = 1;
      occurrenceTime = null;
      selectedImage = null;
    });

    if (severity >= 7) {
      // Placeholder for real alert system
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Alert: Symptom "$symptom" is severe and caregiver has been notified.')),
      );
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      occurrenceTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Tracker'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select a symptom:'),
            DropdownButton<String>(
              value: selectedSymptom,
              hint: const Text('Choose a symptom'),
              isExpanded: true,
              items: defaultSymptoms.map((symptom) {
                return DropdownMenuItem(
                  value: symptom,
                  child: Text(symptom),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedSymptom = value),
            ),
            const SizedBox(height: 8),
            const Text('Or enter a custom symptom:'),
            TextField(
              controller: customSymptomController,
              decoration:
                  const InputDecoration(hintText: 'e.g. Chest tightness'),
            ),
            const SizedBox(height: 16),
            const Text('Severity (1 = mild, 10 = severe):'),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: severity,
              label: severity.toStringAsFixed(0),
              onChanged: (val) => setState(() => severity = val),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(
                occurrenceTime == null
                    ? 'Select time of occurrence'
                    : 'Time: ${occurrenceTime!.month}/${occurrenceTime!.day}/${occurrenceTime!.year} @ ${occurrenceTime!.hour}:${occurrenceTime!.minute.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Symptom Photo'),
            ),
            if (selectedImage != null) ...[
              const SizedBox(height: 8),
              Image.file(selectedImage!, height: 100),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitEntry,
              child: const Text('Submit Symptom Log'),
            ),
            const Divider(height: 32),
            const Text('Symptom History:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...history.map((entry) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: entry.image != null
                        ? Image.file(entry.image!, width: 50, fit: BoxFit.cover)
                        : const Icon(Icons.local_hospital),
                    title: Text(entry.symptom),
                    subtitle: Text(
                        'Severity: ${entry.severity.toInt()}\nTime: ${entry.timestamp.month}/${entry.timestamp.day}/${entry.timestamp.year} @ ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class SymptomEntry {
  final String symptom;
  final double severity;
  final DateTime timestamp;
  final File? image;

  SymptomEntry({
    required this.symptom,
    required this.severity,
    required this.timestamp,
    this.image,
  });
}
