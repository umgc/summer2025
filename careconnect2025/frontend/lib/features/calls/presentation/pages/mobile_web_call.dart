
/*

// this code oshows the camrea but doe snot detect emotin
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:uuid/uuid.dart';
import 'emoton_bridge.dart'; // Platform-specific emotion detection

class CallScreen extends StatefulWidget {
  final String name;
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.name,
    required this.isCaller,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // RTC
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  late final String roomId;

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

  Future<void> _initRTC() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    // Signal setup here...
  }

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

    // Request both camera and microphone permissions at once
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
      setState(() {});
      await _cameraController!.startImageStream(_processFrame);
    } catch (e) {
      print("⚠️ Camera error: $e");
    }

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
  }

  void _initializeWebCamera() async {
    try {
      final mediaStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': true,
      });

      // Immediately assign the mediaStream to localRenderer.srcObject
      localRenderer.srcObject = mediaStream;

      // Force rebuild to display the video stream
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
      });

    } catch (e) {
      emotion = "Error";
      emoji = "⚠️";
      print("👁️ MLKit error: $e");
    }

    setState(() {});
    _isDetecting = false;
  }

  void _endCall() {
    // Stop the webcam stream if it is active
    if (kIsWeb) {
      final mediaStream = localRenderer.srcObject as MediaStream?;
      mediaStream?.getTracks().forEach((track) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraReady = _cameraController?.value.isInitialized ?? false;
    final displayName = widget.name.isNotEmpty ? widget.name : "patient";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCaller
            ? 'Calling ${widget.name.isNotEmpty ? widget.name : "Patient"}'
            : 'In Call with ${widget.name.isNotEmpty ? widget.name : "Patient"}'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Room ID and Emotion
            Text('Room ID: $roomId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Emotion: $emotion', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const Divider(),

            // Small camera preview as an icon or thumbnail
            _isCameraAllowed
                ? SizedBox(
              width: 80,
              height: 80,
              child: ClipOval(
                child: RTCVideoView(localRenderer, mirror: true),
              ),
            )
                : const SizedBox(height: 80), // Spacer if no camera is allowed

            // Use RTCVideoView to display the emotion detection or call status
            const SizedBox(height: 20),

            // Emotion detection when no camera
            Expanded(child: Text('Emotion: $emotion')),
            Expanded(child: Text(emoji, style: const TextStyle(fontSize: 48))),

            // End Call button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _endCall,
                child: const Text("End Call"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigo, // Indigo color for the button
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// this code has actual emotn deteciton but no cameara




/*
// live emotion detection but video feed is missing in it

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:uuid/uuid.dart';
import 'web_emotion_detector_entry.dart';
import 'dart:html' as html; // Import for WebRTC in web
import 'emoton_bridge.dart'; // Platform-specific emotion detection



class CallScreen extends StatefulWidget {
  final String name;
  final bool isCaller;
  final String userName;
  final String roomCode;

  const CallScreen({
    super.key,
    required this.name,
    required this.isCaller,
    required this.userName,
    required this.roomCode,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // RTC Variables
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  late final String roomId;

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

  Future<void> _initRTC() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    // Signal setup here...
  }

  Future<void> _initEmotionAndCamera() async {
    if (kIsWeb) {
      // Web-specific: use EmotionBridge for emotion detection
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

      // Force rebuild to display the video stream
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraReady = _cameraController?.value.isInitialized ?? false;
    final displayName = widget.name.isNotEmpty ? widget.name : "patient";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCaller
            ? 'Calling ${widget.name.isNotEmpty ? widget.name : "Patient"}'
            : 'In Call with ${widget.name.isNotEmpty ? widget.name : "Patient"}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Camera Preview on the left side
            cameraReady
                ? Container(
              width: 100,
              height: 100,
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
                : const SizedBox(height: 100), // Spacer if no camera is allowed

            // Emotion detection on the right side
            Expanded(
              child: Column(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _endCall,
          child: const Text("End Call"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,// Indigo color for the button
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            textStyle: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
*/


import 'dart:async';
import 'dart:developer';
import 'package:care_connect_app/features/calls/presentation/pages/rtc_connect/rtc_signaling_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;


import 'web_emotion_detector_entry.dart';
import 'emoton_bridge.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final bool isCaller;
  final String userName;
  final String roomCode;

  const CallScreen({
    super.key,
    required this.name,
    required this.isCaller,
    required this.userName,
    required this.roomCode,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  late final String roomId;
  late RTCSignalingService signaling;

  MediaStream? _activeLocalStream; // Preserved stream
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  String emotion = "Detecting...";
  String emoji = "🙂";

  @override
  void initState() {
    super.initState();
    roomId = const Uuid().v4();
    _initRTC();
    _initEmotionAndCamera();
  }

  Future<void> _initRTC() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    signaling = RTCSignalingService(
      roomId: widget.roomCode,
      isCaller: widget.isCaller,
      onRemoteStream: (stream) {
        setState(() {
          remoteRenderer.srcObject = stream;
        });
      },
    );

    await signaling.init();

    // Rebind preserved stream or get from signaling
    final streamFromSignaling = signaling.getLocalStream();
    localRenderer.srcObject = _activeLocalStream ?? streamFromSignaling;

    // Force repaint
    setState(() {
      localRenderer.srcObject = localRenderer.srcObject;
    });

    log("📡 Local renderer bound");
  }

  Future<void> _initEmotionAndCamera() async {
    if (kIsWeb) {
      EmotionBridge.start((detectedEmotion, detectedEmoji) {
        setState(() {
          emotion = detectedEmotion;
          emoji = detectedEmoji;
        });
      });

      try {
        final mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
          'video': true,
          'audio': true,
        });

        if (mediaStream != null) {
          _activeLocalStream = mediaStream as MediaStream?;
          localRenderer.srcObject = _activeLocalStream;
          log("🎥 Web camera stream initialized");
        } else {
          setState(() {
            emotion = "Camera Not Found";
            emoji = "🛑";
          });
        }
      } catch (e) {
        log("⚠️ Web camera error: $e");
        setState(() {
          emotion = "Error initializing webcam";
          emoji = "⚠️";
        });
      }

      return;
    }

    final camPerm = await Permission.camera.request();
    final micPerm = await Permission.microphone.request();
    if (!camPerm.isGranted || !micPerm.isGranted) {
      log("🔒 Permissions denied");
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
      await _cameraController!.startImageStream(_processFrame);
      log("📸 Mobile camera initialized");
    } catch (e) {
      log("⚠️ Camera error: $e");
    }

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
  }

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
      _updateEmotion(faces);
    } catch (e) {
      setState(() {
        emotion = "Error";
        emoji = "⚠️";
      });
      log("👁️ MLKit error: $e");
    }

    _isDetecting = false;
  }

  void _updateEmotion(List<Face> faces) {
    if (faces.isNotEmpty) {
      final smileProb = faces.first.smilingProbability ?? 0.0;
      setState(() {
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
      });
    } else {
      setState(() {
        emotion = "No face detected";
        emoji = "😐";
      });
    }
  }

  void _endCall() {
    if (kIsWeb) {
      final stream = localRenderer.srcObject as html.MediaStream?;
      stream?.getTracks().forEach((track) => track.stop());
    }

    localRenderer.srcObject = _activeLocalStream;
    remoteRenderer.srcObject = null;

    setState(() {
      emotion = "Call Ended";
      emoji = "👋";
    });

    _cameraController?.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    if (kIsWeb) EmotionBridge.stop();
    _cameraController?.dispose();
    _faceDetector?.close();
    localRenderer.dispose();
    remoteRenderer.dispose();
    signaling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraReady = _cameraController?.value.isInitialized ?? true;
    final displayName = widget.name.isNotEmpty ? widget.name : "Patient";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCaller
            ? 'Calling $displayName'
            : 'In Call with $displayName'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 180,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: RTCVideoView(localRenderer, mirror: true),
                  ),
                ),
                const SizedBox(width: 16),
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
          Expanded(child: RTCVideoView(remoteRenderer)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _endCall,
          child: const Text("End Call"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
