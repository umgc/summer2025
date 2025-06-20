import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:io';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool isPosting = false;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _selectedImage = File(result.files.single.path!));
    }
  }

  Future<void> submitPost() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID missing or content empty')),
      );
      return;
    }

    setState(() => isPosting = true);

    final baseUrl = Platform.isAndroid
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
    final url = Uri.parse('$baseUrl/api/feed');

    final request = http.MultipartRequest('POST', url)
      ..fields['userId'] = userId
      ..fields['content'] = _contentController.text.trim();

    if (_selectedImage != null) {
      final fileLength = await _selectedImage!.length();
      final stream = http.ByteStream(_selectedImage!.openRead());
      final fileName = path.basename(_selectedImage!.path);

      request.files.add(
        http.MultipartFile('image', stream, fileLength, filename: fileName),
      );
    }

    final response = await request.send();
    setState(() => isPosting = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post')),
      );
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
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
