import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class GoogleCloudService {
  final String _credentialsFile = 'assets/credentials/api_key.txt';
  late String _apiKey;
  final Record _recorder = Record();

  Future<void> loadApiKey() async {
    try {
      _apiKey = (await rootBundle.loadString(_credentialsFile)).trim();
      print('API Key loaded successfully.');
    } catch (e) {
      print('Failed to load API key: $e');
    }
  }

  // Method to start recording and process audio
  Future<void> startListening() async {
    // Check and request microphone permission
    bool hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      print('Microphone permission not granted.');
      return;
    }

    // Start recording
    try {
      final tempDir = await getTemporaryDirectory();
      String audioPath = '${tempDir.path}/recorded_audio.wav';

      // Start recording audio
      await _recorder.start(
        path: audioPath,
        encoder: AudioEncoder.wav,
        sampleRate: 16000, // Google API prefers 16000 Hz sample rate
      );

      print('Started listening...');
      // Wait for some seconds to collect audio (for demo purposes, consider 5 seconds)
      await Future.delayed(Duration(seconds: 5));

      // Stop recording
      String? path = await _recorder.stop();

      if (path != null) {
        print('Audio recorded to: $path');
        // Process the recorded audio with STT
        await sendAudioToSTT(path);
      }
    } catch (e) {
      print('Error recording audio: $e');
    }
  }

  // Method to send audio to Google's Speech-to-Text API
  Future<void> sendAudioToSTT(String audioFilePath) async {
    try {
      // Load audio file and convert to base64
      File audioFile = File(audioFilePath);
      List<int> audioBytes = await audioFile.readAsBytes();
      String audioContent = base64Encode(audioBytes);

      // Create request payload
      Map<String, dynamic> requestBody = {
        "config": {
          "encoding": "LINEAR16",
          "sampleRateHertz": 16000,
          "languageCode": "en-US",
        },
        "audio": {
          "content": audioContent,
        }
      };

      // Send HTTP request to Google STT API
      final uri = Uri.parse(
          'https://speech.googleapis.com/v1/speech:recognize?key=$_apiKey');

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['results'] != null &&
            responseData['results'].isNotEmpty) {
          for (var result in responseData['results']) {
            var alternative = result['alternatives'][0];
            print('Transcript: ${alternative['transcript']}');
            // Optionally, send transcript to Vertex AI for further processing
            await processTextWithVertexAI(alternative['transcript']);
          }
        } else {
          print('No transcription found.');
        }
      } else {
        print(
            'Failed to get a response from Google API. Status: ${response.statusCode}, Error: ${response.body}');
      }
    } catch (e) {
      print('Error sending audio to STT: $e');
    }
  }

  // Placeholder to send the recognized text to Vertex AI
  Future<void> processTextWithVertexAI(String inputText) async {
    try {
      // Placeholder for Vertex AI Integration
      print('Sending text to Vertex AI: $inputText');
      // Implement API calls to Vertex AI Gemini API here
    } catch (e) {
      print('Error processing text with Vertex AI: $e');
    }
  }
}
