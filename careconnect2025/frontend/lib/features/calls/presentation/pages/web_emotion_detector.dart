import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';

class WebEmotionDetector extends StatefulWidget {
  const WebEmotionDetector({Key? key}) : super(key: key);

  @override
  State<WebEmotionDetector> createState() => _WebEmotionDetectorState();
}

class _WebEmotionDetectorState extends State<WebEmotionDetector> {
  CameraController? _controller;
  String _simulatedEmotion = "Neutral";
  String _emoji = "😐";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _initCamera();
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.low);
    await _controller!.initialize();

    if (!mounted) return;
    setState(() {});
    _startSimulatedDetection();
  }

  void _startSimulatedDetection() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      final emotions = ["Happy", "Sad", "Neutral"];
      final emojis = ["😄", "☹️", "😐"];
      final index = DateTime.now().second % emotions.length;

      setState(() {
        _simulatedEmotion = emotions[index];
        _emoji = emojis[index];
      });

      return mounted;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Emotion Detector'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
              const SizedBox(height: 20),
              Text(
                "Emotion: $_simulatedEmotion $_emoji",
                style: GoogleFonts.notoSans(
                  textStyle: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
