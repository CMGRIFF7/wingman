import 'package:flutter/material.dart';
import 'package:ai_best_friend_app/services/google_cloud_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleCloudService _googleCloudService = GoogleCloudService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _googleCloudService.loadApiKey();
  }

  void toggleListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      // Stop listening logic here (or future live streaming)
      print('Stopped listening.');
    } else {
      setState(() {
        _isListening = true;
      });
      print('Started listening...');
      await _googleCloudService.startListening();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Best Friend App'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isListening ? Icons.mic : Icons.mic_off,
              size: 100,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              _isListening ? 'Listening...' : 'Tap to Start Listening',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}
