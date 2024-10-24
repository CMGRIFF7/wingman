import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Start the sign-in process.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled sign-in, return null.
        return null;
      }

      // Get Google account authentication.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential for Firebase.
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials.
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  // Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // Sign in using email and password.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      switch (e.code) {
        case 'user-not-found':
          print("No user found with that email.");
          break;
        case 'wrong-password':
          print("Incorrect password provided.");
          break;
        default:
          print("Error signing in with Email: $e");
      }
      return null;
    } catch (e) {
      // Catch any other errors
      print("Error signing in with Email: $e");
      return null;
    }
  }

  // Sign out from all providers
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google, if signed in
      await _googleSignIn.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent");
    } catch (e) {
      print("Error sending password reset email: $e");
    }
  }

  // Register a new user with Email and Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          print("The password provided is too weak.");
          break;
        case 'email-already-in-use':
          print("An account already exists for that email.");
          break;
        default:
          print("Error registering with Email: $e");
      }
      return null;
    } catch (e) {
      print("Error registering with Email: $e");
      return null;
    }
  }
}
