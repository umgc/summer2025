import 'dart:io';

import 'package:care_connect_app/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool isPosting = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // ✅ NEW
  }

  Future<void> _loadUserId() async {
    final userIdString = await _secureStorage.read(key: 'userId');
    if (userIdString != null) {
      setState(() {
        _userId = int.tryParse(userIdString);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
    }
  }

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

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot post: user not logged in')),
      );
      return;
    }

    setState(() => isPosting = true);
    try {
      final response = await ApiService.createPost(
        _userId!,
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
      appBar: AppBar(
        title: const Text('Create New Post'),
        backgroundColor: Colors.blue.shade900,
      ),
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
