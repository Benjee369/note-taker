import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../services/auth_service.dart';

class UserDetailsProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService;

  bool get isSignedIn => _auth.currentUser != null;

  final Completer<void> _initialLoad = Completer<void>();
  Future<void> get initialLoad => _initialLoad.future;

  late final StreamSubscription<User?> _authSubscription;

  UserDetailsProvider({
    required AuthService authService,
  }) : _authService = authService {
    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        _user = user;
        if (!_initialLoad.isCompleted) {
          _initialLoad.complete();
        }
        notifyListeners();
      },
    );
  }

  Future<bool> signIn() async {
    try {
      await _authService.signInWithGoogle();
      return true;
    } catch (e) {
      return false;
    }
  }

  void signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
