import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class UploadAvatarScreen extends StatefulWidget {
  const UploadAvatarScreen({super.key});

  @override
  State<UploadAvatarScreen> createState() => _UploadAvatarScreenState();
}

class _UploadAvatarScreenState extends State<UploadAvatarScreen> {
  File? _selectedAvatar;       // Mobile/desktop file
  Uint8List? _avatarBytes;     // Web image bytes
  bool isUploading = false;
  String? uploadedAvatarUrl;   // Relative URL from backend

  Future<void> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _avatarBytes = result.files.single.bytes;
          _selectedAvatar = null;
        } else {
          _selectedAvatar = File(result.files.single.path!);
          _avatarBytes = null;
        }
      });
    }
  }

  Future<void> uploadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    // Ensure image is picked
    if (userId == null || (_selectedAvatar == null && _avatarBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing user ID or image')),
      );
      return;
    }

    setState(() => isUploading = true);

    final baseUrl = kIsWeb
        ? 'http://localhost:8080'
        : (Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080');
    final uri = Uri.parse('$baseUrl/api/auth/avatar/$userId');

    final request = http.MultipartRequest('POST', uri);

    if (kIsWeb && _avatarBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'avatar',
        _avatarBytes!,
        filename: 'avatar.png',
      ));
    } else if (_selectedAvatar != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', _selectedAvatar!.path));
    } else {
      // Should never happen, but safety!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      setState(() => isUploading = false);
      return;
    }

    try {
      final response = await request.send();
      setState(() => isUploading = false);

      if (response.statusCode == 200) {
        final responseBody = await http.Response.fromStream(response);
        if (responseBody.statusCode == 200) {
          final data = jsonDecode(responseBody.body);
          final serverPath = data['imageUrl']; // This should be '/uploads/filename.jpg'

          setState(() => uploadedAvatarUrl = serverPath);
          await prefs.setString('profileImageUrl', serverPath);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar uploaded successfully!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload avatar')),
        );
      }
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = uploadedAvatarUrl != null
        ? ((kIsWeb || !Platform.isAndroid)
        ? 'http://localhost:8080$uploadedAvatarUrl'
        : 'http://10.0.2.2:8080$uploadedAvatarUrl')
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Avatar'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (kIsWeb && _avatarBytes != null) ...[
              Image.memory(_avatarBytes!, height: 150),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() {
                  _avatarBytes = null;
                  uploadedAvatarUrl = null;
                }),
                child: const Text('Remove Image'),
              ),
            ] else if (!kIsWeb && _selectedAvatar != null) ...[
              Image.file(_selectedAvatar!, height: 150),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() {
                  _selectedAvatar = null;
                  uploadedAvatarUrl = null;
                }),
                child: const Text('Remove Image'),
              ),
            ],
            ElevatedButton.icon(
              onPressed: pickAvatar,
              icon: const Icon(Icons.image),
              label: const Text('Pick Avatar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isUploading ? null : uploadAvatar,
              child: isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Upload'),
            ),
            const SizedBox(height: 20),
            if (resolvedImageUrl != null)
              Column(
                children: [
                  const Text('Preview:'),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(resolvedImageUrl),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
