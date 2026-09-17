import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserDetailsProvider with ChangeNotifier {
  UserCredential? _user;
  UserCredential? get user => _user;

  void setUserCredentials(UserCredential? user) {
    _user = user;
    notifyListeners();
  }

  void clearUserCredentials() {
    _user = null;
    notifyListeners();
  }
}
