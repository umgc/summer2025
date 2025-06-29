import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  File? _imageFile;
  File? _documentFile;

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required.')),
        );
        return;
      }
    }

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _documentFile = File(result.files.single.path!));
    }
  }

  Widget _buildIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.indigo,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Media'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text("Choose an option", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconButton(
                  icon: Icons.camera_alt,
                  label: 'Take Picture',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildIconButton(
                  icon: Icons.photo_library,
                  label: 'Upload Photo',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                _buildIconButton(
                  icon: Icons.insert_drive_file,
                  label: 'Upload Document',
                  onTap: _pickDocument,
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (_imageFile != null)
              Text('Selected Image: ${_imageFile!.path.split('/').last}', style: const TextStyle(fontSize: 16)),
            if (_documentFile != null)
              Text('Selected Document: ${_documentFile!.path.split('/').last}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
