import 'package:care_connect_app/widgets/real_video_call_widget.dart';
import 'package:flutter/material.dart';

class VideoCallTestPage extends StatefulWidget {
  const VideoCallTestPage({super.key});

  @override
  State<VideoCallTestPage> createState() => _VideoCallTestPageState();
}

class _VideoCallTestPageState extends State<VideoCallTestPage> {
  final TextEditingController _channelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set a default channel name for testing
    _channelController.text =
        'test_channel_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareConnect Video Call Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🎥 Real Video Calling Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            const Text(
              'This will start a REAL video call using Agora SDK',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _channelController,
              decoration: const InputDecoration(
                labelText: 'Channel Name',
                hintText: 'Enter channel name for the call',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _startVideoCall,
              icon: const Icon(Icons.video_call),
              label: const Text('Start Video Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _startAudioCall,
              icon: const Icon(Icons.call),
              label: const Text('Start Audio Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 How to Test:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('1. Click "Start Video Call" or "Start Audio Call"'),
                    Text('2. Allow camera and microphone permissions'),
                    Text('3. You should see your own video feed'),
                    Text('4. Share the channel name with another user'),
                    Text('5. They can join using the same channel name'),
                    SizedBox(height: 10),
                    Text(
                      '✨ Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• Real-time video and audio'),
                    Text('• Works on web, iOS, and Android'),
                    Text('• Built-in controls (mute, camera toggle)'),
                    Text('• Multiple participants support'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startVideoCall() {
    if (_channelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a channel name')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RealVideoCallWidget(
          callId: _channelController.text.trim(),
          currentUserId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          currentUserName: 'Test User',
          otherUserId: 'other_user',
          otherUserName: 'Other User',
          isVideoCall: true,
        ),
      ),
    );
  }

  void _startAudioCall() {
    if (_channelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a channel name')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RealVideoCallWidget(
          callId: _channelController.text.trim(),
          currentUserId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          currentUserName: 'Test User',
          otherUserId: 'other_user',
          otherUserName: 'Other User',
          isVideoCall: false,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }
}
