import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool get isSignedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;

  // 3. REACTIVE STREAM (For auto-updating widgets)
  Stream<bool> get authStateStream =>
      _auth.authStateChanges().map((user) => user != null);

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger native Google account selector
      final GoogleSignInAccount? googleUser = await _googleSignIn.attemptLightweightAuthentication();
      if (googleUser == null) return null; // User aborted flow

      // Fetch auth tokens
      final GoogleSignInAuthentication googleAuth =
      googleUser.authentication;

      // Generate Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        // accessToken: googleAuth.,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      log("Error signing in: $e");
      return null;
    }
  }

  // 5. SIGN OUT METHOD
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}