import 'package:flutter/material.dart';

/// Basic AI chat widget
///
/// This provides a simple chat interface for AI interactions
class AIChat extends StatelessWidget {
  final String role;
  final bool isModal;

  const AIChat({Key? key, required this.role, this.isModal = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isModal ? 0 : 12),
        boxShadow: isModal
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildHeader(), _buildChatArea(), _buildInputArea()],
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isModal ? 0 : 12),
            topRight: Radius.circular(isModal ? 0 : 12),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.assistant, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'CareConnect AI Assistant',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (isModal)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'AI Chat interface for $role role',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {},
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}
