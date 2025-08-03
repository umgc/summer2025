import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ai_chat_service.dart';
import '../config/theme/app_theme.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'dart:io';
import 'dart:convert';

// Message model for chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? errorMessage;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.errorMessage,
  });
}

// Helper class for uploaded files
class UploadedFile {
  final String name;
  final int size;
  final String content;
  final String type;
  final List<int>? bytes;
  final String? path;

  UploadedFile({
    required this.name,
    required this.size,
    required this.content,
    required this.type,
    this.bytes,
    this.path,
  });
}

// (AIModel selection removed as requested)

// ...existing widget classes below...
class AIChat extends StatefulWidget {
  final String role;
  final String? healthDataContext;
  final bool isModal;
  final int? patientId;
  final int? userId;

  const AIChat({
    Key? key,
    required this.role,
    this.healthDataContext,
    this.isModal = false,
    this.patientId,
    this.userId,
  }) : super(key: key);

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> with SingleTickerProviderStateMixin {
  String _conversationId = "";
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<UploadedFile> _uploadedFiles = [];
  bool _isLoading = false;
  bool _isFilePickerOpen = false;
  double _chatWidth = 320.0;
  double _chatHeight = 500.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    setState(() => _isFilePickerOpen = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        for (var file in result.files) {
          final uploaded = await _processFile(file);
          if (uploaded != null) {
            setState(() {
              _uploadedFiles.add(uploaded);
            });
          }
        }
      }
    } finally {
      setState(() => _isFilePickerOpen = false);
    }
  }

  Future<UploadedFile?> _processFile(PlatformFile file) async {
    final fileType = _getFileType(file.name);
    if (file.size > 10 * 1024 * 1024) {
      throw Exception('File ${file.name} is too large (max 10MB)');
    }
    String content;
    try {
      if (fileType == 'pdf' || fileType == 'document') {
        content =
            '[This is a ${fileType.toUpperCase()} file. Content extraction not yet implemented for this file type. File name: ${file.name}]';
      } else {
        if (file.bytes != null) {
          try {
            content = utf8.decode(file.bytes!);
          } catch (e) {
            content = latin1.decode(file.bytes!);
          }
        } else if (file.path != null) {
          try {
            content = await File(file.path!).readAsString(encoding: utf8);
          } catch (e) {
            content = await File(file.path!).readAsString(encoding: latin1);
          }
        } else {
          throw Exception('Unable to read file content');
        }
      }
      if (content.length > 50000) {
        content =
            '${content.substring(0, 50000)}\n... [Content truncated due to length]';
      }
      return UploadedFile(
        name: file.name,
        size: file.size,
        content: content,
        type: fileType,
        bytes: file.bytes,
        path: file.path,
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
    });
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    try {
      final userProvider = mounted
          ? Provider.of<UserProvider>(context, listen: false)
          : null;
      final currentUserId = widget.userId ?? userProvider?.user?.id ?? 1;
      // Only use patientId if explicitly provided, never default to user ID
      final currentPatientId = widget.patientId;

      // Prepare uploadedFiles for API if any
      List<Map<String, dynamic>>? uploadedFilesJson;
      if (_uploadedFiles.isNotEmpty) {
        uploadedFilesJson = _uploadedFiles.map((file) {
          List<int>? fileBytes = file.bytes;
          if (fileBytes == null && file.path != null) {
            try {
              fileBytes = File(file.path!).readAsBytesSync();
            } catch (_) {}
          }
          String? base64Content = fileBytes != null
              ? base64Encode(fileBytes)
              : null;
          String contentType = _guessMimeType(file.name);
          return {
            'filename': file.name,
            'content': base64Content ?? '',
            'contentType': contentType,
          };
        }).toList();
      }

      // Only these fields are dynamic for the request
      final response = await AIChatService.sendMessage(
        message: userMessage,
        patientId: currentPatientId, // Pass only if explicitly provided
        userId: currentUserId,
        conversationId: _conversationId.isNotEmpty ? _conversationId : null,
        uploadedFiles: uploadedFilesJson,
      );
      final aiText = response['aiResponse'] ?? 'No response.';
      final errorMsg =
          (response['errorMessage'] != null &&
              (response['errorMessage'] as String).isNotEmpty)
          ? response['errorMessage']
          : null;
      // Update conversationId for next request
      if (response['conversationId'] != null &&
          response['conversationId'] is String) {
        _conversationId = response['conversationId'];
      }
      setState(() {
        _messages.add(
          ChatMessage(
            text: aiText,
            isUser: false,
            timestamp: DateTime.now(),
            errorMessage: errorMsg,
          ),
        );
        _isLoading = false;
      });
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  String _guessMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'doc':
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  void _scrollToBottom() {
    // Implement scroll logic if using a ScrollController
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: _chatWidth,
        height: _chatHeight,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Chat header
            Row(
              children: [
                Icon(Icons.smart_toy, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('AI Chat', style: theme.textTheme.titleMedium),
                ),
                if (widget.isModal)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
              ],
            ),
            Divider(color: colorScheme.outlineVariant),
            // Message list
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? AppTheme.chatUserMessage
                            : colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MarkdownBody(
                            data: msg.text,
                            shrinkWrap: true,
                            styleSheet: MarkdownStyleSheet(
                              p: msg.isUser
                                  ? theme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.chatTextOnPrimary,
                                    )
                                  : theme.textTheme.bodyMedium,
                            ),
                          ),
                          if (msg.errorMessage != null)
                            Text(
                              msg.errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          Text(
                            _formatTimestamp(msg.timestamp),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // File preview (if any files uploaded)
            if (_uploadedFiles.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Files to upload:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._uploadedFiles.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final file = entry.value;
                      return Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              file.name,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            onPressed: () => _removeFile(idx),
                            tooltip: 'Remove',
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            // Input row
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: colorScheme.primary),
                  onPressed: _isFilePickerOpen ? null : _pickFiles,
                  tooltip: 'Attach file',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(Icons.send, color: colorScheme.primary),
                  onPressed: _isLoading ? null : _sendMessage,
                  tooltip: 'Send',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.month}/${dt.day}/${dt.year}';
    }
  }
}
