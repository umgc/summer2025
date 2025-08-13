abstract class VideoCallServiceBase {
  Future<void> initializeService();
  Future<bool> checkUserAvailability(String userId);
  Future<Map<String, dynamic>> initiateCall({
    required String callId,
    required String callerId,
    required String recipientId,
    required bool isVideoCall,
  });
}

// You can add more methods as needed for your app's requirements.
