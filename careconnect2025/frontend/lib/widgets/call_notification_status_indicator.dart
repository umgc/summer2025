import 'package:flutter/material.dart';
import '../services/call_notification_service.dart';

/// Widget that shows the real-time connection status for call notifications
class CallNotificationStatusIndicator extends StatefulWidget {
  final bool isInitialized;

  const CallNotificationStatusIndicator({
    super.key,
    required this.isInitialized,
  });

  @override
  State<CallNotificationStatusIndicator> createState() =>
      _CallNotificationStatusIndicatorState();
}

class _CallNotificationStatusIndicatorState
    extends State<CallNotificationStatusIndicator> {
  @override
  Widget build(BuildContext context) {
    final isConnected = CallNotificationService.isConnected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (!widget.isInitialized) return Colors.grey;
    return CallNotificationService.isConnected ? Colors.green : Colors.orange;
  }

  String _getStatusText() {
    if (!widget.isInitialized) return 'Initializing...';
    return CallNotificationService.isConnected ? 'Online' : 'Connecting...';
  }
}
