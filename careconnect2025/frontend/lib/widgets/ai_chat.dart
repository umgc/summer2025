import 'package:flutter/material.dart';

/// Basic AI chat widget
///
/// This provides a simple chat interface for AI interactions
class AIChat extends StatelessWidget {
  final String role;
  final bool isModal;

  const AIChat({super.key, required this.role, this.isModal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(isModal ? 0 : 12),
        boxShadow: isModal
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
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
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isModal ? 0 : 12),
            topRight: Radius.circular(isModal ? 0 : 12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.assistant,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'CareConnect AI Assistant',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (isModal)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Builder(
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'AI Chat interface for $role role',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          ),
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
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () {},
              tooltip: 'Send message',
            ),
          ],
        ),
      ),
    );
  }
}
