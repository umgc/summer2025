import 'dart:convert';

import 'package:care_connect_app/features/tasks/models/template_model.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/features/tasks/models/task_model.dart';
import 'package:care_connect_app/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/presentation/pre_defined_task_screen.dart';

// This screen provides a choice of what type of task to assign to a patient 
// by loading the available pre-defined tasks or offering to create a custom task.
class AssignTaskScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const AssignTaskScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  List<Template> templates = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiService.getTaskTemplates(widget.patientId).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          templates = data.map((templateJson) => Template.fromJson(templateJson)).toList();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load templates: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Task to ${widget.patientName}'),
      ),
      drawer: NavigationMenu(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Choose a task to assign to your patient.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      Expanded( //Add a card to the top of this list for a custom task
                        child: ListView.builder(
                          itemCount: templates.length+1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  leading: const Icon(Icons.task, size: 40, color: Colors.indigo),
                                  title: const Text('Custom Task'),
                                  subtitle: const Text('Create a custom task for your patient.'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    context.push('/custom-task-scheduling?patientId=${widget.patientId}');
                                  },
                                ),
                              );
                            }
                            final template = templates[index-1];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: Icon(template.icon.icon, size: 40, color: Colors.indigo),
                                title: Text(template.name),
                                subtitle: Text(template.description),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  context.push('/pre-defined-task?templateId=${template.id}&patientId=${widget.patientId}');
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