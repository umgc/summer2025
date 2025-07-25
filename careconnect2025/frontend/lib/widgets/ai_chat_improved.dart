import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import '../services/ai_service.dart';
import '../providers/user_provider.dart';

/// This is a consolidated AI Chat component that serves all use cases:
/// - Regular floating chat widget for analytics/patient dashboards
/// - Modal dialog chat for the caregiver dashboard
class AIChat extends StatefulWidget {
  final String role; // 'caregiver', 'patient', or 'analytics'
  final String? healthDataContext; // Health data context for analytics role
  final bool isModal; // Whether the chat is displayed in a modal
  final int? patientId; // Patient ID for API calls
  final int? userId; // User ID for API calls

  const AIChat({
    super.key,
    required this.role,
    this.healthDataContext,
    this.isModal = false,
    this.patientId,
    this.userId,
  });

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
  final List<UploadedFile> _uploadedFiles = [];
  bool _isFilePickerOpen = false;

  // Performance optimization: Cache for expensive operations
  String? _cachedFileContext;
  bool _fileContextNeedsUpdate = false;

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

    // Set default initial sizes before proper measurement
    _chatHeight = 500.0;
    _chatWidth = 400.0;

    // If this is a modal view, expand by default
    if (widget.isModal) {
      _isExpanded = true;
      _animationController.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenSize = MediaQuery.of(context).size;

    // Responsive sizing with constraints - only relevant for non-modal
    if (!widget.isModal) {
      // Limit the width based on screen size but with a hard cap
      _chatWidth = screenSize.width < 768 ? 320.0 : 380.0;

      // Never let the chat width exceed 35% of the screen width
      // Ensure max value is always greater than min value to avoid clamp errors
      double maxWidth = screenSize.width * 0.35;
      _chatWidth = _chatWidth.clamp(280.0, math.max(281.0, maxWidth));

      // Adjust height based on screen size
      _chatHeight = screenSize.height < 600
          ? 400.0
          : screenSize.height > 900
          ? 600.0
          : screenSize.height * 0.6;
      _chatHeight = _chatHeight.clamp(400.0, 600.0);
    }

    // Show welcome message for modal view
    if (widget.isModal && !_hasSeenWelcome) {
      _hasSeenWelcome = true;

      // Customize welcome message based on role
      String welcomeMessage;
      if (widget.role == 'analytics') {
        welcomeMessage =
            'Welcome to the Healthcare Analytics Assistant. How can I help you analyze your data today?';
      } else if (widget.role == 'caregiver') {
        welcomeMessage =
            'Welcome to the Caregiver Assistant. I can help you with patient information, care protocols, and medical references.';
      } else {
        welcomeMessage =
            'Welcome to CareConnect AI Assistant. How can I help you today?';
      }

      // Add system welcome message
      _messages.add(
        ChatMessage(
          text: welcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
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

  Future<void> _pickFiles() async {
    if (_isFilePickerOpen) return;

    setState(() {
      _isFilePickerOpen = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        allowedExtensions: null,
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          try {
            UploadedFile? uploadedFile = await _processFile(file);
            if (uploadedFile != null) {
              setState(() {
                _uploadedFiles.add(uploadedFile);
                _fileContextNeedsUpdate = true; // Mark cache as needing update
              });
            }
          } catch (e) {
            debugPrint('Error processing file ${file.name}: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing file ${file.name}: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }

        if (_uploadedFiles.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${result.files.length} file(s) uploaded successfully',
              ),
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isFilePickerOpen = false;
      });
    }
  }

  Future<UploadedFile?> _processFile(PlatformFile file) async {
    final fileType = _getFileType(file.name);

    // Check if file is too large (limit to 10MB)
    if (file.size > 10 * 1024 * 1024) {
      throw Exception('File ${file.name} is too large (max 10MB)');
    }

    String content;

    try {
      if (fileType == 'pdf' || fileType == 'document') {
        // For PDFs and documents, we'll store a placeholder message
        // In a real app, you'd want to use a PDF parser or document converter
        content =
            '[This is a ${fileType.toUpperCase()} file. Content extraction not yet implemented for this file type. File name: ${file.name}]';
      } else {
        // For text-based files, read the content
        if (file.bytes != null) {
          // For web, use bytes and handle encoding properly
          try {
            content = utf8.decode(file.bytes!);
          } catch (e) {
            // If UTF-8 decoding fails, try latin1
            content = latin1.decode(file.bytes!);
          }
        } else if (file.path != null) {
          // For mobile/desktop, read file content
          try {
            content = await File(file.path!).readAsString(encoding: utf8);
          } catch (e) {
            // If UTF-8 fails, try latin1
            content = await File(file.path!).readAsString(encoding: latin1);
          }
        } else {
          throw Exception('Unable to read file content');
        }
      }

      // Limit content size to prevent overwhelming the AI
      if (content.length > 50000) {
        content =
            '${content.substring(0, 50000)}\n... [Content truncated due to length]';
      }

      return UploadedFile(
        name: file.name,
        size: file.size,
        content: content,
        type: fileType,
      );
    } catch (e) {
      debugPrint('Error reading file ${file.name}: $e');
      return null;
    }
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'txt':
      case 'md':
      case 'log':
        return 'text';
      case 'csv':
        return 'csv';
      case 'json':
        return 'json';
      case 'xml':
        return 'xml';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
      case 'odt':
        return 'document';
      case 'xls':
      case 'xlsx':
      case 'ods':
        return 'spreadsheet';
      case 'html':
      case 'htm':
        return 'html';
      case 'js':
      case 'py':
      case 'java':
      case 'c':
      case 'cpp':
      case 'cs':
      case 'php':
      case 'rb':
      case 'swift':
      case 'go':
      case 'rs':
      case 'ts':
        return 'code';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
      case 'bmp':
        return 'image';
      default:
        return 'unknown';
    }
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
      _fileContextNeedsUpdate = true; // Mark cache as needing update
    });
  }

  String _getFileContextForAI() {
    // Return cached value if available and not needing update
    if (_cachedFileContext != null && !_fileContextNeedsUpdate) {
      return _cachedFileContext!;
    }

    if (_uploadedFiles.isEmpty) {
      _cachedFileContext = '';
      _fileContextNeedsUpdate = false;
      return '';
    }

    StringBuffer buffer = StringBuffer();
    buffer.writeln('--- UPLOADED FILES CONTENT ---');

    for (int i = 0; i < _uploadedFiles.length; i++) {
      final file = _uploadedFiles[i];
      buffer.writeln('[FILE ${i + 1}: ${file.name} (${file.type})]');
      buffer.writeln(file.content);
      buffer.writeln('--- END OF FILE ${i + 1} ---');
      buffer.writeln();
    }

    _cachedFileContext = buffer.toString();
    _fileContextNeedsUpdate = false;

    return _cachedFileContext!;
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_snippet;
      case 'csv':
        return Icons.table_chart;
      case 'json':
        return Icons.code;
      case 'xml':
        return Icons.code;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.grid_on;
      case 'html':
        return Icons.web;
      case 'code':
        return Icons.code;
      case 'image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / 1048576).toStringAsFixed(1)}MB';
  }

  void _toggleChat() {
    if (!_isExpanded) {
      // Expand the chat
      setState(() {
        _isExpanded = true;
      });
      _animationController.reset();
      _animationController.forward();
      // Show welcome message on first expansion
      if (!_hasSeenWelcome) {
        _hasSeenWelcome = true;
        // Customize welcome message based on role
        String welcomeMessage = 'Hello! I\'m your health assistant. ';

        if (widget.role == 'analytics') {
          welcomeMessage +=
              'I can help analyze health data and provide insights based on the information you share. You can upload files like health reports or ask questions about the displayed analytics.';
        } else if (widget.role == 'caregiver') {
          welcomeMessage +=
              'I can help with patient care questions, medical information, and treatment guidance. You can also upload patient reports or health documents for analysis.';
        } else {
          welcomeMessage +=
              'I can help with health, wellness, and medical questions. You can also upload your health documents or reports for personalized advice.';
        }

        _messages.add(
          ChatMessage(
            text: welcomeMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        // Scroll to bottom after adding welcome message
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } else {
      // Collapse the chat
      _animationController.reverse().then((_) {
        setState(() {
          _isExpanded = false;
        });
      });
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
      // Get user info from provider if not provided as parameters
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUserId = widget.userId ?? userProvider.user?.id ?? 1;
      final currentPatientId = widget.patientId ?? userProvider.user?.id ?? 1;

      // Combine health data context with file context
      String combinedContext = '';
      if (widget.healthDataContext != null &&
          widget.healthDataContext!.isNotEmpty) {
        combinedContext += widget.healthDataContext!;
      }

      final fileContext = _getFileContextForAI();
      if (fileContext.isNotEmpty) {
        if (combinedContext.isNotEmpty) {
          combinedContext += '\n\n';
        }
        combinedContext += fileContext;
      }

      final response = await AIService.askAI(
        userMessage,
        role: widget.role,
        model: _selectedModel,
        healthDataContext: combinedContext.isNotEmpty ? combinedContext : null,
        patientId: currentPatientId,
        userId: currentUserId,
        context: context, // Pass context for subscription checks
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
            text: 'Sorry, I encountered an error: $e',
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

    // Responsive sizing with constraints - only relevant for non-modal
    if (!widget.isModal) {
      // Limit the width based on screen size but with a hard cap
      _chatWidth = screenSize.width < 768 ? 320.0 : 380.0;

      // Never let the chat width exceed 35% of the screen width
      // This ensures it stays properly on the right side and doesn't take too much space
      double maxWidth = screenSize.width * 0.35;
      _chatWidth = _chatWidth.clamp(280.0, math.max(281.0, maxWidth));

      // Adjust height based on screen size
      _chatHeight = screenSize.height < 600
          ? screenSize.height * 0.7
          : screenSize.height * 0.6;

      // Ensure height stays within reasonable bounds
      _chatHeight = _chatHeight.clamp(400.0, 600.0);
    }

    // The main chat content
    Widget chatContent = Container(
      width: widget.isModal ? double.infinity : _chatWidth,
      height: widget.isModal ? double.infinity : _chatHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: widget.isModal
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
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
              color: Theme.of(context).primaryColor,
              borderRadius: widget.isModal
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Health Assistant',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched to ${newModel.displayName}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      );
                    }
                  },
                  dropdownColor: Theme.of(context).primaryColor,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 16,
                  ),
                  underline: Container(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10,
                  ),
                  items: AIModel.values.map((AIModel model) {
                    return DropdownMenuItem<AIModel>(
                      value: model,
                      child: Text(
                        model.displayName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (!widget.isModal) ...[
                  const SizedBox(width: 8),
                  // Minimize button
                  IconButton(
                    icon: Icon(
                      Icons.minimize,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    onPressed: _toggleChat,
                    tooltip: 'Minimize',
                  ),
                ],
                // Close button
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    if (widget.isModal) {
                      Navigator.of(context).pop();
                    } else {
                      _toggleChat();
                      // Clear messages when closing
                      setState(() {
                        _messages.clear();
                      });
                    }
                  },
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          // Chat messages
          Expanded(
            child: Column(
              children: [
                // File upload area
                if (_uploadedFiles.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Uploaded Files (${_uploadedFiles.length})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _uploadedFiles.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  _getFileIcon(_uploadedFiles[i].type),
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _uploadedFiles[i].name,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatFileSize(_uploadedFiles[i].size),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _removeFile(i),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                // Messages list
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
              ],
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
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI is thinking...',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          // Input field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              borderRadius: widget.isModal
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // File upload button
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: _isFilePickerOpen
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  onPressed: _isFilePickerOpen ? null : _pickFiles,
                  tooltip: 'Upload files',
                ),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 120, // Max height for multi-line input
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: widget.role == 'analytics'
                            ? 'Ask about the health data or upload files...'
                            : widget.role == 'caregiver'
                            ? 'Ask about patient care or upload documents...'
                            : 'Ask a health question or upload documents...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
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
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // If in modal mode, return just the content
    if (widget.isModal) {
      return chatContent;
    }

    // If not in modal mode, handle floating behavior
    return Positioned(
      bottom: 16,
      right: 16, // Position on the right side
      width: _chatWidth, // Set explicit width to constrain it
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end, // Align to bottom
        crossAxisAlignment: CrossAxisAlignment.end, // Align to right
        children: [
          // Only show chat content when expanded
          if (_isExpanded)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: chatContent,
                );
              },
            ),
          const SizedBox(height: 8),
          // Floating action button - only show when not in modal
          if (!widget.isModal)
            FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: _isExpanded
                  ? const Icon(Icons.keyboard_arrow_down)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.smart_toy, size: 20),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.settings,
                          size: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ],
                    ),
              label: Text(
                'Ask AI (${_selectedModel.displayName})',
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
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Theme.of(context).primaryColor,
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
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use markdown formatting for AI responses, plain text for user messages
                  message.isUser
                      ? Text(
                          message.text,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            h1: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            strong: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                            em: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontStyle: FontStyle.italic,
                            ),
                            code: TextStyle(
                              backgroundColor: Theme.of(context).cardColor,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            listBullet: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(
                              context,
                            ).colorScheme.onPrimary.withOpacity(0.7)
                          : Theme.of(context).textTheme.bodySmall?.color,
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
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
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

class UploadedFile {
  final String name;
  final int size;
  final String content;
  final String type;

  UploadedFile({
    required this.name,
    required this.size,
    required this.content,
    required this.type,
  });
}

// Modal wrapper for AI Chat
class AIChatModal extends StatelessWidget {
  final String role;
  final String? healthDataContext;

  const AIChatModal({super.key, required this.role, this.healthDataContext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AIChat(
        role: role,
        healthDataContext: healthDataContext,
        isModal: true,
      ),
    );
  }
}
