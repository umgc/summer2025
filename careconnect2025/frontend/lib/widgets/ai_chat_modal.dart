import 'package:flutter/material.dart';
import 'ai_chat_improved.dart';

/// A modal dialog wrapper for the AI chat component
class AIChatModal extends StatelessWidget {
  final String role;

  const AIChatModal({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AIChat(role: role, isModal: true),
      ),
    );
  }
}
