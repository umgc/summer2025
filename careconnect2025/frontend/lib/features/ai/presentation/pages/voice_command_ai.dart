import 'dart:async';
import 'package:flutter/material.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceCommandAI extends StatefulWidget {
  const VoiceCommandAI({super.key});

  @override
  State<VoiceCommandAI> createState() => _VoiceCommandAIState();
}

class _VoiceCommandAIState extends State<VoiceCommandAI> {
  PorcupineManager? _porcupine;
  late stt.SpeechToText _speech;

  bool _isListening = false;
  bool _wakeDetected = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initPorcupine();
  }

  Future<void> _initPorcupine() async {
    try {
      _porcupine = await PorcupineManager.fromBuiltInKeywords(
        'Qxjb+VJuMnPDRseioWb9czxnyKe7EWFMdNNMbIWrJiARG2q9Tvo5XA==',
        [BuiltInKeyword.PORCUPINE],
        _onWakeDetected,
      );
      await _porcupine?.start();
    } on PorcupineException catch (e) {
      // Log and show the full error message
      debugPrint('Porcupine init failed: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wake word init error: ${e.message}')),
      );
    } catch (e) {
      // Fallback for other error types
      debugPrint('Unexpected init error: $e');
    }
  }

  void _onWakeDetected(int _) {
    setState(() => _wakeDetected = true);
    _startListening();
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    bool available = await _speech.initialize();
    if (available && await _speech.hasPermission) {
      setState(() => _isListening = true);

      _speech.listen(
        listenFor: const Duration(seconds: 3),
        onResult: (r) {
          if (r.finalResult) {
            _timeoutTimer?.cancel();
            _process(r.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: false,
          listenMode: stt.ListenMode.dictation,
          onDevice: false,
          autoPunctuation: true,
          enableHapticFeedback: false,
        ),
      );

      _timeoutTimer = Timer(const Duration(seconds: 3), _onTimeout);
    } else {
      _showError('Mic permission denied');
      _reset();
    }
  }

  void _process(String words) {
    final cmd = words.toLowerCase().trim();
    debugPrint('Heard: $cmd');

    if (cmd.contains('take me home')) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else if (cmd.contains('take me to calendar')) {
      Navigator.pushNamed(context, '/telehealth');
    } else if (cmd.contains('take me to my tracker')) {
      Navigator.pushNamed(context, '/symptomTracker');
    } else {
      _showError('Command not recognized — please try again.');
    }
    _reset();
  }

  void _onTimeout() {
    if (_isListening) {
      _showError('Listening timed out — please say the command faster.');
      _reset();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _reset() {
    _timeoutTimer?.cancel();
    _speech.stop();
    setState(() {
      _isListening = false;
      _wakeDetected = false;
    });
  }

  void _onMicPressed() {
    setState(() => _wakeDetected = true);
    _startListening();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _porcupine?.stop();
    _porcupine?.delete();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Commands'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            _wakeDetected ? Icons.mic : Icons.mic_none,
            size: 64,
            color: _wakeDetected ? Colors.red : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            !_wakeDetected
                ? 'Say wake word or tap mic'
                : _isListening
                    ? 'Listening...'
                    : 'Processing...',
            style: const TextStyle(fontSize: 18),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onMicPressed,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
