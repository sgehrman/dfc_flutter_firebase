import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';

class PhoneVerifyier extends ChangeNotifier {
  String? _verificationId;
  String? _errorMessage;

  final auth.FirebaseAuth _auth = AuthService().fbAuth;

  bool get hasVerificationId =>
      _verificationId != null && _verificationId!.isNotEmpty;
  String? get verificationId => _verificationId;
  String? get errorMessage => _errorMessage;

  // PhoneVerificationCompleted
  Future<void> _verificationCompleted(
      auth.AuthCredential phoneAuthCredential) async {
    try {
      await _auth.signInWithCredential(phoneAuthCredential);
    } on auth.FirebaseAuthException catch (error) {
      _errorMessage = error.message;

      switch (error.code) {
        case 'account-exists-with-different-credential':
          break;
        case 'invalid-credential':
          break;
        case 'operation-not-allowed':
          break;
        case 'user-disabled':
          break;
        case 'user-not-found':
          break;
        case 'wrong-password':
          break;
        case 'invalid-verification-code':
          break;
        case 'invalid-verification-id':
          break;
      }
    }

    notifyListeners();
  }

  // PhoneVerificationFailed
  void _verificationFailed(auth.FirebaseAuthException authException) {
    _errorMessage =
        'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';

    notifyListeners();
  }

  // PhoneCodeSent
  void _codeSent(String verificationId, [int? forceResendingToken]) {
    _verificationId = verificationId;

    notifyListeners();
  }

  // PhoneCodeAutoRetrievalTimeout
  void _codeAutoRetrievalTimeout(String verificationId) {
    _verificationId = verificationId;

    notifyListeners();
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 10),
        verificationCompleted: _verificationCompleted,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout);
  }
}
