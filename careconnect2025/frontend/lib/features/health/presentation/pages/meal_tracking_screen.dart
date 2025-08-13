import 'package:flutter/material.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';

class MealTrackingScreen extends StatefulWidget {
  const MealTrackingScreen({super.key});

  @override
  State<MealTrackingScreen> createState() => _MealTrackingScreenState();
}

class _MealTrackingScreenState extends State<MealTrackingScreen> {
  final Map<String, TextEditingController> _responses = {};
  List<String> _mealQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadMealQuestions();
  }

  void _loadMealQuestions() {
    // Placeholder for backend call in the future.
    // Will replace this with the fetched set of questions from backend when sorted
    _mealQuestions = [
      'What did you eat for breakfast?',
      'What did you eat for lunch?',
      'What did you eat for dinner?',
      'Did you drink enough water today?',
      'Did you eat any snacks today?',
    ];

    for (var question in _mealQuestions) {
      _responses[question] = TextEditingController();
    }
  }

  void _submitMealLog() {
    final now = DateTime.now();
    final log = {
      'timestamp': now.toIso8601String(),
      'responses': _responses.map((q, c) => MapEntry(q, c.text.trim())),
    };

    // Placeholder for saving to backend.
    // Will replace this with real API call in the future when backend is sorted
    debugPrint('Meal log submitted: $log');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal log submitted successfully.')),
    );

    // Clear the responses
    setState(() {
      for (var controller in _responses.values) {
        controller.clear();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _responses.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Meal & Nutrition Tracking',
      ),
      drawer: const CommonDrawer(currentRoute: '/meal_tracking'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please answer the following questions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (var question in _mealQuestions)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _responses[question],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Your answer...',
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              onPressed: _submitMealLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
              ),
              child: const Text('Submit Meal Log'),
            ),
          ],
        ),
      ),
    );
  }
}
