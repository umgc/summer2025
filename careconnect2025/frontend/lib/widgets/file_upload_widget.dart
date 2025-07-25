import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/comprehensive_file_service.dart';
import '../services/enhanced_file_service.dart';
import '../providers/user_provider.dart';
import '../config/theme/app_theme.dart';

/// Comprehensive file upload widget for CareConnect
class FileUploadWidget extends StatefulWidget {
  final FileCategory? defaultCategory;
  final int? patientId;
  final Function(FileUploadResponse)? onUploadSuccess;
  final Function(String)? onUploadError;
  final bool showCategorySelector;
  final String? customTitle;
  final List<FileCategory>? allowedCategories;

  const FileUploadWidget({
    super.key,
    this.defaultCategory,
    this.patientId,
    this.onUploadSuccess,
    this.onUploadError,
    this.showCategorySelector = true,
    this.customTitle,
    this.allowedCategories,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  FileCategory? _selectedCategory;
  bool _isUploading = false;
  File? _selectedFile;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.defaultCategory;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<FileCategory> get _availableCategories {
    if (widget.allowedCategories != null) {
      return widget.allowedCategories!;
    }

    // Return all categories by default
    return FileCategory.values;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (widget.showCategorySelector) ...[
              _buildCategorySelector(),
              const SizedBox(height: 16),
            ],
            _buildFileSelector(),
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              _buildFilePreview(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
            ],
            _buildUploadButton(),
            if (_isUploading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.cloud_upload, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.customTitle ?? 'Upload File',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<FileCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Select category',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _availableCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Text(category.icon),
                  const SizedBox(width: 8),
                  Expanded(child: Text(category.displayName)),
                ],
              ),
            );
          }).toList(),
          onChanged: (FileCategory? newValue) {
            setState(() {
              _selectedCategory = newValue;
              _selectedFile = null; // Reset file when category changes
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a file category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select File',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedFile != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _selectedFile != null
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: InkWell(
            onTap: _selectFile,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedFile != null
                      ? Icons.check_circle
                      : Icons.add_circle_outline,
                  size: 48,
                  color: _selectedFile != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFile != null
                      ? 'File Selected: ${_selectedFile!.path.split('/').last}'
                      : _getFileInstructions(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedFile != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: _selectedFile != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    final filePath = _selectedFile!.path;
    final fileName = filePath.split('/').last;
    final fileSize = _selectedFile!.lengthSync();
    final fileSizeText = _formatFileSize(fileSize);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(fileName),
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileSizeText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedFile = null;
              });
            },
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description (Optional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Enter file description',
            hintText: 'Provide additional details about this file...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    final canUpload =
        _selectedCategory != null && _selectedFile != null && !_isUploading;

    return ElevatedButton.icon(
      onPressed: canUpload ? _uploadFile : null,
      style: canUpload
          ? Theme.of(context).elevatedButtonTheme.style
          : ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).disabledColor,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.38),
            ),
      icon: _isUploading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_upload),
      label: Text(_isUploading ? 'Uploading...' : 'Upload File'),
    );
  }

  String _getFileInstructions() {
    if (_selectedCategory == null) {
      return 'Select a category first, then tap to choose file';
    }

    switch (_selectedCategory!) {
      case FileCategory.profilePicture:
        return 'Tap to select profile picture\n(JPG, PNG - max 5MB)';
      case FileCategory.prescription:
        return 'Tap to take photo or select prescription\n(JPG, PNG, PDF - max 10MB)';
      case FileCategory.medicalReport:
      case FileCategory.labResult:
        return 'Tap to select medical document\n(PDF, DOC, JPG, PNG - max 25MB)';
      case FileCategory.insuranceDoc:
        return 'Tap to select insurance document\n(PDF, DOC, JPG, PNG - max 25MB)';
      default:
        return 'Tap to select file\n(Any format - max 50MB)';
    }
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _selectFile() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file category first'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    try {
      final file = await ComprehensiveFileService.pickFileForCategory(
        _selectedCategory!,
      );
      if (file != null) {
        // Validate file
        if (!ComprehensiveFileService.validateFileForCategory(
          file,
          _selectedCategory!,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid file type for ${_selectedCategory!.displayName}',
              ),
              backgroundColor: AppTheme.error,
            ),
          );
          return;
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedCategory == null || _selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) {
        throw Exception('User not logged in');
      }

      FileUploadResponse? response;
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();

      // Upload based on category
      switch (_selectedCategory!) {
        case FileCategory.profilePicture:
          response = await ComprehensiveFileService.uploadProfileImage(
            userId: user.id,
            imageFile: _selectedFile!,
          );
          break;

        case FileCategory.medicalReport:
        case FileCategory.labResult:
          response = await ComprehensiveFileService.uploadMedicalDocument(
            patientId: widget.patientId ?? user.id,
            documentFile: _selectedFile!,
            category: _selectedCategory!,
            description: description,
          );
          break;

        case FileCategory.prescription:
          response = await ComprehensiveFileService.uploadPrescription(
            patientId: widget.patientId ?? user.id,
            prescriptionFile: _selectedFile!,
            description: description,
          );
          break;

        case FileCategory.clinicalNotes:
          response =
              await ComprehensiveFileService.uploadClinicalNotesAttachment(
                patientId: widget.patientId ?? user.id,
                attachmentFile: _selectedFile!,
                description: description,
              );
          break;

        case FileCategory.aiChatUpload:
          response = await ComprehensiveFileService.uploadChatFile(
            chatFile: _selectedFile!,
            description: description,
          );
          break;

        case FileCategory.insuranceDoc:
          response = await ComprehensiveFileService.uploadInsuranceDocument(
            patientId: widget.patientId ?? user.id,
            insuranceFile: _selectedFile!,
            description: description,
          );
          break;

        case FileCategory.emergencyContact:
          response =
              await ComprehensiveFileService.uploadEmergencyContactDocument(
                userId: user.id,
                documentFile: _selectedFile!,
                description: description,
              );
          break;

        default:
          // Use the existing enhanced file service for other categories
          response = await EnhancedFileService.uploadFile(
            file: _selectedFile!,
            category: _selectedCategory!.value,
            description: description,
            patientId: widget.patientId,
          );
          break;
      }

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File uploaded successfully: ${response.originalFilename}',
            ),
            backgroundColor: AppTheme.success,
          ),
        );

        // Reset form
        setState(() {
          _selectedFile = null;
          _descriptionController.clear();
        });

        // Callback
        if (widget.onUploadSuccess != null) {
          widget.onUploadSuccess!(response);
        }
      } else {
        throw Exception('Upload failed - no response received');
      }
    } catch (e) {
      final errorMessage = 'Upload failed: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppTheme.error),
      );

      if (widget.onUploadError != null) {
        widget.onUploadError!(errorMessage);
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}

/// Quick upload buttons for common file types
class QuickUploadButtons extends StatelessWidget {
  final int? patientId;
  final Function(FileUploadResponse)? onUploadSuccess;

  const QuickUploadButtons({super.key, this.patientId, this.onUploadSuccess});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Upload', style: AppTheme.headingSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickButton(
              context,
              icon: Icons.person,
              label: 'Profile Photo',
              category: FileCategory.profilePicture,
            ),
            _buildQuickButton(
              context,
              icon: Icons.medical_services,
              label: 'Medical Report',
              category: FileCategory.medicalReport,
            ),
            _buildQuickButton(
              context,
              icon: Icons.medication,
              label: 'Prescription',
              category: FileCategory.prescription,
            ),
            _buildQuickButton(
              context,
              icon: Icons.science,
              label: 'Lab Result',
              category: FileCategory.labResult,
            ),
            _buildQuickButton(
              context,
              icon: Icons.security,
              label: 'Insurance',
              category: FileCategory.insuranceDoc,
            ),
            _buildQuickButton(
              context,
              icon: Icons.smart_toy,
              label: 'AI Chat File',
              category: FileCategory.aiChatUpload,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required FileCategory category,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _showUploadDialog(context, category),
      style: AppTheme.secondaryButtonStyle,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  void _showUploadDialog(BuildContext context, FileCategory category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload ${category.displayName}'),
          content: SizedBox(
            width: 400,
            child: FileUploadWidget(
              defaultCategory: category,
              patientId: patientId,
              showCategorySelector: false,
              onUploadSuccess: (response) {
                Navigator.of(context).pop();
                if (onUploadSuccess != null) {
                  onUploadSuccess!(response);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
