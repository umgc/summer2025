import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../config/theme/app_theme.dart';
import '../services/comprehensive_file_service.dart';
import 'file_upload_widget.dart';

class SpeechToTextCard extends StatefulWidget {
  final Future<void> Function(String fileName, Uint8List fileBytes) onSave;
  final List<FileCategory>? allowedCategories;

  const SpeechToTextCard({super.key, required this.onSave, this.allowedCategories});

  @override
  State<SpeechToTextCard> createState() => _SpeechToTextCardState();
}

class _SpeechToTextCardState extends State<SpeechToTextCard> {
  final _fileNameController = TextEditingController();
  FileCategory? _selectedCategory;
  late stt.SpeechToText _speech;
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    final categories = _availableCategories;
    _speech = stt.SpeechToText();
  }

  List<FileCategory> get _availableCategories {
    if (widget.allowedCategories != null &&
        widget.allowedCategories!.isNotEmpty) {
      return widget.allowedCategories!;
    } else {
      return FileCategory.values;
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _saveRecognizedText() async {
    if (_recognizedText
        .trim()
        .isEmpty) return;

    final fileName = 'speech_to_text_${DateTime
        .now()
        .millisecondsSinceEpoch}';
    final fileBytes = Uint8List.fromList(_recognizedText.codeUnits);

    await widget.onSave(fileName, fileBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Speech-to-text file saved')),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.mic, color: Theme
            .of(context)
            .colorScheme
            .primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Speech to Text',
            style: Theme
                .of(context)
                .textTheme
                .headlineSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = _availableCategories;

    if (categories.isEmpty) {
      return const Text('No categories available.');
    }

    return DropdownButtonFormField<FileCategory>(
      items: categories.map((category) {
        return DropdownMenuItem<FileCategory>(
          value: category,
          child: Text('${category.icon} ${category.displayName}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a file category';
        }
        return null;
      },
      value: _selectedCategory,
      // Starts as null!
      hint: const Text('Select Category'),
      // This shows when value is null
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _selectCategory() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file category first'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
  }

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCategorySelector(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'File Name',
              hintText: 'Enter file name (no extension)',
            ),
            validator: (value) {
              if (value == null || value
                  .trim()
                  .isEmpty) {
                return 'File name cannot be empty';
              }
              if (!RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(value.trim())) {
                return 'Invalid characters in file name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme
                    .of(context)
                    .dividerColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Theme
                  .of(context)
                  .colorScheme
                  .surfaceVariant
                  .withOpacity(0.1),
            ),
            child: Column(
              children: [
                Text(
                  _recognizedText.isNotEmpty
                      ? 'Recognized Text:\n$_recognizedText'
                      : 'Tap the button below to start Speech-to-Text',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedCategory == null) {
                      _selectCategory();
                    } else {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    }
                  },
                  child: Text(
                      _isListening ? 'Stop Listening' : 'Start Listening'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _recognizedText.isNotEmpty
                      ? _saveRecognizedText
                      : null,
                  child: const Text('Save to File'),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }