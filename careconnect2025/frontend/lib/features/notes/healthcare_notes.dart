import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'dart:io';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/services/auth_token_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

class HealthcareNotes extends StatefulWidget {
  final int patientUserId;
  const HealthcareNotes({super.key, required this.patientUserId});

  @override
  State<HealthcareNotes> createState() => _HealthcareNotesState();
}

class _HealthcareNotesState extends State<HealthcareNotes> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  File? _selectedFile;
  dynamic _userProfile;
  bool _isPatient = false;
  bool _isCaregiver = false;
  List<String> _notesFiles = [];
  bool _isLoadingNotes = true;
  int? _userId;


  @override
  void initState() {
    super.initState();
    _loadNotesFiles();  // Pass correct userId here
    _speech = stt.SpeechToText();
  }

  // Manual text entry
  void _showManualTextEntryDialog() {
    final _fileNameController = TextEditingController();
    final _fileContentController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manual Text Entry'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
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
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _fileContentController,
                    decoration: InputDecoration(
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),  // Cancel button
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String fileName = _fileNameController.text.trim();
                  String content = _fileContentController.text.trim();

                  // Convert content to bytes
                  final fileBytes = utf8.encode(content);

                  // Call your upload function (adjust as needed)
                  await _uploadManualTextFile(fileName, fileBytes);

                  Navigator.of(context).pop();  // Close dialog after upload
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadManualTextFile(String fileName, List<int> fileBytes) async {
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
      final userSession = await AuthTokenManager.getUserSession();
      int? profileId;

      if (_isPatient) {
        profileId = userSession?['id'] as int?;
      } else if (_isCaregiver) {
        profileId = widget.patientUserId;
      }

      if (profileId == null) {
        throw Exception("Profile ID not found for the current user role");
      }

      final response = await ApiService.uploadUserFileFromBytes(
        userId: profileId,
        fileBytes: Uint8List.fromList(fileBytes),
        fileName: '$fileName.txt',
        category: 'manualTextEntry',
        role: _isPatient ? 'PATIENT' : 'CAREGIVER',
      );

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('File Saved'),
            content: Text('File: $fileName.txt has been uploaded successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload file: $fileName.txt.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Error uploading file: $fileName.txt.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  // pick file from web or mobile decision
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      if (kIsWeb) {
        // On Web: Use bytes and filename
        Uint8List? fileBytes = result.files.single.bytes;
        String fileName = result.files.single.name;

        if (fileBytes != null) {
          await _uploadFileWeb(fileBytes, fileName);
        } else {
          print('No file bytes found.');
        }
      } else {
        // On Mobile/Desktop: Use File from path
        final path = result.files.single.path;
        if (path != null) {
          _selectedFile = File(path);
          await _uploadFile();
        } else {
          print('No file path found.');
        }
      }
    } else {
      print('No file selected');
    }
  }

  // Upload for Web
  Future<void> _uploadFileWeb(Uint8List fileBytes, String fileName) async {
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
      final userSession = await AuthTokenManager.getUserSession();
      int? profileId;

      if (_isPatient) {
        profileId = userSession?['id'] as int?;
      } else if (_isCaregiver) {
        profileId = widget.patientUserId;
      }

      if (profileId == null) {
        throw Exception("Profile ID not found for the current user role");
      }

      final response = await ApiService.uploadUserFileFromBytes(
        userId: profileId,
        fileBytes: fileBytes,
        fileName: fileName,
        category: 'healthcareNotesFileUpload',
        role: _isPatient ? 'PATIENT' : 'CAREGIVER',
      );

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('File Saved'),
            content: Text('File: $fileName has been uploaded successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload file: $fileName.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }
  }


  Future<void> _uploadFile() async {
    if (_selectedFile == null || _userProfile == null) return;

    try {
      final userSession = await AuthTokenManager.getUserSession();
      int? profileId;

      if (_isPatient) {
        profileId = userSession?['patientId'] as int?;
      } else if (_isCaregiver) {
        profileId = widget.patientUserId;
      }

      if (profileId == null) {
        throw Exception("Profile ID not found for the current user role");
      }

      final response = await ApiService.uploadUserFile(
        userId: profileId,
        file: _selectedFile!,
        category: 'healthcareNotesFileUpload',
        role: _isPatient ? 'PATIENT' : 'CAREGIVER',
      );

      if (response.statusCode == 200) {
        print('Upload successful');
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('File Saved'),
              content: Text('Your file "${_selectedFile!.path.split('/').last}" has been uploaded successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        print('Upload failed with status: ${response.statusCode}');
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to upload file "${_selectedFile!.path.split('/').last}".'),
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  // Speech to Text Section
  void _resetSpeechToText() {
    _speech = stt.SpeechToText();  // Re-initialize the instance
  }

  void _showSpeechToTextDialog() {
    final _fileNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    String recognizedText = '';
    bool isListening = false;

    // Re-initialize speech to text instance to avoid conflict with other operations
    _resetSpeechToText();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _startListening() async {
              if (_speech.isListening) {
                await _speech.stop();
                setState(() => isListening = false);
                await Future.delayed(Duration(milliseconds: 300));
              }

              bool available = await _speech.initialize(
                onStatus: (status) => print('Speech Status: $status'),
                onError: (error) => print('Speech Error: $error'),
              );

              if (available) {
                setState(() => isListening = true);
                _speech.listen(
                  onResult: (val) {
                    setState(() {
                      recognizedText = val.recognizedWords;
                    });
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Microphone unavailable or access denied.')),
                );
              }
            }

            Future<void> _stopListening() async {
              if (_speech.isListening) {
                await _speech.stop();
                setState(() => isListening = false);
              }
            }

            return AlertDialog(
              title: Text('Speech to Text Entry'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _fileNameController,
                        decoration: InputDecoration(
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
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: isListening ? _stopListening : _startListening,
                        icon: Icon(isListening ? Icons.mic_off : Icons.mic),
                        label: Text(isListening ? 'Stop Listening' : 'Start Listening'),
                      ),
                      SizedBox(height: 20),
                      Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        constraints: BoxConstraints(minHeight: 100),
                        child: Text(
                          recognizedText.isNotEmpty ? recognizedText : 'No speech detected.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _speech.stop();
                    setState(() {
                      recognizedText = '';
                      isListening = false;
                    });
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String fileName = _fileNameController.text.trim();
                      String content = recognizedText.trim();

                      if (content.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No speech content to save.')),
                        );
                        return;
                      }

                      final fileBytes = utf8.encode(content);
                      await _uploadManualTextFile(fileName, fileBytes);

                      _speech.stop();
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // View Notes Section
  Future<List<String>> getUserNotesFiles(int userId) async {
    List<String> allFiles = [];

    final response = await ApiService.getUserFilesByCategory(userId);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> files = data['files'];
      allFiles.addAll(files.map((f) => f.toString()));
    } else {
      print('Failed to load files.');
    }

    return allFiles;
  }

  Future<void> _loadNotesFiles() async {
    setState(() => _isLoadingNotes = true);

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

    int? profileId;

    if (_isPatient) {
      profileId = userSession?['id'] as int?;
    } else if (_isCaregiver) {
      profileId = widget.patientUserId;
    }

    if (profileId == null) {
      throw Exception("Profile ID not found for the current user role");
    }

    final files = await getUserNotesFiles(profileId);

    setState(() {
      _notesFiles = files;
      _isLoadingNotes = false;
    });
  }

  // Perform download on file tap
  void _onNoteFileTapped(String filePath) {
    print('Tapped file path: $filePath');

    _downloadAndShowTextFile(filePath);
  }

  void _downloadAndShowTextFile(String filePath) async {
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

    int? profileId;

    if (_isPatient) {
      profileId = userSession?['id'] as int?;
    } else if (_isCaregiver) {
      profileId = widget.patientUserId;
    }

    if (profileId == null) {
      throw Exception("Profile ID not found for the current user role");
    }

    if (filePath.isEmpty || _userId == null) {
      print('Invalid file path or userId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid file selection')),
      );

      final response = await ApiService.downloadUserFile(
          userId: profileId, filePath: filePath);

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('File Saved'),
              content: Text('Your file "${_selectedFile!
                  .path
                  .split('/')
                  .last}" has been downloaded successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to download file "${_selectedFile!
                  .path
                  .split('/')
                  .last}".'),
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
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: '/healthcare-notes'),
      appBar: AppBar(title: Text('Healthcare Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Upload Notes Section
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Notes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobileLayout = constraints.maxWidth < 600;

                        Widget buttonWidget(IconData icon, String label, VoidCallback onPressed) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: onPressed,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                textStyle: TextStyle(fontSize: 18),
                                minimumSize: Size(double.infinity, 60), // Full width buttons in Column
                              ),
                              icon: Icon(icon, size: 28),
                              label: Text(label),
                            ),
                          );
                        }

                        return isMobileLayout
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buttonWidget(Icons.upload_file, 'File Upload', _pickFile),
                            buttonWidget(Icons.edit, 'Text Entry', _showManualTextEntryDialog),
                            buttonWidget(Icons.mic, 'Speech to Text', _showSpeechToTextDialog),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton.icon(
                                  onPressed: _showSpeechToTextDialog,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    textStyle: TextStyle(fontSize: 18),
                                  ),
                                  icon: Icon(Icons.mic, size: 28),
                                  label: Text('Speech to Text'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton.icon(
                                  onPressed: _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    textStyle: TextStyle(fontSize: 18),
                                  ),
                                  icon: Icon(Icons.upload_file, size: 28),
                                  label: Text('File Upload'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton.icon(
                                  onPressed: _showManualTextEntryDialog,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    textStyle: TextStyle(fontSize: 18),
                                  ),
                                  icon: Icon(Icons.edit, size: 28),
                                  label: Text('Text Entry'),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 20),
            // Download Notes Section
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Notes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _isLoadingNotes
                      ? Center(child: CircularProgressIndicator())
                      : _notesFiles.isEmpty
                      ? Text('No notes found.')
                      : Expanded(
                    child: ListView.builder(
                      itemCount: _notesFiles.length,
                      itemBuilder: (context, index) {
                        final fileName = _notesFiles[index].split('/').last;
                        return ListTile(
                          title: Text(fileName),
                          onTap: () => _onNoteFileTapped(_notesFiles[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}