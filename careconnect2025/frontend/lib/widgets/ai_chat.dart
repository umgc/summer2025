import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../services/ai_service.dart';

class AIChat extends StatefulWidget {
  final String role; // 'caregiver', 'patient', or 'analytics'
  final String? healthDataContext; // Health data context for analytics role

  const AIChat({super.key, required this.role, this.healthDataContext});

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
            print('Error processing file ${file.name}: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing file ${file.name}: $e'),
                backgroundColor: Colors.red,
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
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
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
            content.substring(0, 50000) +
            '\n... [Content truncated due to length]';
      }

      return UploadedFile(
        name: file.name,
        size: file.size,
        content: content,
        type: fileType,
      );
    } catch (e) {
      print('Error reading file ${file.name}: $e');
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
      case 'docx':
      case 'doc':
        return 'document';
      case 'xlsx':
      case 'xls':
        return 'spreadsheet';
      case 'html':
      case 'htm':
        return 'html';
      case 'js':
      case 'ts':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
      case 'dart':
        return 'code';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File removed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Performance optimization: Cache file context generation
  String _getFileContextForAI() {
    if (_uploadedFiles.isEmpty) return '';

    // Use cached context if available and not outdated
    if (_cachedFileContext != null && !_fileContextNeedsUpdate) {
      return _cachedFileContext!;
    }

    // Generate new context and cache it
    final buffer = StringBuffer();
    buffer.writeln('=== UPLOADED FILES CONTEXT ===');
    buffer.writeln(
      'The user has uploaded ${_uploadedFiles.length} file(s) for analysis:',
    );
    buffer.writeln();

    for (int i = 0; i < _uploadedFiles.length; i++) {
      final file = _uploadedFiles[i];
      buffer.writeln('FILE ${i + 1}:');
      buffer.writeln('Name: ${file.name}');
      buffer.writeln('Type: ${file.type}');
      buffer.writeln('Size: ${(file.size / 1024).toStringAsFixed(2)} KB');
      buffer.writeln();

      if (file.type == 'pdf' ||
          file.type == 'document' ||
          file.type == 'spreadsheet') {
        buffer.writeln('Content: ${file.content}');
      } else if (file.type == 'image') {
        buffer.writeln(
          'Content: [This is an image file. Image analysis not yet implemented.]',
        );
      } else {
        buffer.writeln('Content:');
        buffer.writeln('---BEGIN ${file.name.toUpperCase()} CONTENT---');
        buffer.writeln(file.content);
        buffer.writeln('---END ${file.name.toUpperCase()} CONTENT---');
      }
      buffer.writeln();
    }

    buffer.writeln('=== ANALYSIS INSTRUCTIONS ===');
    buffer.writeln(
      'Please analyze the above file content and provide insights based on the data.',
    );
    buffer.writeln('Focus on health-related aspects if applicable.');
    buffer.writeln(
      'If the files contain medical data, provide relevant medical insights.',
    );
    buffer.writeln(
      'If the files contain patient data, provide care recommendations.',
    );
    buffer.writeln('===========================');
    buffer.writeln();

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
                              child: Column(
                                children: [
                                  // File upload area
                                  if (_uploadedFiles.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_file,
                                                size: 16,
                                                color: Colors.blue.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Uploaded Files (${_uploadedFiles.length})',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          for (
                                            int i = 0;
                                            i < _uploadedFiles.length;
                                            i++
                                          )
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 4,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _getFileIcon(
                                                      _uploadedFiles[i].type,
                                                    ),
                                                    size: 14,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      _uploadedFiles[i].name,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatFileSize(
                                                      _uploadedFiles[i].size,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  InkWell(
                                                    onTap: () => _removeFile(i),
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 14,
                                                      color:
                                                          Colors.red.shade600,
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
                                  // File upload button
                                  IconButton(
                                    icon: Icon(
                                      Icons.attach_file,
                                      color: _isFilePickerOpen
                                          ? Colors.grey.shade400
                                          : Colors.blue.shade700,
                                      size: 20,
                                    ),
                                    onPressed: _isFilePickerOpen
                                        ? null
                                        : _pickFiles,
                                    tooltip: 'Upload files',
                                  ),
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
