import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/services/session_manager.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';

class NewPostScreen extends StatefulWidget {
  final int userId;
  const NewPostScreen({super.key, required this.userId});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool isPosting = false;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedImage = File(result.files.single.path!));
    }
  }

  Future<void> submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post content cannot be empty')),
      );
      return;
    }

    // Call restoreSession() here to ensure the session cookie is restored
    final session = SessionManager();
    await session.restoreSession(); // This will restore the session cookie

    setState(() => isPosting = true);
    try {
      final response = await ApiService.createPost(
        widget.userId,
        content,
        _selectedImage,
      );

      // Debugging lines
      print('Create post status: ${response.statusCode}');
      print('Create post body: ${response.body}');

      setState(() => isPosting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      setState(() => isPosting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exception: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(context, title: 'Create New Post'),
      drawer: const CommonDrawer(currentRoute: '/new_post'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What’s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedImage != null) ...[
              Image.file(_selectedImage!, height: 150),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => _selectedImage = null),
                child: const Text('Remove Photo'),
              ),
            ],
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('Upload Photo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isPosting ? null : submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
              ),
              child: isPosting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
