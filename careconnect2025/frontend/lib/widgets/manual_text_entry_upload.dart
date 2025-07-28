import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class ManualTextEntryCard extends StatefulWidget {
  final Future<void> Function(String fileName, Uint8List fileBytes) onSave;

  const ManualTextEntryCard({super.key, required this.onSave});

  @override
  State<ManualTextEntryCard> createState() => _ManualTextEntryCardState();
}

class _ManualTextEntryCardState extends State<ManualTextEntryCard> {
  final _fileNameController = TextEditingController();
  final _fileContentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manual Text Entry',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fileNameController,
                  decoration: const InputDecoration(
                    labelText: 'File Name',
                    hintText: 'Enter file name (no extension)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'File name cannot be empty';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(value.trim())) {
                      return 'Invalid characters in file name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fileContentController,
                  decoration: const InputDecoration(
                    labelText: 'File Content',
                    hintText: 'Enter file content...',
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'File content cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String fileName = _fileNameController.text.trim();
                        String content = _fileContentController.text.trim();

                        final fileBytes = utf8.encode(content);
                        await widget.onSave(fileName, Uint8List.fromList(fileBytes));
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
