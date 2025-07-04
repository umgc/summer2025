import 'package:flutter/material.dart';

class PreDefinedCareTemplatesScreen extends StatelessWidget {
  
  // TODO: Connect this screen to the backend to fetch pre-defined care templates
  //       and display them in a list format.
  final List<Map<String, dynamic>> _templates = [
    {
      'title': 'Medication',
      'description': 'A template for managing medication schedules and dosages.',
      'icon': Icons.medication,
    },
    {
      'title': 'Meals',
      'description': 'A template for managing meal plans and nutritional information.',
      'icon': Icons.fastfood,
    },
    {
      'title': 'Daily Walk',
      'description': 'A template for managing daily walk schedules and tracking.',
      'icon': Icons.directions_walk,
    },
    {
      'title': 'Sleep',
      'description': 'A template for managing sleep schedules and quality tracking.',
      'icon': Icons.bedtime,
    },
    {
      'title': 'Bathing',
      'description': 'A template for managing bathing schedules and assistance.',
      'icon': Icons.bathtub,
    },
  ];

   PreDefinedCareTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-defined Care Templates'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Select a pre-defined care template to manage your patient\'s care.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(template['icon'], size: 40),
                      title: Text(template['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text(template['description']),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      contentPadding: const EdgeInsets.all(8.0),
                      onTap: () {
                        // TODO: Navigate to the template details screen
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}