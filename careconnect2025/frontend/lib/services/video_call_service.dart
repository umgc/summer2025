// Platform-aware VideoCallService that provides static methods
// This acts as a facade and delegates to platform-specific implementations

// Conditional imports to prevent Agora from loading on web
import 'video_call_service_mobile.dart'
    if (dart.library.html) 'video_call_service_web.dart'
    as mobile;

class VideoCallService {
  // Static methods that provide a unified interface
  // The conditional imports above ensure the right implementation is used

  static Future<bool> initializeService() async {
    return await mobile.VideoCallService.initializeService();
  }

  static Future<bool> checkUserAvailability(String userId) async {
    return await mobile.VideoCallService.checkUserAvailability(userId);
  }

  static Future<Map<String, dynamic>> initiateCall({
    required String callId,
    required String callerId,
    required String recipientId,
    required bool isVideoCall,
  }) async {
    // The conditional import will choose the right implementation
    return await mobile.VideoCallService.initiateCall(
      callerId: callerId,
      recipientId: recipientId,
      isVideoCall: isVideoCall,
    );
  }

  static Future<bool> joinCall(String callId, String userId) async {
    return await mobile.VideoCallService.joinCall(callId, userId);
  }

  static Future<void> endCallStatic(String callId, String userId) async {
    await mobile.VideoCallService.endCallStatic(callId, userId);
  }
}
