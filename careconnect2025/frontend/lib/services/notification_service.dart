import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;

  static Future<void> initialize(String wsUrl) async {
    if (_isConnected) return;
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _isConnected = true;
    // Add listeners or authentication as needed
  }

  static void dispose() {
    _channel?.sink.close();
    _isConnected = false;
  }

  static bool get isConnected => _isConnected;
  static WebSocketChannel? get channel => _channel;
}
