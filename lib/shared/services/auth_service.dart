import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

class AuthService {
  AuthService._internal();

  // 2. Single global instance
  static final AuthService instance = AuthService._internal();

  // 3. Factory constructor returning the same instance
  factory AuthService() => instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final clientSecret = dotenv.get('CLIENTSECRET');
  final clientId = dotenv.get('CLIENTID');

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    params: GoogleSignInParams(
      clientSecret: clientSecret,
      clientId: clientId,
      scopes: ['email', 'profile'],
      redirectPort: 8080,
    ),
  );

  // Non-blocking sign-in check


  // 2. Cross-platform Sign-In Method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Opens system browser on Windows/Linux, native prompt on mobile
      final GoogleSignInCredentials? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User closed browser or canceled

      // Extract tokens
      final String? idToken = googleUser.idToken;
      final String accessToken = googleUser.accessToken;

      if (idToken == null) {
        throw Exception("Failed to retrieve ID token from Google.");
      }

      // Generate Firebase Credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Authenticate with Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      log("Google Sign-In Error: $e");
      return null;
    }
  }

  // 3. Sign-Out Method
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
