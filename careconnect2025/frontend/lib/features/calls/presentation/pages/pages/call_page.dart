
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // For WriteBuffer
import 'dart:ui' as ui; // For platformViewRegistry
import 'dart:html' as html; // For dart:html for web-specific operations
import 'package:uuid/uuid.dart';
import 'dart:ui_web' as  ui; //to rem ove the ui.platforviereistyr error on console


class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.patientName,
    this.roomId, // This roomId is now primarily for initial setup, but not the definitive Jitsi room
    required this.userRole,
    required this.caregiverId, // This will now be the basis for the Jitsi room
    required this.displayName,
  });

  final String patientName;
  final String? roomId; // This is now less critical for Jitsi room itself
  final String userRole;
  final String caregiverId; // The ID to form the consistent Jitsi room
  final String displayName;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // We no longer need 'late final String roomCode;' here if we're consistently
  // deriving it in _preCallView based on caregiverId.
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool callStarted = false;

  late final bool isCaregiver;

  String myEmotion = "Detecting...";
  String myEmoji = "🙂";
  String peerEmotion = "Detecting...";
  String peerEmoji = "🙂";

  @override
  void initState() {
    super.initState();

    // Robust role detection
    final normalizedRole = widget.userRole.trim().toLowerCase();
    isCaregiver = normalizedRole == 'caregiver';

    // Listen for messages from the Jitsi iframe (or other participants via postMessage)
    html.window.onMessage.listen(_onPeerEmotionReceived);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  void _onPeerEmotionReceived(html.MessageEvent event) {
    final data = event.data;
    // Ensure the received data is a Map and contains the expected keys
    if (data is Map &&
        data.containsKey('emotion') &&
        data.containsKey('emoji')) {
      setState(() {
        peerEmotion = data['emotion'];
        peerEmoji = data['emoji'];
      });
    }
  }

  Future<void> _startCall(String roomCodeToJoin, String displayName) async {
    setState(() => callStarted = true);

    // Encode display name safely for URL
    final encodedName = Uri.encodeComponent(displayName);

    // Construct the Jitsi URL with all necessary parameters
    final jitsiUrl =
        'https://meet.jit.si/$roomCodeToJoin'
        '#config.startWithVideoMuted=false' // Start with video on
        '&config.startWithAudioMuted=false' // Start with audio on
        '&config.disableModeratorIndicator=true' // Hides moderator star icon
        '&config.enableLobby=false' // CRITICAL: Disables the lobby, allowing direct join
        '&interfaceConfig.SHOW_JITSI_WATERMARK=false' // Removes Jitsi watermark
        '&userInfo.displayName=$encodedName'
        '&config.lockRoom=false';
    // Sets participant's display name

    final iframe = html.IFrameElement()
      ..src = jitsiUrl
      ..allow = 'camera; microphone; fullscreen' // Permissions for the iframe
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%';

    // Register iframe as a platform view for Flutter web
    //ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('jitsi-view', (_) => iframe);

    // Initialize camera for emotion detection (if applicable to your app's flow)
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        // Get available cameras and select the front camera
        final cameras = await availableCameras();
        final front = cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first, // Fallback if front camera not found
        );

        _cameraController = CameraController(front, ResolutionPreset.medium);
        await _cameraController!.initialize();
        // Start image stream for continuous frame processing
        await _cameraController!.startImageStream(_processFrame);

        // Initialize FaceDetector
        _faceDetector = FaceDetector(
          options: FaceDetectorOptions(enableClassification: true),
        );

        setState(() {}); // Update UI once camera is ready
      } catch (e) {
        print("Error initializing camera: $e");
        // Handle camera initialization errors (e.g., show a message to the user)
      }
    } else {
      // Handle camera permission denied
      print("Camera permission denied");
      // You might want to show a dialog or message to the user here
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isDetecting || _faceDetector == null || _cameraController == null || !_cameraController!.value.isInitialized) return;
    _isDetecting = true;

    try {
      // Convert CameraImage to InputImage for ML Kit
      final WriteBuffer buffer = WriteBuffer();
      for (final plane in image.planes) {
        buffer.putUint8List(plane.bytes);
      }
      final bytes = buffer.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          // Adjust rotation if necessary based on your camera and device orientation
          rotation: InputImageRotation.rotation0deg, // Assuming default, adjust if camera is rotated
          format: InputImageFormat.nv21, // Common format for camera images
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        final smileProb = faces.first.smilingProbability ?? 0.0;
        if (smileProb > 0.8) {
          myEmotion = "Happy";
          myEmoji = "😄";
        } else if (smileProb > 0.3) {
          myEmotion = "Neutral";
          myEmoji = "🙂";
        } else {
          myEmotion = "Sad";
          myEmoji = "☹️";
        }
      } else {
        myEmotion = "No Face";
        myEmoji = "❓";
      }

      // Post emotion data to other participants (via parent window for iframe)
      html.window.postMessage({'emotion': myEmotion, 'emoji': myEmoji}, '*');
    } catch (e) {
      print("Error processing frame: $e");
      myEmotion = "Error";
      myEmoji = "⚠️";
    } finally {
      setState(() {});
      _isDetecting = false;
    }
  }

  // Widget to display emotion panels
  Widget _emotionPanel(String title, String emoji, String emotion) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueGrey.shade900,
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 8),
          Text(emoji, style: const TextStyle(fontSize: 40)),
          Text(emotion, style: const TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  // Widget displayed before the call starts
  Widget _preCallView() {

    final String consistentRoomCode = 'room-${widget.caregiverId}';
    final displayName = widget.displayName;

    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.video_call),
        label: const Text("Start Call"),
        onPressed: () => _startCall(consistentRoomCode, displayName),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Helper function to build emotion panels based on user role
    Widget buildEmotionPanel() {
      if (isCaregiver) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _emotionPanel("Patient Emotion", myEmoji, myEmotion), // Caregiver's own camera
            const SizedBox(height: 24),
            _emotionPanel("Caregiver Emotion", peerEmoji, peerEmotion), // Peer (Patient) data
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _emotionPanel("Caregiver Emotion", myEmoji, myEmotion), // Patient's own camera
            const SizedBox(height: 24),
            _emotionPanel("Patient Emotion", peerEmoji, peerEmotion), // Peer (Caregiver) data
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Call with ${widget.patientName}")),
      body: callStarted
          ? Row(
        children: [
          // Emotion detection panel (fixed width)
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.black,
            child: buildEmotionPanel(),
          ),
          // Jitsi Meet iframe (takes remaining space)
          const Expanded(
            child: HtmlElementView(viewType: 'jitsi-view'),
          ),
        ],
      )
          : _preCallView(), // Show "Start Call" button initially
    );
  }
}