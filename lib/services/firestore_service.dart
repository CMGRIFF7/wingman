import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save conversation history
  Future<void> saveConversation(String userId, String conversation) async {
    await _db.collection('conversations').add({
      'userId': userId,
      'conversation': conversation,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Save user preferences
  Future<void> saveUserPreferences(
      String userId, Map<String, dynamic> preferences) async {
    await _db.collection('user_preferences').doc(userId).set(preferences);
  }
}
