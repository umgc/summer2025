import 'package:flutter/material.dart';

class MoodWellnessCheckIn extends StatefulWidget {
  const MoodWellnessCheckIn({super.key});

  @override
  State<MoodWellnessCheckIn> createState() => _MoodWellnessCheckInState();
}

class _MoodWellnessCheckInState extends State<MoodWellnessCheckIn> {
  double _moodValue = 5;
  double _painValue = 5;
  final TextEditingController _noteController = TextEditingController();

  final Map<int, String> moodEmojis = {
    1: '🙁', // 🙁 Very Sad
    2: '😔', // 😔 Sad
    3: '😕', // 😕 Down
    4: '😐', // 😐 Unhappy
    5: '🙂', // 🙂 Neutral
    6: '😊', // 😊 Okay
    7: '😃', // 😃 Content
    8: '😄', // 😄 Happy
    9: '😁', // 😁 Joyful
    10: '😍', // 😍 Very Happy
  };

  final Map<int, String> painEmojis = {
    1: '😀', // 😀 No Pain
    2: '🙂', // 🙂 Minimal Pain
    3: '😐', // 😐 Mild Pain
    4: '😕', // 😕 Discomfort
    5: '🙁', // 🙁 Moderate Pain
    6: '😞', // 😞 Significant Pain
    7: '😢', // 😢 High Pain
    8: '😥', // 😥 Intense Pain
    9: '😭', // 😭 Severe Pain
    10: '😱', // 😱 Worst Pain
  };

  void _submitMoodLog() {
    final now = DateTime.now();
    final moodEntry = {
      'timestamp': now.toIso8601String(),
      'moodValue': _moodValue.toInt(),
      'moodEmoji': moodEmojis[_moodValue.toInt()] ?? '',
      'painValue': _painValue.toInt(),
      'painEmoji': painEmojis[_painValue.toInt()] ?? '',
      'note': _noteController.text.trim(),
    };

    // Placeholder for backend submission
    debugPrint('Mood & Pain log submitted: $moodEntry');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mood & Pain submitted successfully.')),
    );

    // Clear the input
    setState(() {
      _moodValue = 5;
      _painValue = 5;
      _noteController.clear();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Wellness Check-In'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Mood: ${moodEmojis[_moodValue.toInt()] ?? ''}',
              style: const TextStyle(fontSize: 30),
            ),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              label: _moodValue.toStringAsFixed(0),
              value: _moodValue,
              onChanged: (value) => setState(() => _moodValue = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pain Level:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Pain: ${painEmojis[_painValue.toInt()] ?? ''}',
              style: const TextStyle(fontSize: 30),
            ),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              label: _painValue.toStringAsFixed(0),
              value: _painValue,
              onChanged: (value) => setState(() => _painValue = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Would you like to share anything else?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write about your day or feelings here... (optional)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitMoodLog,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
