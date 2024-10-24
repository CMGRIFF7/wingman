import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  void startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(
        onResult: (result) {
          if (result.hasConfidenceRating && result.confidence > 0) {
            _processSpeech(result.recognizedWords);
          }
        },
      );
    } else {
      print("The user has denied the use of speech recognition.");
    }
  }

  void stopListening() {
    _speechToText.stop();
  }

  void _processSpeech(String input) async {
    // Here, you could use Google AI services to process the text and generate responses
    String response = _getResponse(input);

    // Convert response to speech
    await _flutterTts.speak(response);
  }

  String _getResponse(String input) {
    // Implement logic for generating an appropriate response based on the input
    if (input.toLowerCase().contains("how are you")) {
      return "You're doing great! Keep the conversation going.";
    } else if (input.toLowerCase().contains("what should I say next")) {
      return "Ask her about her favorite activities, people love talking about what they enjoy.";
    } else {
      return "You're doing great, just be yourself!";
    }
  }
}
