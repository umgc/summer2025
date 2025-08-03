import 'messaging_service.dart';

class WebRTCSignaling {
  final String apiBaseUrl;

  WebRTCSignaling(this.apiBaseUrl);

  /// Send a signaling message to a user using HTTP notification API
  Future<bool> sendSignal({
    required String userId,
    required String message,
    Map<String, String>? extraHeaders,
  }) async {
    return await MessagingService.sendHttpWebSocketNotification(
      userId: userId,
      message: message,
      extraHeaders: extraHeaders,
    );
  }
}
