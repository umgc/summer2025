import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../state/scenario_provider.dart';
import '../shared/models/node_block.dart';
import 'dart:typed_data'; // Required for FilePicker.platform.saveFile bytes

class ScenarioBuilderScreen extends ConsumerStatefulWidget {
  final String initialDomain;
  const ScenarioBuilderScreen({super.key, required this.initialDomain});

  @override
  ConsumerState<ScenarioBuilderScreen> createState() =>
      _ScenarioBuilderScreenState();
}

class _ScenarioBuilderScreenState extends ConsumerState<ScenarioBuilderScreen> {
  late String selectedDomain;

  final List<String> nodeTypes = [
    'Start',
    'Lesson',
    'Quiz',
    'Decision',
    'Checkpoint',
    'End',
    'Interactive',
    'Event',
  ];

  final List<String> domains = [
    'Oil & Gas',
    'IT Project Management',
    'Healthcare',
    'Military',
    'Government',
    'Finance',
  ];

  /// Domain-specific images
  final Map<String, String> domainImages = {
    'Oil & Gas': 'assets/images/oil-pumps.jpg',
    'IT Project Management': 'assets/images/it_management_background.jpg',
    'Healthcare': 'assets/images/healthcare_background.jpg',
    'Military': 'assets/images/military_background.jpg',
    'Government': 'assets/images/government_background.jpg',
    'Finance': 'assets/images/finance_background.jpg',
  };

  /// Domain-specific event templates
  /// These can be used to generate random events based on the selected domain.
  final Map<String, List<Map<String, String>>> domainEventTemplates = {
    'Healthcare': [
      {'type': 'Pop Quiz', 'content': 'What is the normal blood pressure?'},
      {'type': 'Surprise Task', 'content': 'Sterilize a new tool set.'},
      {'type': 'Pop Quiz', 'content': 'How many bones are in the human body?'},
      {'type': 'Surprise Task', 'content': 'Triage five incoming patients.'},
      {
        'type': 'Pop Quiz',
        'content': 'What PPE is required for airborne precautions?',
      },
    ],
    'Military': [
      {'type': 'Pop Quiz', 'content': 'How do you identify friendly fire?'},
      {
        'type': 'Surprise Task',
        'content': 'Clean your weapon in under 2 minutes.',
      },
      {'type': 'Pop Quiz', 'content': 'What does “HOOAH” stand for?'},
      {
        'type': 'Surprise Task',
        'content': 'Prepare a defensive perimeter using your squad.',
      },
      {
        'type': 'Pop Quiz',
        'content': 'What is the five-paragraph OPORD format?',
      },
    ],
    'IT Project Management': [
      {
        'type': 'Surprise Task',
        'content': 'Your stakeholder changed a requirement. What do you do?',
      },
      {'type': 'Pop Quiz', 'content': 'What does MVP stand for?'},
      {
        'type': 'Pop Quiz',
        'content': 'What’s the difference between Agile and Waterfall?',
      },
      {
        'type': 'Surprise Task',
        'content': 'The project is delayed. Create a mitigation plan.',
      },
      {'type': 'Pop Quiz', 'content': 'Define the term "technical debt."'},
    ],
    'Oil & Gas': [
      {'type': 'Pop Quiz', 'content': 'What is the flash point of crude oil?'},
      {
        'type': 'Surprise Task',
        'content': 'Respond to a simulated pipeline leak.',
      },
      {
        'type': 'Pop Quiz',
        'content': 'What is upstream vs. downstream in oil & gas?',
      },
      {
        'type': 'Surprise Task',
        'content': 'Conduct a risk assessment on a drilling site.',
      },
      {
        'type': 'Pop Quiz',
        'content': 'What PPE is required for rig floor personnel?',
      },
    ],
    'Government': [
      {'type': 'Pop Quiz', 'content': 'What is the FOIA?'},
      {
        'type': 'Surprise Task',
        'content': 'Draft a policy response to a cyber threat.',
      },
      {
        'type': 'Pop Quiz',
        'content': 'What are the three branches of government?',
      },
      {
        'type': 'Surprise Task',
        'content': 'You must prepare for a public press briefing.',
      },
      {'type': 'Pop Quiz', 'content': 'What does OMB stand for?'},
    ],
    'Finance': [
      {'type': 'Pop Quiz', 'content': 'What does ROI stand for?'},
      {
        'type': 'Surprise Task',
        'content': 'Analyze this balance sheet for errors.',
      },
      {
        'type': 'Pop Quiz',
        'content': 'What is the difference between a stock and a bond?',
      },
      {
        'type': 'Surprise Task',
        'content': 'Develop a quick forecast for next quarter.',
      },
      {'type': 'Pop Quiz', 'content': 'What is compound interest?'},
    ],
  };

  /// Returns a random event for the given domain.
  /// If no specific events are defined for the domain, returns a generic event.
  Map<String, String> getRandomEventForDomain(String domain) {
    final events = domainEventTemplates[domain];
    if (events == null || events.isEmpty) {
      return {
        'type': 'Generic Event',
        'content': 'A random event has occurred.',
      };
    }
    return events[Random().nextInt(events.length)];
  }

  @override
  void initState() {
    super.initState();
    selectedDomain = widget.initialDomain;
  }

  // --- MODIFIED: _addNode to include parentId logic ---
  void _addNode(String type, Offset offset) {
    final currentNodes = ref.read(scenarioProvider);
    String? lastNodeId;

    // If there are existing nodes, the last one becomes the parent of the new node.
    if (currentNodes.isNotEmpty) {
      lastNodeId = currentNodes.last.id;
    }

    if (type == 'Event') {
      final randomEvent = getRandomEventForDomain(selectedDomain);
      ref.read(scenarioProvider.notifier).addNode(
            NodeBlock(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              offset: offset,
              type: type,
              title: randomEvent['type']!,
              eventType: randomEvent['type'],
              eventContent: randomEvent['content'],
              parentId: lastNodeId, // <--- Crucial: Assign parentId here
            ),
          );
    } else {
      ref.read(scenarioProvider.notifier).addNode(
            NodeBlock(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              offset: offset,
              type: type,
              title: type,
              parentId: lastNodeId, // <--- Crucial: Assign parentId here
            ),
          );
    }
  }
  // --- END MODIFIED _addNode ---

  void _editNode(NodeBlock block) {
    showDialog(
      context: context,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final currentBlock = ref
              .watch(scenarioProvider)
              .firstWhere((b) => b.id == block.id);

          return AlertDialog(
            title: Text('Edit ${currentBlock.type}'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width >= 800 ? 768 : null,
              height: MediaQuery.of(context).size.width >= 800 ? 512 : null,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: currentBlock.title,
                      onChanged: (val) => ref
                          .read(scenarioProvider.notifier)
                          .updateNode(currentBlock.copyWith(title: val)),
                      decoration: const InputDecoration(
                        labelText: 'Node Title',
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (currentBlock.type == 'Start') ...[
                      TextFormField(
                        initialValue: currentBlock.welcomeMessage ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(welcomeMessage: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Welcome Message',
                        ),
                      ),
                    ],
                    if (currentBlock.type == 'Lesson') ...[
                      DropdownButtonFormField<String>(
                        value: currentBlock.lessonType ?? 'Text',
                        items: ['Text', 'Image', 'Video']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(currentBlock.copyWith(lessonType: val)),
                        decoration: const InputDecoration(
                          labelText: 'Lesson Type',
                        ),
                      ),

                      if (currentBlock.lessonType == 'Image' ||
                          currentBlock.lessonType == 'Video') ...[
                        ElevatedButton(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: currentBlock.lessonType == 'Image'
                                  ? FileType.image
                                  : FileType.video,
                            );
                            if (result != null &&
                                result.files.single.path != null) {
                              ref
                                  .read(scenarioProvider.notifier)
                                  .updateNode(
                                    currentBlock.copyWith(
                                      lessonContent: result.files.single.path!,
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Selected: ${result.files.single.name}",
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            currentBlock.lessonType == 'Image'
                                ? 'Pick Image'
                                : 'Pick Video',
                          ),
                        ),
                        if (currentBlock.lessonContent != null &&
                            currentBlock.lessonContent!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Selected: ${currentBlock.lessonContent}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                      TextFormField(
                        initialValue: currentBlock.lessonContent ?? '',
                        maxLines: 8,
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(lessonContent: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Lesson Content',
                        ),
                      ),

                      TextFormField(
                        initialValue: currentBlock.estimatedTime ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(estimatedTime: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Estimated Time (minutes)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    if (currentBlock.type == 'Quiz') ...[
                      TextFormField(
                        initialValue: currentBlock.quizTitle ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(currentBlock.copyWith(quizTitle: val)),
                        decoration: const InputDecoration(
                          labelText: 'Quiz Title',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.passingScore ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(passingScore: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Passing Score (%)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        initialValue: currentBlock.timeLimit ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(currentBlock.copyWith(timeLimit: val)),
                        decoration: const InputDecoration(
                          labelText: 'Time Limit (minutes)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String questionText = "";
                          String correctAnswer = "";
                          final result = await showDialog<Map<String, String>>(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text("Add Question"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        labelText: "Question",
                                      ),
                                      onChanged: (val) => questionText = val,
                                    ),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: "Correct Answer",
                                      ),
                                      onChanged: (val) => correctAnswer = val,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx, {
                                        "question": questionText,
                                        "answer": correctAnswer,
                                      });
                                    },
                                    child: const Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (result != null &&
                              result["question"]!.trim().isNotEmpty) {
                            final updatedQuestions = [
                              ...?currentBlock.questions,
                              result,
                            ];
                            ref
                                .read(scenarioProvider.notifier)
                                .updateNode(
                                  currentBlock.copyWith(
                                    questions: updatedQuestions,
                                  ),
                                );
                          }
                        },
                        child: const Text('Add Question'),
                      ),
                      if (currentBlock.questions != null &&
                          currentBlock.questions!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              "Questions:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...currentBlock.questions!.asMap().entries.map(
                              (entry) => ListTile(
                                dense: true,
                                title: Text(
                                  "${entry.key + 1}. ${entry.value['question']} (Answer: ${entry.value['answer']})",
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],

                    if (currentBlock.type == 'Decision') ...[
                      TextFormField(
                        initialValue: currentBlock.conditionExpression ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(conditionExpression: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Condition Expression',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.truePathLabel ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(truePathLabel: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'True Path Label',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.falsePathLabel ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(falsePathLabel: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'False Path Label',
                        ),
                      ),
                    ],

                    if (currentBlock.type == 'Checkpoint') ...[
                      TextFormField(
                        initialValue: currentBlock.checkpointTitle ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(checkpointTitle: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Checkpoint Title',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.checkpointNote ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(checkpointNote: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Checkpoint Note',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.estimatedTime ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(estimatedTime: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Estimated Time (minutes)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    /// Event nodes allow for dynamic interactions
                    /// like pop quizzes or surprise tasks.
                    if (currentBlock.type == 'Event') ...[
                      TextFormField(
                        initialValue: currentBlock.eventType ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(currentBlock.copyWith(eventType: val)),
                        decoration: const InputDecoration(
                          labelText:
                              'Event Type (e.g., Pop Quiz, Surprise Task)',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.triggerCondition ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(triggerCondition: val),
                            ),
                        decoration: const InputDecoration(
                          labelText:
                              'Trigger Condition (e.g., Random, After Lesson)',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.eventContent ?? '',
                        maxLines: 6,
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(eventContent: val),
                            ),
                        decoration: const InputDecoration(
                          labelText:
                              'Event Content (e.g., quiz question or info)',
                        ),
                      ),
                      TextFormField(
                        initialValue: currentBlock.eventAnswer ?? '',
                        onChanged: (val) => ref
                            .read(scenarioProvider.notifier)
                            .updateNode(
                              currentBlock.copyWith(eventAnswer: val),
                            ),
                        decoration: const InputDecoration(
                          labelText: 'Correct Answer (if applicable)',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              // NEW: Delete button
              TextButton(
                onPressed: () {
                  // Show a confirmation dialog before deleting
                  showDialog(
                    context: context,
                    builder: (deleteContext) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Text(
                          'Are you sure you want to delete "${currentBlock.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(deleteContext), // Close confirmation
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                            ref.read(scenarioProvider.notifier).removeNode(currentBlock.id);
                            Navigator.pop(deleteContext); // Close confirmation
                            Navigator.pop(context); // Close the edit dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Node "${currentBlock.title}" deleted')),
                                );
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              // Your existing "Done" button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper functions for node colors
  Color _getNodeColor(String type) {
    switch (type) {
      case 'Start':
        return Colors.green.shade200;
      case 'Lesson':
        return Colors.blue.shade200;
      case 'Quiz':
        return Colors.orange.shade200;
      case 'Decision':
        return Colors.purple.shade200;
      case 'Checkpoint':
        return Colors.teal.shade200;
      case 'End':
        return Colors.red.shade200;
      case 'Interactive':
        return Colors.yellow.shade200;
      case 'Event':
        return Colors.cyan.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String type) {
    switch (type) {
      case 'Start':
      case 'Lesson':
      case 'Quiz':
      case 'Decision':
      case 'Checkpoint':
      case 'End':
      case 'Interactive':
      case 'Event':
        return Colors.black87; // Dark text for lighter backgrounds
      default:
        return Colors.black54;
    }
  }

  // _buildNodeCard is included for completeness and context
  Widget _buildNodeCard(NodeBlock block, bool isDragging) {
    final cardContent = Card(
      elevation: isDragging ? 10 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: _getNodeColor(block.type),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              block.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getTextColor(block.type),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              block.type,
              style: TextStyle(
                fontSize: 12,
                color: _getTextColor(block.type).withOpacity(0.8),
              ),
            ),
            if (block.type == 'Event' && block.eventType != null)
              Text(
                block.eventType!,
                style: TextStyle(
                  fontSize: 10,
                  color: _getTextColor(block.type).withOpacity(0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            if (block.estimatedTime != null && block.estimatedTime!.isNotEmpty)
              Text(
                'Est. Time: ${block.estimatedTime} min',
                style: TextStyle(
                  fontSize: 10,
                  color: _getTextColor(block.type).withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () => _editNode(block),
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Node'),
                  onTap: () {
                    // This is for quick delete from long press, but the
                    // main delete button is in the edit dialog.
                    // Consider unifying delete logic or having a confirmation here too.
                    Navigator.pop(context); // Close the bottom sheet
                    ref.read(scenarioProvider.notifier).removeNode(block.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Node "${block.title}" deleted')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: cardContent,
    );
  }
  // END _buildNodeCard

  Widget _buildSidebar(BuildContext context, bool isMobile) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scenario Designer',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                if (domainImages[selectedDomain] != null)
                  Expanded(
                    child: Image.asset(
                      domainImages[selectedDomain]!,
                      fit: BoxFit
                          .cover, // or BoxFit.contain depending on the effect you want
                      width: double.infinity,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: selectedDomain,
              isExpanded: true,
              items: domains
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedDomain = value);
              },
            ),
          ),
          ExpansionTile(
            title: const Text('Node Palette'),
            children: nodeTypes.map((type) {
              return isMobile
                  ? ListTile(
                      leading: const Icon(Icons.touch_app),
                      title: Text(type),
                      onTap: () {
                        _addNode(type, const Offset(100, 100));
                        Navigator.pop(context);
                      },
                    )
                  : Draggable<String>(
                      data: type,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Chip(label: Text(type)),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.drag_indicator),
                        title: Text(type),
                      ),
                    );
            }).toList(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Properties Inspector'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Properties Inspector feature')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = ref.read(scenarioProvider.notifier);
    final blocks = ref.watch(scenarioProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        leading: isMobile
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        title: Text('Scenario Designer - $selectedDomain'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: scenario.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: scenario.redo),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Scenario',
            onPressed: () {
              ref.read(scenarioProvider.notifier).clear();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Canvas cleared')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              // Serialize the 'blocks' list to JSON and save it.
              // This uses the toJson method we added to NodeBlock.
              final jsonString = jsonEncode(blocks.map((block) => block.toJson()).toList());
              // In a real app, you'd save jsonString to a file.
              print('Scenario JSON: $jsonString'); // For demonstration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scenario data printed to console (save feature needs file system access)')),
              );
            },
          ),
          // --- NEW/MODIFIED: Export to JSON functionality ---
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Scenario to JSON',
            onPressed: () async {
              try {
                // Convert the current list of NodeBlock objects to a list of JSON maps
                final List<Map<String, dynamic>> scenarioJsonList = blocks
                    .map((block) => block.toJson())
                    .toList();

                // Encode the list of JSON maps into a JSON string with indentation for readability
                final String jsonString = const JsonEncoder.withIndent(
                  '  ',
                ).convert(scenarioJsonList);

                // Suggest a default filename
                String defaultFileName = 'scenario_export.json';
                // You might want to derive a more meaningful name here, e.g., from the scenario's first node's title or the selected domain.
                if (selectedDomain.isNotEmpty) {
                  defaultFileName =
                      '${selectedDomain.replaceAll(' ', '_').toLowerCase()}_scenario.json';
                } else if (blocks.isNotEmpty && blocks.first.title.isNotEmpty) {
                  defaultFileName = '${blocks.first.title.replaceAll(' ', '_').toLowerCase()}_scenario.json';
                }

                // Use file_picker to save the file
                // On web, this will trigger a download. On desktop, it will open a save dialog.
                final String? filePath = await FilePicker.platform.saveFile(
                  fileName: defaultFileName,
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                  bytes: Uint8List.fromList(jsonString.codeUnits), // Provide content as bytes
                );

                if (filePath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scenario exported to: $filePath')),
                  );
                } else {
                  // User cancelled the save operation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scenario export cancelled.')),
                  );
                }
              } catch (e) {
                // Catch any errors during the export process
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error exporting scenario: $e')),
                );
              }
            },
          ),
          // --- END NEW/MODIFIED: Export to JSON functionality ---

          // --- MODIFIED: Load Scenario functionality ---
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Scenario',
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['json'],
              );
              if (result != null && result.files.single.bytes != null) {
                try {
                  final jsonString = String.fromCharCodes(
                    result.files.single.bytes!,
                  );
                  final parsedJson = jsonDecode(jsonString);

                  if (parsedJson is! List) {
                    throw Exception("Expected JSON array at the top level");
                  }

                  // CORRECTED: Use NodeBlock.fromJson to properly deserialize
                  final loadedBlocks = (parsedJson as List)
                      .map((e) => NodeBlock.fromJson(e as Map<String, dynamic>))
                      .toList()
                      .cast<NodeBlock>(); // Explicit cast for safety

                  ref.read(scenarioProvider.notifier).replace(loadedBlocks);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scenario loaded')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load scenario: $e')),
                  );
                }
              }
            },
          ),
          // --- END MODIFIED: Load Scenario functionality ---
        ],
      ),
      drawer: isMobile ? _buildSidebar(context, isMobile) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, isMobile),
          Expanded(
            child: DragTarget<String>(
              // This DragTarget accepts String (for new nodes from sidebar)
              onAcceptWithDetails: (details) {
                final renderBox = context.findRenderObject() as RenderBox;
                final offset = renderBox.globalToLocal(details.offset);
                _addNode(details.data, offset); // This adds a new node
              },
              builder: (context, candidate, rejected) {
                return Stack(
                  children: [
                    CustomPaint(
                      painter: _ConnectionPainter(blocks), // Pass all blocks
                      child: Container(),
                    ),
                    ...blocks.map(
                      (block) => Positioned(
                        left: block.offset.dx,
                        top: block.offset.dy,
                        // MODIFIED: Draggable for existing nodes
                        child: Draggable<NodeBlock>(
                          // Draggable now takes NodeBlock as data
                          data: block, // Pass the entire NodeBlock as data
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildNodeCard(block,
                                true), // Use _buildNodeCard for visual feedback
                          ),
                          onDragEnd: (details) {
                            // Use onDragEnd for final position update
                            final renderBox =
                                context.findRenderObject() as RenderBox;
                            final localOffset =
                                renderBox.globalToLocal(details.offset);

                            ref
                                .read(scenarioProvider.notifier)
                                .updateNode(block.copyWith(offset: localOffset));
                          },
                          child: _buildNodeCard(
                              block, false), // Use _buildNodeCard here
                        ),
                        // END MODIFIED
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing connections between NodeBlocks.
class _ConnectionPainter extends CustomPainter {
  final List<NodeBlock> blocks;

  _ConnectionPainter(this.blocks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // A map to quickly look up nodes by ID
    final Map<String, NodeBlock> nodeMap = {
      for (var block in blocks) block.id: block
    };

    // Iterate through all blocks to draw connections
    for (var block in blocks) {
      // Only draw a connection if the block has a parentId
      if (block.parentId != null) {
        final parentNode = nodeMap[block.parentId];
        if (parentNode != null) {
          // Calculate the center of each node for drawing connections
          // Assuming node width 150, height 100 for connection points
          const nodeWidth = 100.0;
          const nodeHeight = 50.0;

          // Connect from the bottom-center of the parent to the top-center of the child
          final Offset parentBottomCenter = parentNode.offset + const Offset(nodeWidth / 2, nodeHeight);
          final Offset childTopCenter = block.offset + const Offset(nodeWidth / 2, 0);

          canvas.drawLine(parentBottomCenter, childTopCenter, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint if the list of blocks changes (e.g., nodes are added, removed, or moved)
    return (oldDelegate as _ConnectionPainter).blocks != blocks;
  }
}

// Extension to allow .firstWhereOrNull (often built into newer Flutter/Dart versions)
extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}