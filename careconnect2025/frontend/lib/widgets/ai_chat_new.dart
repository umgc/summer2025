import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIChat extends StatefulWidget {
  final String role; // 'caregiver' or 'patient'

  const AIChat({super.key, required this.role});

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  AIModel _selectedModel = AIModel.deepseek;
  bool _hasSeenWelcome = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _chatHeight = 500.0;
  double _chatWidth = 400.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
      // Show welcome message on first expansion
      if (!_hasSeenWelcome) {
        _hasSeenWelcome = true;
        _messages.add(
          ChatMessage(
            text:
                'Hello! I\'m your health assistant. I can help with health, wellness, and medical questions. You can switch between AI models using the dropdown above. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        // Scroll to bottom after adding welcome message
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } else {
      _animationController.reverse();
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    // Scroll to bottom after adding user message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final response = await AIService.askAI(
        userMessage,
        role: widget.role,
        model: _selectedModel,
      );
      setState(() {
        _messages.add(
          ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isLoading = false;
      });

      // Scroll to bottom after adding AI response
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, I encountered an error. Please try again later.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      // Scroll to bottom after adding error message
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Responsive sizing with constraints
    _chatWidth = (_chatWidth > screenSize.width * 0.9)
        ? screenSize.width * 0.9
        : _chatWidth.clamp(300.0, 500.0);
    _chatHeight = (_chatHeight > screenSize.height * 0.8)
        ? screenSize.height * 0.8
        : _chatHeight.clamp(400.0, 600.0);

    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: _animation.value > 0
                    ? Container(
                        width: _chatWidth,
                        height: _chatHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Chat header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.smart_toy,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Health Assistant',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  // Model selector dropdown
                                  DropdownButton<AIModel>(
                                    value: _selectedModel,
                                    onChanged: (AIModel? newModel) {
                                      if (newModel != null) {
                                        setState(() {
                                          _selectedModel = newModel;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Switched to ${newModel.displayName}',
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                    dropdownColor: Colors.blue.shade600,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    underline: Container(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    items: AIModel.values.map((AIModel model) {
                                      return DropdownMenuItem<AIModel>(
                                        value: model,
                                        child: Text(
                                          model.displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(width: 8),
                                  // Minimize button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.minimize,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: _toggleChat,
                                    tooltip: 'Minimize',
                                  ),
                                  // Close button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _toggleChat();
                                      // Clear messages when closing
                                      setState(() {
                                        _messages.clear();
                                      });
                                    },
                                    tooltip: 'Close',
                                  ),
                                ],
                              ),
                            ),
                            // Chat messages
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(12),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return _buildMessageBubble(message);
                                },
                              ),
                            ),
                            // Loading indicator
                            if (_isLoading)
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AI is thinking...',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Input field
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight:
                                            120, // Max height for multi-line input
                                      ),
                                      child: TextField(
                                        controller: _controller,
                                        maxLines: null,
                                        minLines: 1,
                                        textInputAction:
                                            TextInputAction.newline,
                                        decoration: const InputDecoration(
                                          hintText: 'Ask a health question...',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          // Allow Enter to send message when it's a simple text
                                          if (!value.contains('\n')) {
                                            _sendMessage();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: Colors.blue.shade700,
                                    ),
                                    onPressed: _sendMessage,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(height: 8),
          // Floating action button
          FloatingActionButton.extended(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            icon: _isExpanded
                ? const Icon(Icons.keyboard_arrow_down)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.smart_toy, size: 20),
                      const SizedBox(width: 4),
                      Icon(Icons.settings, size: 12, color: Colors.white70),
                    ],
                  ),
            label: Text(
              'Ask AI (${_selectedModel.displayName.split(' ')[0]})',
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: _toggleChat,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue.shade700
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 16, color: Colors.blue.shade700),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
