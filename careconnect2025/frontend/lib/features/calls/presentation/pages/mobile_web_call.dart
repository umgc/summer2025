import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'web_emotion_detector.dart';

class CallScreen extends StatefulWidget {
  final String patientName;
  final String roomId;
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.patientName,
    required this.roomId,
    required this.isCaller, // True if caregiver is calling
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // Camera and face detection variables
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isCameraOn = true;  // Tracks whether the camera is on

  // Emotion and face status variables for caregiver and patient
  String caregiverEmotion = "Detecting...";
  String caregiverFaceStatus = "🙂";
  String patientEmotion = "Detecting...";
  String patientFaceStatus = "🙂";

  @override
  void initState() {
    super.initState();
    // Initialize camera and face detection for non-web platforms
    if (!kIsWeb) {
      _initializeCameraAndDetection();
    }
  }

  // Method to initialize the camera and face detection
  Future<void> _initializeCameraAndDetection() async {
    // Request camera and microphone permissions
    await [Permission.camera, Permission.microphone].request();

    // Get available cameras and select the front camera
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // Initialize the CameraController
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Initialize the camera and start image stream for face detection
    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processFrame);

    // Initialize the FaceDetector
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    // Refresh UI after camera is initialized
    setState(() {});
  }

  // Method to process each frame for face detection
  void _processFrame(CameraImage image) async {
    if (_isDetecting || _faceDetector == null) return;

    _isDetecting = true;

    try {
      // Convert camera image to byte data
      final WriteBuffer buffer = WriteBuffer();
      for (Plane plane in image.planes) {
        buffer.putUint8List(plane.bytes);
      }
      final bytes = buffer.done().buffer.asUint8List();

      // Create InputImage for face detection
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      // Detect faces
      final faces = await _faceDetector!.processImage(inputImage);

      // Update emotion label and face status based on detection
      if (faces.isEmpty) {
        caregiverEmotion = "No face";
        caregiverFaceStatus = "❓";
      } else {
        final smile = faces.first.smilingProbability ?? 0.0;
        if (smile > 0.8) {
          caregiverEmotion = "Happy";
          caregiverFaceStatus = "😄";
        } else if (smile > 0.3) {
          caregiverEmotion = "Neutral";
          caregiverFaceStatus = "🙂";
        } else {
          caregiverEmotion = "Sad";
          caregiverFaceStatus = "☹️";
        }
      }
    } catch (_) {
      caregiverEmotion = "Error";
      caregiverFaceStatus = "⚠️";
    }

    // Refresh UI after processing frame
    setState(() {});
    _isDetecting = false;
  }

  @override
  void dispose() {
    // Dispose of camera and face detector resources
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  // Method to toggle camera on/off
  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    if (_isCameraOn) {
      _initializeCameraAndDetection();
    } else {
      _cameraController?.stopImageStream();
    }
  }

  // Build the UI based on whether the camera is initialized or not
  Widget _buildEmotionView() {
    if (kIsWeb) {
      return const WebEmotionDetector();
    }

    final ready = _cameraController != null && _cameraController!.value.isInitialized;

    if (!ready) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_cameraController!),
        Positioned(
          top: 30,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.isCaller)  // Caregiver sees the patient's emotion
                Text(
                  "Patient Emotion: $patientEmotion",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              const SizedBox(height: 6),
              Text(caregiverFaceStatus, style: const TextStyle(fontSize: 48)), // Caregiver’s face status
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Call with ${widget.patientName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: Icon(
              _isCameraOn ? Icons.camera_alt : Icons.camera_alt_outlined,
              color: Colors.white,
            ),
            onPressed: _toggleCamera, // Toggles the camera on/off
          ),
        ],
      ),
      body: _buildEmotionView(),
    );
  }
}
