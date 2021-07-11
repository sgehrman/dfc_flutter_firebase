import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:dfc_flutter_firebase/src/firebase/firebase_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';

class SignInResult {
  const SignInResult({this.user, this.errorString});

  final String? errorString;
  final auth.User? user;
}

class AuthService {
  factory AuthService() {
    return _instance ??= AuthService._();
  }
  AuthService._();
  static AuthService? _instance;

  // only used for the disconnect
  GoogleSignIn? _googleSignIn;

  auth.User? get currentUser => fbAuth.currentUser;
  Stream<auth.User?> get userStream => fbAuth.authStateChanges();
  FirebaseFirestore get store => FirebaseFirestore.instance;
  auth.FirebaseAuth get fbAuth => auth.FirebaseAuth.instance;

  // returns a map {user: user, error: 'error message'}
  Future<SignInResult> emailSignIn(String email, String password) async {
    auth.User? user;
    String? errorString;

    // you must trim the inputs, flutter is appending a tab when tab over to the password
    final trimmedEmail = StrUtils.trim(email);
    final trimmedPassword = StrUtils.trim(password);

    try {
      final auth.UserCredential authResult =
          await fbAuth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      user = authResult.user;
    } on auth.FirebaseAuthException catch (error) {
      errorString = error.message;

      switch (error.code) {
        case 'user-disabled':
          break;
        case 'wrong-password':
          break;
        case 'invalid-email':
          break;
        case 'user-not-found':
          // create user if doesn't have account
          final SignInResult createRes =
              await createUserWithEmail(email, password);
          user = createRes.user;
          errorString = createRes.errorString;
          break;
      }
    }

    return SignInResult(user: user, errorString: errorString);
  }

  // returns a map {user: user, error: 'error message'}
  Future<SignInResult> createUserWithEmail(
      String email, String password) async {
    auth.User? user;
    String? errorString;

    // you must trim the inputs, flutter is appending a tab when tab over to the password
    final trimmedEmail = StrUtils.trim(email);
    final trimmedPassword = StrUtils.trim(password);

    try {
      final auth.UserCredential result =
          await fbAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      user = result.user;
    } on auth.FirebaseAuthException catch (error) {
      errorString = error.message;

      switch (error.code) {
        case 'email-already-in-use':
          break;
        case 'invalid-email':
          break;
        case 'operation-not-allowed':
          break;
        case 'weak-password':
          break;
      }
    }

    return SignInResult(user: user, errorString: errorString);
  }

  // returns a map {user: user, error: 'error message'}
  Future<SignInResult> googleSignIn() async {
    auth.User? user;
    String? errorString;

    try {
      _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn!.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        final auth.AuthCredential credential =
            auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final auth.UserCredential authResult =
            await fbAuth.signInWithCredential(credential);
        user = authResult.user;
      }
    } on auth.FirebaseAuthException catch (error) {
      errorString = error.message;

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
        case 'ERROR_OPERATION_NOT_ALLOWED':
          break;
        case 'invalid-verification-id':
          break;
      }
    }

    return SignInResult(user: user, errorString: errorString);
  }

  // returns a map {user: user, error: 'error message'}
  Future<SignInResult> anonLogin() async {
    auth.User? user;
    String? errorString;

    try {
      final auth.UserCredential authResult = await fbAuth.signInAnonymously();

      user = authResult.user;
    } on auth.FirebaseAuthException catch (error) {
      errorString = error.message;

      switch (error.code) {
        case 'operation-not-allowed':
          break;
      }
    }

    return SignInResult(user: user, errorString: errorString);
  }

  Future<void> signOut() {
    // Google only: allows you to login to a new google account next login
    // otherwise you will be stuck on the first account you login with
    _googleSignIn?.disconnect();

    return fbAuth.signOut();
  }

  bool isAnonymous() {
    final auth.User? user = currentUser;

    if (user != null && user.uid.isNotEmpty) {
      return user.isAnonymous;
    }

    return false;
  }

  Future<Map> sendPasswordResetEmail(String email) async {
    try {
      await fbAuth.sendPasswordResetEmail(email: email);

      return <String, dynamic>{'result': true, 'errorString': ''};
    } on auth.FirebaseAuthException catch (error) {
      final String? errorString = error.message;

      switch (error.code) {
        case 'invalid-email':
          break;
        case 'user-not-found':
          break;
      }
      return <String, dynamic>{'result': false, 'errorString': errorString};
    }
  }

  // returns a map {user: user, error: 'error message'}
  Future<SignInResult> phoneSignIn(
      String verificationId, String smsCode) async {
    auth.User? user;
    String? errorString;

    // you must trim the inputs, flutter is appending a tab when tab over to the password
    final trimmedSmsCode = StrUtils.trim(smsCode);

    try {
      final auth.AuthCredential credential = auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: trimmedSmsCode,
      );

      final auth.UserCredential authResult =
          await fbAuth.signInWithCredential(credential);
      user = authResult.user;
    } on auth.FirebaseAuthException catch (error) {
      errorString = error.message;

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

    return SignInResult(user: user, errorString: errorString);
  }

  Future<bool> addClaimToEmail(String email, String claim) async {
    return FirebaseUtils.modifyClaims(
      email: email,
      uid: null,
      claims: <String, bool>{claim: true},
    );
  }

  Future<bool> removeClaimForEmail(String email, String claim) async {
    return FirebaseUtils.modifyClaims(
      email: email,
      uid: null,
      claims: <String, bool>{claim: false},
    );
  }

  Future<bool> addClaimToUid(String? uid, String? claim) async {
    return FirebaseUtils.modifyClaims(
      email: null,
      uid: uid,
      claims: <String?, bool>{claim: true},
    );
  }

  Future<bool> removeClaimForUid(String? uid, String? claim) async {
    return FirebaseUtils.modifyClaims(
      email: null,
      uid: uid,
      claims: <String?, bool>{claim: false},
    );
  }

  Future<bool> isAdmin() async {
    final userClaims = await claims();

    return userClaims.contains('admin');
  }

  Future<List<String>> claims() async {
    final List<String> result = [];

    final auth.User? user = currentUser;
    if (user != null) {
      try {
        final x = await user.getIdTokenResult();

        x.claims!.keys.forEach((key) {
          if (x.claims![key] == true) {
            result.add(key);
          }
        });
      } catch (error) {
        print(error);
      }
    }

    return result;
  }

  String get identity {
    String result = displayName;

    if (Utils.isEmpty(result)) {
      result = phoneNumber;
    }

    if (Utils.isEmpty(result)) {
      result = email;
    }

    if (Utils.isEmpty(result)) {
      result = 'Guest';
    }

    return result;
  }

  String get displayName {
    String? result;

    final auth.User? user = currentUser;
    if (user != null) {
      result = user.displayName;
    }

    return result ?? '';
  }

  String get phoneNumber {
    String? result;

    final auth.User? user = currentUser;
    if (user != null) {
      result = user.phoneNumber;
    }

    return result ?? '';
  }

  String get email {
    String? result;

    final auth.User? user = currentUser;
    if (user != null) {
      result = user.email;
    }

    return result ?? '';
  }

  String get photoUrl {
    String? result;

    final auth.User? user = currentUser;
    if (user != null) {
      result = user.photoURL;
    }

    return result ?? '';
  }
}
