// lib/features/calls/presentation/pages/mobile_emotion_detector.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MobileEmotionDetector extends StatefulWidget {
  final bool showPreview;

  const MobileEmotionDetector({Key? key, this.showPreview = true, required CameraController cameraController, required void Function(String emj, String label) onEmotionDetected}) : super(key: key);

  @override
  State<MobileEmotionDetector> createState() => _MobileEmotionDetectorState();
}

class _MobileEmotionDetectorState extends State<MobileEmotionDetector> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  String _emotion = "Neutral";
  String _emoji = "😐";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    _cameraController.startImageStream(_processCameraImage);

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final inputImage = _convertCameraImage(image, _cameraController.description.sensorOrientation);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final smilingProb = face.smilingProbability ?? 0.0;

        setState(() {
          if (smilingProb > 0.75) {
            _emotion = "Happy";
            _emoji = "😄";
          } else if (smilingProb < 0.25) {
            _emotion = "Sad";
            _emoji = "☹️";
          } else {
            _emotion = "Neutral";
            _emoji = "😐";
          }
        });
      }
    } catch (e) {
      // Handle error silently or print
    }

    _isDetecting = false;
  }

  InputImage _convertCameraImage(CameraImage image, int rotation) {
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final inputImageRotation = InputImageRotationValue.fromRawValue(rotation) ?? InputImageRotation.rotation0deg;
    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: inputImageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showPreview || !_cameraController.value.isInitialized) {
      // Show just the emotion text, no camera preview
      return Center(
        child: Text(
          "Emotion: $_emotion $_emoji",
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _cameraController.value.aspectRatio,
          child: CameraPreview(_cameraController),
        ),
        const SizedBox(height: 10),
        Text(
          "Emotion: $_emotion $_emoji",
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
