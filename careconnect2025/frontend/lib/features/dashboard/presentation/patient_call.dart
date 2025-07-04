
 // Below code is without the emotion detection: It is just the regular video/call
 import 'package:flutter/material.dart';
 import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
 import 'package:permission_handler/permission_handler.dart';

 class CallScreen extends StatefulWidget {
   final String userName;
   final String roomCode;

   const CallScreen({super.key, required this.userName, required this.roomCode});

   @override
   State<CallScreen> createState() => _CallScreenState();
 }

 class _CallScreenState extends State<CallScreen> {
   final JitsiMeet _jitsiMeet = JitsiMeet();

   @override
   void initState() {
     super.initState();
     _initiateVideoCall();
   }

   Future<void> _initiateVideoCall() async {
     final permissions = await [
       Permission.camera,
       Permission.microphone,
     ].request();

     if (permissions[Permission.camera]!.isGranted &&
         permissions[Permission.microphone]!.isGranted) {
       final options = JitsiMeetConferenceOptions(
         room: widget.roomCode,
         serverURL: "https://meet.jit.si",
         userInfo: JitsiMeetUserInfo(displayName: widget.userName),
         configOverrides: {
           "startWithVideoMuted": false,
           "startWithAudioMuted": false,
         },
         featureFlags: {
           "welcomepage.enabled": false,
           "pip.enabled": false,
         },
       );

       try {
         await _jitsiMeet.join(options);
         debugPrint("📞 Joined video call successfully");
       } catch (error) {
         debugPrint("❌ Failed to join video call: $error");
       }
     } else {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Camera and Microphone permissions are required.")),
       );
       Navigator.pop(context);
     }
   }

   @override
   void dispose() {
     _jitsiMeet.hangUp();
     super.dispose();
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("In Call: ${widget.userName}"),
         actions: [
           IconButton(
             onPressed: () {
               _jitsiMeet.hangUp();
               Navigator.pop(context);
             },
             icon: const Icon(Icons.call_end, color: Colors.red),
           ),
         ],
       ),
       body: const Center(child: Text("Connecting to video call...")),
     );
   }
 }



 /*
// Look this for the emotion detection: not opening video/call
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class PatientEmotionCallScreen extends StatefulWidget {
  final String patientName;

  const PatientEmotionCallScreen({super.key, required this.patientName});

  @override
  State<PatientEmotionCallScreen> createState() => _PatientEmotionCallScreenState();
}

class _PatientEmotionCallScreenState extends State<PatientEmotionCallScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _canStartCall = false;
  bool _inCall = false;

  String emotionLabel = "Detecting...";
  String emoji = "";

  final JitsiMeet _jitsi = JitsiMeet();
  late String roomName;

  @override
  void initState() {
    super.initState();
    roomName = "careconnect_${widget.patientName.replaceAll(' ', '_')}";
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_detectEmotion);

    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(enableClassification: true, performanceMode: FaceDetectorMode.accurate),
    );

    setState(() {});
  }

  Future<void> _detectEmotion(CameraImage image) async {
    if (_isDetecting || _faceDetector == null || _inCall) return;
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

  Future<void> _startVideoCall() async {
    await Permission.microphone.request();

    if (!await Permission.microphone.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission is required")),
      );
      return;
    }

    try {
      final options = JitsiMeetConferenceOptions(
        room: roomName,
        serverURL: "https://meet.jit.si",
        userInfo: JitsiMeetUserInfo(displayName: widget.patientName),
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
        },
        featureFlags: {
          "welcomepage.enabled": false,
          "call-integration.enabled": false,
          "pip.enabled": false,
        },
      );

      setState(() => _inCall = true);
      await _cameraController?.dispose();
      await _jitsi.join(options);
    } catch (e) {
      debugPrint("Call Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Call failed: $e")));
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    _jitsi.hangUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _cameraController != null && _cameraController!.value.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: Text("Patient: ${widget.patientName}"),
        actions: _inCall
            ? [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () {
              _jitsi.hangUp();
              setState(() => _inCall = false);
            },
          ),
        ]
            : [],
      ),
      body: Column(
        children: [
          if (!_inCall && isReady)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            )
          else if (!_inCall)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_inCall) ...[
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
                  onPressed: _startVideoCall,
                ),
              ),
          ]
        ],
      ),
    );
  }
}
*/


