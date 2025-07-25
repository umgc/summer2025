import 'package:flutter/material.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';

class MoodWellnessCheckIn extends StatefulWidget {
  const MoodWellnessCheckIn({super.key});

  @override
  State<MoodWellnessCheckIn> createState() => _MoodWellnessCheckInState();
}

class _MoodWellnessCheckInState extends State<MoodWellnessCheckIn> {
  double _moodValue = 5;
  double _painValue = 5;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

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

  // FIX: Make the method async and add proper error handling
  Future<void> _submitMoodLog() async {
    final now = DateTime.now();
    final moodEntry = {
      'timestamp': now.toIso8601String(),
      'moodValue': _moodValue.toInt(),
      'moodEmoji': moodEmojis[_moodValue.toInt()] ?? '',
      'painValue': _painValue.toInt(),
      'painEmoji': painEmojis[_painValue.toInt()] ?? '',
      'note': _noteController.text.trim(),
    };

    // Show loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Send to backend
      final response = await ApiService.submitMoodAndPainLog(
        moodValue: _moodValue.toInt(),
        painValue: _painValue.toInt(),
        note: _noteController.text.trim(),
        timestamp: now,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mood & Pain submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the input on success
          setState(() {
            _moodValue = 5;
            _painValue = 5;
            _noteController.clear();
          });
        }
      } else {
        throw Exception('Failed to submit data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Mood & Wellness Check-In',
      ),
      drawer: const CommonDrawer(currentRoute: '/mood_wellness'),
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
              activeColor: Colors.blue.shade900,
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
              activeColor: Colors.red.shade700,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitMoodLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
