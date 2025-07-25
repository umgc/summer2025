import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/hybrid_video_call_service.dart';
import '../services/backend_api_service.dart';
import '../config/theme/app_theme.dart';

class HybridVideoCallWidget extends StatefulWidget {
  final String userId;
  final String callId;
  final String? recipientId;
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final bool isInitiator;

  // Real user identification data
  final String? userEmail;
  final String? userPhone;
  final String? userName;
  final String? recipientEmail;
  final String? recipientPhone;
  final String? recipientName;

  const HybridVideoCallWidget({
    super.key,
    required this.userId,
    required this.callId,
    this.recipientId,
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
    this.isInitiator = false,

    // Real user data parameters
    this.userEmail,
    this.userPhone,
    this.userName,
    this.recipientEmail,
    this.recipientPhone,
    this.recipientName,
  });

  @override
  _HybridVideoCallWidgetState createState() => _HybridVideoCallWidgetState();
}

class _HybridVideoCallWidgetState extends State<HybridVideoCallWidget> {
  final HybridVideoCallService _videoCallService = HybridVideoCallService();
  Widget? _callWidget;
  bool _isLoading = true;
  String? _error;
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      _callStartTime = DateTime.now();

      // Send call invitation via backend (for push notifications)
      if (widget.isInitiator && widget.recipientId != null) {
        await BackendApiService.sendVideoCallInvitation(
          callerId: widget.userId,
          callerName: widget.userName ?? 'Unknown User',
          recipientId: widget.recipientId!,
          recipientName: widget.recipientName ?? 'Unknown Recipient',
          callId: widget.callId,
          isVideoCall: widget.isVideoEnabled,
        );
      }

      // Initialize the service
      await _videoCallService.initialize(
        userId: widget.userId,
        onRemoteStreamReceived: (stream) {
          print('Remote stream received');
          // Handle remote stream if needed
        },
        onCallEnded: () {
          print('Call ended');
          _logCallToBackend(wasAnswered: true);
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );

      // Start or join the call
      Widget callWidget;
      if (widget.isInitiator && widget.recipientId != null) {
        callWidget = await _videoCallService.startCall(
          callId: widget.callId,
          recipientId: widget.recipientId!,
          isVideoEnabled: widget.isVideoEnabled,
          isAudioEnabled: widget.isAudioEnabled,
        );
      } else {
        callWidget = await _videoCallService.joinCall(
          callId: widget.callId,
          isVideoEnabled: widget.isVideoEnabled,
          isAudioEnabled: widget.isAudioEnabled,
        );
      }

      setState(() {
        _callWidget = callWidget;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoCallService.dispose();
    super.dispose();
  }

  /// Log call to backend for analytics and history
  Future<void> _logCallToBackend({required bool wasAnswered}) async {
    if (_callStartTime == null) return;

    await BackendApiService.logVideoCall(
      callId: widget.callId,
      callerId: widget.userId,
      callerName: widget.userName ?? 'Unknown User',
      recipientId: widget.recipientId ?? 'unknown',
      recipientName: widget.recipientName ?? 'Unknown Recipient',
      startTime: _callStartTime!,
      endTime: DateTime.now(),
      wasAnswered: wasAnswered,
      isVideoCall: widget.isVideoEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppTheme.videoCallBackgroundDarkTheme
        : AppTheme.videoCallBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          kIsWeb ? 'Video Call (WebRTC)' : 'Video Call (Agora)',
          style: TextStyle(color: AppTheme.videoCallText),
        ),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: AppTheme.videoCallText),
        actions: [
          // Show real user info
          if (widget.recipientName != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  'Calling: ${widget.recipientName}',
                  style: const TextStyle(
                    color: AppTheme.videoCallTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.call_end,
              color: isDarkMode
                  ? AppTheme.videoCallEndCallDarkTheme
                  : AppTheme.videoCallEndCall,
            ),
            onPressed: () async {
              await _videoCallService.endCall();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.videoCallText),
            const SizedBox(height: 16),
            const Text(
              kIsWeb
                  ? 'Initializing WebRTC call...'
                  : 'Initializing Agora call...',
              style: TextStyle(color: AppTheme.videoCallText),
            ),
            const SizedBox(height: 8),
            // Show real user info during loading
            if (widget.recipientName != null || widget.recipientEmail != null)
              Column(
                children: [
                  Text(
                    'Calling: ${widget.recipientName ?? 'Unknown'}',
                    style: const TextStyle(
                      color: AppTheme.videoCallTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.recipientEmail != null)
                    Text(
                      'Email: ${widget.recipientEmail}',
                      style: const TextStyle(
                        color: AppTheme.videoCallTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                  if (widget.recipientPhone != null)
                    Text(
                      'Phone: ${widget.recipientPhone}',
                      style: const TextStyle(
                        color: AppTheme.videoCallTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
          ],
        ),
      );
    }

    if (_error != null) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              color: isDarkMode ? AppTheme.errorDarkTheme : AppTheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: AppTheme.videoCallText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    if (_callWidget != null) {
      return Stack(
        children: [
          _callWidget!,
          // Add platform indicator
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.videoCallBackground.withOpacity(0.54),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                kIsWeb ? 'WebRTC' : 'Agora',
                style: TextStyle(color: AppTheme.videoCallText, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    }

    return const Center(
      child: Text(
        'No call widget available',
        style: TextStyle(color: AppTheme.videoCallText),
      ),
    );
  }
}

// Test page for the hybrid video calling with real user data
class VideoCallTestPage extends StatefulWidget {
  const VideoCallTestPage({super.key});

  @override
  _VideoCallTestPageState createState() => _VideoCallTestPageState();
}

class _VideoCallTestPageState extends State<VideoCallTestPage> {
  final TextEditingController _callIdController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _recipientIdController = TextEditingController();

  // Real user data controllers based on your API structure
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _recipientEmailController =
      TextEditingController();
  final TextEditingController _recipientPhoneController =
      TextEditingController();
  final TextEditingController _recipientNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set realistic default values based on your backend data
    _callIdController.text = 'call_${DateTime.now().millisecondsSinceEpoch}';
    _userIdController.text = '15'; // Caregiver ID from your API
    _recipientIdController.text = '10'; // Patient ID from your API

    // Real data from your curl commands
    _userEmailController.text = 'carepatient2025@yopmail.com';
    _userPhoneController.text = '2012345670';
    _userNameController.text = 'test mama';
    _recipientEmailController.text = 'patienttar2025@yopmail.com';
    _recipientPhoneController.text = '2012345671';
    _recipientNameController.text = 'patient patient';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hybrid Video Call Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kIsWeb
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.successDarkTheme.withOpacity(0.1)
                          : AppTheme.success.withOpacity(0.1))
                    : (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.primaryDarkTheme.withOpacity(0.1)
                          : AppTheme.primary.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Platform',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kIsWeb ? 'Web (using WebRTC)' : 'Mobile (using Agora)',
                    style: TextStyle(
                      fontSize: 16,
                      color: kIsWeb
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.successDarkTheme
                                : AppTheme.success)
                          : (Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.primaryDarkTheme
                                : AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input fields for IDs
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'Your User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _callIdController,
              decoration: const InputDecoration(
                labelText: 'Call ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _recipientIdController,
              decoration: const InputDecoration(
                labelText: 'Recipient ID (for starting call)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Real user data fields
            const Text(
              'Your Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _userEmailController,
              decoration: const InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _userPhoneController,
              decoration: const InputDecoration(
                labelText: 'Your Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Recipient Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _recipientNameController,
              decoration: const InputDecoration(
                labelText: 'Recipient Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _recipientEmailController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _recipientPhoneController,
              decoration: const InputDecoration(
                labelText: 'Recipient Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            ElevatedButton(
              onPressed: () => _startCall(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.successDarkTheme
                    : AppTheme.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Start Video Call',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.textDarkThemeDark
                      : AppTheme.textLight,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => _startCall(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryDarkTheme
                    : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Join Existing Call',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.textDarkThemeDark
                      : AppTheme.textLight,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions (Using Real Patient/Caregiver Data):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. For web: Uses WebRTC (browser-based calling)'),
                  Text(
                    '2. For mobile: Uses Agora with App ID: 6dd0e8e31625434e8dd185bcb075cd79',
                  ),
                  Text('3. Real user emails/phones are shown during calls'),
                  Text('4. Default data matches your backend API structure'),
                  Text('5. Caregiver: carepatient2025@yopmail.com (ID: 15)'),
                  Text('6. Patient: patienttar2025@yopmail.com (ID: 10)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCall(bool isInitiator) {
    if (_callIdController.text.isEmpty || _userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Call ID and User ID')),
      );
      return;
    }

    if (isInitiator && _recipientIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Recipient ID to start a call'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HybridVideoCallWidget(
          userId: _userIdController.text,
          callId: _callIdController.text,
          recipientId: isInitiator ? _recipientIdController.text : null,
          isInitiator: isInitiator,

          // Pass real user data
          userName: _userNameController.text.isEmpty
              ? null
              : _userNameController.text,
          userEmail: _userEmailController.text.isEmpty
              ? null
              : _userEmailController.text,
          userPhone: _userPhoneController.text.isEmpty
              ? null
              : _userPhoneController.text,
          recipientName: _recipientNameController.text.isEmpty
              ? null
              : _recipientNameController.text,
          recipientEmail: _recipientEmailController.text.isEmpty
              ? null
              : _recipientEmailController.text,
          recipientPhone: _recipientPhoneController.text.isEmpty
              ? null
              : _recipientPhoneController.text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callIdController.dispose();
    _userIdController.dispose();
    _recipientIdController.dispose();
    _userEmailController.dispose();
    _userPhoneController.dispose();
    _userNameController.dispose();
    _recipientEmailController.dispose();
    _recipientPhoneController.dispose();
    _recipientNameController.dispose();
    super.dispose();
  }
}
