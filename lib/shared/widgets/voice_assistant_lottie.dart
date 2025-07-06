import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantLottie extends StatefulWidget {
  const VoiceAssistantLottie({super.key});

  @override
  State<VoiceAssistantLottie> createState() => _VoiceAssistantLottieState();
}

class _VoiceAssistantLottieState extends State<VoiceAssistantLottie> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  String _recognizedWords = "";

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

Future<void> _toggleListening() async {
  try {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('status: $status'),
        onError: (errorNotification) => debugPrint('error: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) async {
            setState(() => _recognizedWords = result.recognizedWords);
            await _tts.speak("You said: ${result.recognizedWords}");
          },
        );
      } else {
        debugPrint("Speech not available");
      }
    }
  } catch (e) {
    debugPrint("Voice assistant error: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: Lottie.asset(
        'assets/images/deeptrain_animation.json',
        repeat: _isListening,  // animates while listening
      ),
    );
  }
}
