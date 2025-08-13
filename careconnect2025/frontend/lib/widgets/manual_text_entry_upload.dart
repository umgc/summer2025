import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../config/theme/app_theme.dart';
import '../core/services/api_service.dart';
import '../providers/user_provider.dart';
import '../services/auth_token_manager.dart';
import '../services/comprehensive_file_service.dart';
import '../services/enhanced_file_service.dart';

class ManualTextEntryCard extends StatefulWidget {
  final List<FileCategory>? allowedCategories;
  final int? patientId;
  final Function(FileUploadResponse)? onUploadSuccess;
  final Function(String)? onUploadError;

  const ManualTextEntryCard({super.key, this.allowedCategories, this.patientId, this.onUploadSuccess, this.onUploadError});

  @override
  State<ManualTextEntryCard> createState() => _ManualTextEntryCardState();
}

class _ManualTextEntryCardState extends State<ManualTextEntryCard> {
  final _fileNameController = TextEditingController();
  late var _fileContentController = TextEditingController();
  FileCategory? _selectedCategory;

  List<FileCategory> get _availableCategories {
    if (widget.allowedCategories != null && widget.allowedCategories!.isNotEmpty) {
      return widget.allowedCategories!;
    } else {
      return FileCategory.values;
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.text_fields, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Manual Text Entry',
            style: Theme.of(context).textTheme.headlineSmall,
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
      value: _selectedCategory,  // Starts as null!
      hint: const Text('Select Category'),  // This shows when value is null
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Future<void> _uploadManualTextFileToWeb(String fileName, List<int> fileBytes) async {
    if (_selectedCategory == null || fileBytes.isEmpty || fileName.isEmpty) {
      print('Selected category was null..');
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) {
        throw Exception('User not logged in');
      }

      FileUploadResponse? response;

      // Use the existing enhanced file service for other categories
      response = await EnhancedFileService.uploadFileWeb(
        fileBytes: Uint8List.fromList(fileBytes),
        fileName: '$fileName.txt',
        category: _selectedCategory!.value,
        patientId: widget.patientId,
      );

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File uploaded successfully: ${response.fileName}',
            ),
            backgroundColor: AppTheme.success,
          ),
        );

        // Reset form
        setState(() {
          _selectedCategory = null;
          _fileNameController.clear();
          _fileContentController.clear();
        });

        // Callback
        if (widget.onUploadSuccess != null) {
          widget.onUploadSuccess!(response);
        }
      } else {
        throw Exception('Upload failed - no response received');
      }
    } catch (e, stacktrace) {
      print('Upload Exception: $e');
      print('Stacktrace: $stacktrace');
      final errorMessage = 'Upload failed: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppTheme.error),
      );

      if (widget.onUploadError != null) {
        widget.onUploadError!(errorMessage);
      }
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
        Column(
          children: [
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
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedCategory == null) {
                    _selectCategory();
                  }

                  String fileName = _fileNameController.text.trim();
                  String content = _fileContentController.text.trim();

                  final fileBytes = utf8.encode(content);
                  // Call your upload function (adjust as needed)
                  await _uploadManualTextFileToWeb(fileName, fileBytes);
                },

                child: const Text('Save to File'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
