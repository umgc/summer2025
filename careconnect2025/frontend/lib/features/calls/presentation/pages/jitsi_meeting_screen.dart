// jitsi_meeting_screen.dart
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiMeetingScreen extends StatefulWidget {
  final String roomName;
  const JitsiMeetingScreen({super.key, required this.roomName});

  @override
  State<JitsiMeetingScreen> createState() => _JitsiMeetingScreenState();
}

class _JitsiMeetingScreenState extends State<JitsiMeetingScreen> {
  final JitsiMeet _jitsiMeet = JitsiMeet();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _joinMeeting());
  }

  Future<void> _joinMeeting() async {
    var options = JitsiMeetConferenceOptions(
      room: widget.roomName,
      serverURL: "https://meet.jit.si",
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
      },
    );

    await _jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telehealth Meeting'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
