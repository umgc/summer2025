import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextCard extends StatefulWidget {
  final Future<void> Function(String fileName, Uint8List fileBytes) onSave;

  const SpeechToTextCard({super.key, required this.onSave});

  @override
  State<SpeechToTextCard> createState() => _SpeechToTextCardState();
}

class _SpeechToTextCardState extends State<SpeechToTextCard> {
  late stt.SpeechToText _speech;
  String _recognizedText = '';
  bool _isListening = false;

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
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _saveRecognizedText() async {
    if (_recognizedText.trim().isEmpty) return;

    final fileName = 'speech_to_text_${DateTime.now().millisecondsSinceEpoch}';
    final fileBytes = Uint8List.fromList(_recognizedText.codeUnits);

    await widget.onSave(fileName, fileBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Speech-to-text file saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Speech to Text',
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
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Text(
                _recognizedText.isNotEmpty
                    ? 'Recognized Text:\n$_recognizedText'
                    : 'Tap the button below to start Speech-to-Text',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _recognizedText.isNotEmpty ? _saveRecognizedText : null,
                child: const Text('Save to File'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}