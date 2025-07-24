/*import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pages/web_emotion_detector_entry.dart';


class PatientCallScreen extends StatefulWidget {
  final String patientName;
  final String roomName;
  final String caregiverName;

  const PatientCallScreen({
    super.key,
    required this.patientName,
    required this.roomName,
    required this.caregiverName,
  });

  @override
  State<PatientCallScreen> createState() => _PatientCallScreenState();
}

class _PatientCallScreenState extends State<PatientCallScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isCameraOn = true;

  String patientEmotion = "Detecting...";
  String patientEmoji = "🙂";

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeCameraAndDetection();
    }
  }

  Future<void> _initializeCameraAndDetection() async {
    await [Permission.camera, Permission.microphone].request();

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processFrame);

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    setState(() {});
  }

  void _processFrame(CameraImage image) async {
    if (_isDetecting || _faceDetector == null) return;

    _isDetecting = true;

    try {
      final WriteBuffer buffer = WriteBuffer();
      for (Plane plane in image.planes) {
        buffer.putUint8List(plane.bytes);
      }
      final bytes = buffer.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector!.processImage(inputImage);
      final smile = faces.isEmpty ? 0.0 : faces.first.smilingProbability ?? 0.0;

      if (smile > 0.8) {
        patientEmotion = "Happy";
        patientEmoji = "😄";
      } else if (smile > 0.3) {
        patientEmotion = "Neutral";
        patientEmoji = "🙂";
      } else {
        patientEmotion = "Sad";
        patientEmoji = "☹️";
      }
    } catch (_) {
      patientEmotion = "Error";
      patientEmoji = "⚠️";
    }

    setState(() {});
    _isDetecting = false;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

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

  Widget _buildEmotionView() {
    if (kIsWeb) {
      return WebEmotionDetector(onEmotionDetected: (_, __) {});
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
              Text(
                "Patient Emotion: $patientEmotion",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(patientEmoji, style: const TextStyle(fontSize: 48)),
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
        title: Text("Call with ${widget.caregiverName}"),
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
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: _buildEmotionView(),
    );
  }
}
*/


// integrating the rtc in the patiient side too


import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html; // Import for WebRTC in web

import '../pages/emotion_bridge_stub.dart';
import '../pages/rtc_connect/rtc_signaling_service.dart';


class PatientCallScreen extends StatefulWidget {
  final String caregiverName;
  final bool isCaller;
  final String userName;
  final String roomCode;

  const PatientCallScreen({
    super.key,
    required this.caregiverName,
    required this.isCaller,
    required this.userName,
    required this.roomCode, required String patientName, required String roomId,
  });

  @override
  _PatientCallScreenState createState() => _PatientCallScreenState();
}

class _PatientCallScreenState extends State<PatientCallScreen> {
  // RTC Variables
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  late final String roomId;
  late final RTCSignalingService signaling;

  // Camera + Emotion
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  List<Face> _faces = [];

  String emotion = "Detecting...";
  String emoji = "🙂";
  bool _isCameraAllowed = false;  // Track if camera access is allowed

  @override
  void initState() {
    super.initState();
    roomId = const Uuid().v4();
    _initRTC();
    _initEmotionAndCamera();
  }

  // Initialize RTC and signaling
  Future<void> _initRTC() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    signaling = RTCSignalingService(
      roomId: widget.roomCode,
      isCaller: widget.isCaller,
      onRemoteStream: (s) => setState(() {
        remoteRenderer.srcObject = s;
      }),
    );

    // Initialize signaling service
    await signaling.init();

    // If the caller is true, initiate a local stream for the caregiver
    if (widget.isCaller) {
      // Ensure the local renderer receives the stream immediately
      final localStream = signaling.getLocalStream();
      localRenderer.srcObject = localStream;
      print("Local stream assigned: $localStream"); // Debug log
      setState(() {});
    }
  }

  // Initialize Emotion Detection and Camera
  Future<void> _initEmotionAndCamera() async {
    if (kIsWeb) {
      EmotionBridge.start((detectedEmotion, detectedEmoji) {
        setState(() {
          emotion = detectedEmotion;
          emoji = detectedEmoji;
        });
      });
      _initializeWebCamera();
      return;
    }

    // Mobile: Request both camera and microphone permissions at once
    final camPerm = await Permission.camera.request();
    final micPerm = await Permission.microphone.request();

    // Check if both permissions are granted
    if (!camPerm.isGranted || !micPerm.isGranted) {
      print("🔒 Permissions denied");
      return;
    }

    final cameras = await availableCameras();
    final frontCam = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCam,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraAllowed = true;  // Camera initialized successfully
      });
      await _cameraController!.startImageStream(_processFrame);
    } catch (e) {
      print("⚠️ Camera error: $e");
    }

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
  }

  // Initialize Web Camera for Web
  void _initializeWebCamera() async {
    try {
      final mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': true,
        'audio': true,
      });

      // Immediately assign the mediaStream to localRenderer.srcObject
      localRenderer.srcObject = mediaStream as MediaStream?;
      setState(() {});
      print("Webcam stream initialized successfully!");

    } catch (e) {
      print("Error initializing webcam: $e");
      setState(() {
        emotion = "Error initializing webcam";
        emoji = "⚠️";
      });
    }
  }

  // Process each frame for face detection and emotion recognition
  void _processFrame(CameraImage image) async {
    if (_isDetecting || _faceDetector == null) return;
    _isDetecting = true;

    try {
      await Future.delayed(const Duration(milliseconds: 100));

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
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector!.processImage(inputImage);
      setState(() {
        _faces = faces; // Save detected faces for painting
        _updateEmotion(faces); // Update emotion based on face detection
      });

    } catch (e) {
      emotion = "Error";
      emoji = "⚠️";
      print("👁️ MLKit error: $e");
    }

    setState(() {});
    _isDetecting = false;
  }

  // Update emotion and emoji based on face recognition
  void _updateEmotion(List<Face> faces) {
    if (faces.isNotEmpty) {
      final smileProb = faces.first.smilingProbability ?? 0.0;
      if (smileProb > 0.8) {
        emotion = "Happy";
        emoji = "😄";
      } else if (smileProb > 0.3) {
        emotion = "Neutral";
        emoji = "🙂";
      } else {
        emotion = "Sad";
        emoji = "☹️";
      }
    } else {
      emotion = "No face detected";
      emoji = "😐";
    }
  }

  // End call and clean up resources
  void _endCall() {
    // Stop the webcam stream if it is active
    if (kIsWeb) {
      final mediaStream = localRenderer.srcObject as html.MediaStream?;
      mediaStream?.getTracks()?.forEach((track) {
        track.stop();
      });
    }

    // Stop the camera preview and clear localRenderer
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    // Set the emotion and emoji for "call ended"
    setState(() {
      emotion = "Call Ended";
      emoji = "👋";
    });

    // Dispose of resources
    _cameraController?.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();

    // Optionally, you can also close the page or do any additional clean-up here
    Navigator.of(context).pop();  // Close the call screen if needed
  }

  @override
  void dispose() {
    if (kIsWeb) EmotionBridge.stop();
    localRenderer.dispose();
    remoteRenderer.dispose();
    _cameraController?.dispose();
    _faceDetector?.close();
    signaling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraReady = _cameraController?.value.isInitialized ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCaller
            ? 'Calling ${widget.caregiverName.isNotEmpty ? widget.caregiverName : "Caregiver"}'
            : 'In Call with ${widget.caregiverName.isNotEmpty ? widget.caregiverName : "Caregiver"}'),
      ),
      body: Column(
        children: [
          // Top Section - Local Video Feed + Emotion Detection
          Container(
            padding: const EdgeInsets.all(16),
            height: 180,
            child: Row(
              children: [
                cameraReady
                    ? Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: RTCVideoView(localRenderer, mirror: true),
                  ),
                )
                    : const SizedBox(height: 120), // Spacer if no camera feed

                // Emotion & Emoji
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emotion: $emotion',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Remote Video Feed Section
          Expanded(
            child: Center(
              child: RTCVideoView(remoteRenderer),
            ),
          ),
          // End Call Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _endCall,
              child: const Text('End Call'),
            ),
          ),
        ],
      ),
    );
  }
}




