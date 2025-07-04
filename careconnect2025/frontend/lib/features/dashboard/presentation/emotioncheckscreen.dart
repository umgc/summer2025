/*import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'patient_call.dart';


class EmotionDetectionScreen extends StatefulWidget {
  final String patientName;

  const EmotionDetectionScreen({super.key, required this.patientName});

  @override
  State<EmotionDetectionScreen> createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  CameraController? _controller;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _canStartCall = false;

  String emotionLabel = "Detecting...";
  String emoji = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(front, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    await _controller!.startImageStream(_detectEmotion);

    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(enableClassification: true, performanceMode: FaceDetectorMode.accurate),
    );

    setState(() {});
  }

  Future<void> _detectEmotion(CameraImage image) async {
    if (_isDetecting || _faceDetector == null) return;
    _isDetecting = true;

    try {
      final WriteBuffer buffer = WriteBuffer();
      for (final plane in image.planes) {
        buffer.putUint8List(plane.bytes);
      }
      final bytes = buffer.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        final smile = faces.first.smilingProbability ?? 0;
        if (smile > 0.8) {
          emotionLabel = "Happy";
          emoji = "😄";
        } else if (smile > 0.3) {
          emotionLabel = "Neutral";
          emoji = "🙂";
        } else {
          emotionLabel = "Sad";
          emoji = "☹️";
        }
        _canStartCall = true;
      } else {
        emotionLabel = "No face detected";
        emoji = "❓";
        _canStartCall = false;
      }

      setState(() {});
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  void _goToCall() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PatientCallScreen(patientName: widget.patientName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      appBar: AppBar(title: const Text("Emotion Check-In")),
      body: Column(
        children: [
          if (isReady)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            )
          else
            const Expanded(child: Center(child: CircularProgressIndicator())),
          const SizedBox(height: 16),
          Text("Emotion: $emotionLabel", style: const TextStyle(fontSize: 20)),
          Text(emoji, style: const TextStyle(fontSize: 42)),
          const Spacer(),
          if (_canStartCall)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.video_call),
                label: const Text("Start Video Call"),
                onPressed: _goToCall,
              ),
            ),
        ],
      ),
    );
  }
}
*/
