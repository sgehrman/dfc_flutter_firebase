import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class FirebaseUserProvider extends ChangeNotifier {
  FirebaseUserProvider() {
    _setup();
  }

  auth.User? _user;
  final AuthService _auth = AuthService();
  bool _initialized = false;
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;
  bool get hasUser => _user != null;
  String get userId => hasUser ? _user!.uid : '';

  bool get initialized => _initialized;

  // work around for reload
  Future<void> reload() async {
    if (_user != null) {
      await _user!.reload();
    }

    _user = _auth.currentUser;

    notifyListeners();
  }

  String get identity {
    return _auth.identity;
  }

  String get displayName {
    return _auth.displayName;
  }

  String get phoneNumber {
    return _auth.phoneNumber;
  }

  String get email {
    return _auth.email;
  }

  String get photoUrl {
    return _auth.photoUrl;
  }

  Future<void> updateProfile(String inDisplayName, String? inPhotoUrl) async {
    if (_user != null) {
      await _user!.updatePhotoURL(inPhotoUrl);
      await _user!.updateDisplayName(inDisplayName);
      await reload();
    }
  }

  Future<void> updateEmail(String inEmail) async {
    if (_user != null) {
      await _user!.verifyBeforeUpdateEmail(inEmail);
      await reload();
    }
  }

  Future<void> _setup() async {
    final Stream<auth.User?> stream = _auth.userStream;

    await stream.forEach((auth.User? user) async {
      _user = user;

      // this checks for user == null
      _isAdmin = await _auth.isAdmin();

      // want to avoid flashing the login screen until we get the
      // first response
      _initialized = true;

      notifyListeners();
    });
  }
}
