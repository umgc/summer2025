import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/services/auth_token_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

class SpeechToTextFile extends StatefulWidget {
  @override
  _SpeechToTextFileState createState() => _SpeechToTextFileState();
}

class _SpeechToTextFileState extends State<SpeechToTextFile> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _fileContent = '';

  bool _isPatient = false;
  bool _isCaregiver = false;
  bool _isSaving = false;
  List<String> _files = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _recognizedText = val.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Save to S3 storage
  Future<void> _uploadSpeechToText(String fileName) async {
    final userSession = await AuthTokenManager.getUserSession();
    if (userSession == null || userSession['id'] == null) {
      throw Exception('User session not found');
    }

    final userRole = userSession['role'] as String? ?? '';

    setState(() {
      _isPatient = userRole.toUpperCase() == 'PATIENT';
      _isCaregiver =
          userRole.toUpperCase() == 'CAREGIVER' ||
              userRole.toUpperCase() == 'FAMILY_LINK' ||
              userRole.toUpperCase() == 'ADMIN';
    });

    try {
      // Get the user session to retrieve the correct ID based on role
      final userSession = await AuthTokenManager.getUserSession();
      int? profileId;

      if (_isPatient) {
        profileId = userSession?['id'] as int?;
      } else if (_isCaregiver) {
        profileId = userSession?['id'] as int?;
      }

      if (profileId == null) {
        throw Exception("Profile ID not found for the current user role");
      }

      Uint8List bytes = utf8.encode(_recognizedText);

      // Send the correct profile ID and role for the file upload
      final response = await ApiService.uploadUserFileFromBytes(
        userId: profileId,
        fileBytes: bytes,
        fileName: 'speech_text.txt',
        category: 'speechToText',
        role: _isPatient ? 'PATIENT' : 'CAREGIVER',
      );

      if (response.statusCode == 200) {
        // Parse the response directly to get the file URL
        final responseData = json.decode(response.body);
        if (responseData != null && responseData.containsKey('fileUrl')) {
          print('File was saved successfully.');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save file: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Save text to file
  Future<void> _saveToFile() async {
    String fileName = '';
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Enter file name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'File name cannot be empty';
                }
                // Reject invalid characters (anything except a-zA-Z0-9_-)
                if (!RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(value.trim())) {
                  return 'Invalid characters in file name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),  // Cancel button
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  fileName = _controller.text.trim();
                  Navigator.of(context).pop();  // Close dialog on valid input
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    // If user pressed Cancel or input was invalid
    if (fileName.isEmpty) return;

    try {
      // Call your upload function with the validated fileName
      await _uploadSpeechToText(fileName);

      // Show success popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('File Saved'),
            content: Text('Your file "$fileName.txt" has been uploaded successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show error popup if upload failed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload file: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_recognizedText),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Text(_isListening ? 'Stop' : 'Start'),
                ),
                ElevatedButton(
                  onPressed: _saveToFile,
                  child: Text('Save to File'),
                ),
              ],
            ),
            Divider(height: 40),
            Text('File Content:', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
