import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../state/scenario_provider.dart';
import '../shared/models/node_block.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  double _scale = 1.0;
  NodeBlock? currentNode;
  bool simulating = false;
  int? currentQuestionIndex;
  final TextEditingController _responseController = TextEditingController();

  void _zoomIn() => setState(() => _scale = (_scale + 0.1).clamp(0.3, 3.0));
  void _zoomOut() => setState(() => _scale = (_scale - 0.1).clamp(0.3, 3.0));

  void _startSimulation(List<NodeBlock> blocks) {
    if (blocks.isEmpty) return;
    final startNode = blocks.firstWhere(
      (b) => b.type.toLowerCase() == "start",
      orElse: () => blocks.first,
    );
    setState(() {
      simulating = true;
      currentNode = startNode;
      currentQuestionIndex = null;
    });
  }

  void _continueSimulation(List<NodeBlock> blocks) {
    if (currentNode == null) return;
    final currentIndex = blocks.indexWhere((b) => b.id == currentNode!.id);
    if (currentIndex + 1 < blocks.length) {
      setState(() {
        currentNode = blocks[currentIndex + 1];
        currentQuestionIndex = null;
      });
    } else {
      setState(() {
        simulating = false;
        currentNode = null;
        currentQuestionIndex = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Simulation complete.")),
      );
    }
  }

  void _clearCanvas() {
    ref.read(scenarioProvider.notifier).clear();
    setState(() {
      simulating = false;
      currentNode = null;
      currentQuestionIndex = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Canvas cleared')),
    );
  }

  Future<void> _loadSimulation() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.bytes != null) {
        final jsonString = String.fromCharCodes(result.files.single.bytes!);
        final parsedJson = jsonDecode(jsonString);

        final nodes = (parsedJson is List)
            ? parsedJson
            : (parsedJson is Map && parsedJson['nodes'] is List)
                ? parsedJson['nodes']
                : throw Exception("Invalid JSON format");

        final loadedBlocks = nodes.map<NodeBlock>((e) => NodeBlock(
              id: e['id'],
              offset: Offset(
                (e['offset']['dx'] as num).toDouble(),
                (e['offset']['dy'] as num).toDouble(),
              ),
              title: e['title'],
              type: e['type'],
              description: e['description'],
              welcomeMessage: e['welcomeMessage'],
              lessonType: e['lessonType'],
              lessonContent: e['lessonContent'],
              estimatedTime: e['estimatedTime'],
              quizTitle: e['quizTitle'],
              passingScore: e['passingScore'],
              timeLimit: e['timeLimit'],
              conditionExpression: e['conditionExpression'],
              truePathLabel: e['truePathLabel'],
              falsePathLabel: e['falsePathLabel'],
              checkpointTitle: e['checkpointTitle'],
              checkpointNote: e['checkpointNote'],
              questions: (e['questions'] as List?)
                  ?.map((q) => (q as Map).cast<String, String>())
                  .toList(),
            )).toList();

        ref.read(scenarioProvider.notifier).replace(loadedBlocks);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Simulation loaded successfully.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading: $e")),
      );
    }
  }

  Size _calculateCanvasSize(List<NodeBlock> blocks) {
    if (blocks.isEmpty) return const Size(1000, 1000);
    double maxX = 0, maxY = 0;
    for (var block in blocks) {
      if (block.offset.dx > maxX) maxX = block.offset.dx;
      if (block.offset.dy > maxY) maxY = block.offset.dy;
    }
    return Size(maxX + 400, maxY + 400);
  }

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(scenarioProvider);
    final canvasSize = _calculateCanvasSize(blocks);

    return Scaffold(
      appBar: AppBar(title: const Text('Simulator')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final buttons = [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Load Simulation'),
                    onPressed: _loadSimulation,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear Canvas'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _clearCanvas,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Simulation'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _startSimulation(blocks),
                  ),
                ];
                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: buttons
                            .map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: b,
                                ))
                            .toList(),
                      )
                    : Row(
                        children: buttons
                            .map((b) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: b,
                                ))
                            .toList(),
                      );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: Stack(
              children: [
                simulating && currentNode != null
                    ? _buildNodeDetail(currentNode!)
                    : _buildCanvas(blocks, canvasSize),
                _buildZoomButtons(),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                labelText: 'Trainee response',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Submit Response'),
              onPressed: () => _handleTraineeResponse(blocks),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildNodeDetail(NodeBlock node) {
    return Container(
      color: Colors.deepPurple.shade50,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${node.type} Node", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildNodeFields(node),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (node.type.toLowerCase() != "quiz") {
                      _continueSimulation(ref.read(scenarioProvider));
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Continue"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Generated Dialog"),
                        content: const Text("Ai generated dialog content."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text("Generate Dialog"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNodeFields(NodeBlock node) {
    // leave quiz question display alone
    if (node.type.toLowerCase() == "quiz" && node.questions != null && node.questions!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quiz Title: ${node.quizTitle ?? 'N/A'}"),
          const SizedBox(height: 8),
          Text(
            "Question: ${node.questions![currentQuestionIndex ?? 0]['question']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    // for all other types show every field
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (node.title.isNotEmpty) Text("Title: ${node.title}"),
        if (node.description != null) Text("Description: ${node.description}"),
        if (node.welcomeMessage != null) Text("Welcome Message: ${node.welcomeMessage}"),
        if (node.lessonType != null) Text("Lesson Type: ${node.lessonType}"),
        if (node.lessonContent != null) Text("Lesson Content: ${node.lessonContent}"),
        if (node.estimatedTime != null) Text("Estimated Time: ${node.estimatedTime}"),
        if (node.conditionExpression != null) Text("Condition: ${node.conditionExpression}"),
        if (node.truePathLabel != null) Text("True Path Label: ${node.truePathLabel}"),
        if (node.falsePathLabel != null) Text("False Path Label: ${node.falsePathLabel}"),
        if (node.checkpointTitle != null) Text("Checkpoint Title: ${node.checkpointTitle}"),
        if (node.checkpointNote != null) Text("Checkpoint Note: ${node.checkpointNote}"),
      ],
    );
  }

  Widget _buildCanvas(List<NodeBlock> blocks, Size canvasSize) {
    return InteractiveViewer(
      minScale: 0.3,
      maxScale: 3.0,
      panEnabled: true,
      scaleEnabled: false,
      child: Transform.scale(
        scale: _scale,
        alignment: Alignment.center,
        child: SizedBox(
          width: canvasSize.width,
          height: canvasSize.height,
          child: Stack(
            children: [
              CustomPaint(painter: _ConnectionPainter(blocks), child: Container()),
              ...blocks.map((block) => Positioned(
                    left: block.offset.dx,
                    top: block.offset.dy,
                    child: Card(
                      color: currentNode?.id == block.id ? Colors.orange : Colors.deepPurple,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(block.type,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(block.title,
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButtons() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: _zoomIn,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  void _handleTraineeResponse(List<NodeBlock> blocks) {
    final response = _responseController.text.trim();
    if (simulating && currentNode != null) {
      if (currentNode!.type.toLowerCase() == "quiz" &&
          currentNode!.questions != null &&
          currentNode!.questions!.isNotEmpty) {
        final currentQ = currentNode!.questions![currentQuestionIndex ?? 0];
        final answer = currentQ['answer']?.toLowerCase() ?? "";
        if (response.toLowerCase() == answer) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Correct!")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Incorrect, correct was: $answer")));
        }
        if ((currentQuestionIndex ?? 0) + 1 < currentNode!.questions!.length) {
          setState(() {
            currentQuestionIndex = (currentQuestionIndex ?? 0) + 1;
          });
        } else {
          _continueSimulation(blocks);
        }
      } else if (currentNode!.type.toLowerCase() == "decision") {
        _continueSimulation(blocks);
      } else {
        _continueSimulation(blocks);
      }
      _responseController.clear();
    }
  }
}

class _ConnectionPainter extends CustomPainter {
  final List<NodeBlock> blocks;
  _ConnectionPainter(this.blocks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 2;
    for (int i = 0; i < blocks.length - 1; i++) {
      final from = blocks[i].offset + const Offset(50, 20);
      final to = blocks[i + 1].offset + const Offset(50, 20);
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}