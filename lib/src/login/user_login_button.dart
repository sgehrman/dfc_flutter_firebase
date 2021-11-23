import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:dfc_flutter_firebase/src/login/login_apple.dart';
import 'package:dfc_flutter_firebase/src/login/login_email.dart';
import 'package:dfc_flutter_firebase/src/login/login_phone.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class UserLoginButton extends StatefulWidget {
  const UserLoginButton({
    required this.text,
    required this.icon,
    required this.type,
  });

  final IconData icon;
  final String text;
  final String type;

  @override
  _UserLoginButtonState createState() => _UserLoginButtonState();
}

class _UserLoginButtonState extends State<UserLoginButton> {
  void handleAuthResult(BuildContext context, SignInResult? result) {
    if (result != null) {
      if (Utils.isNotEmpty(result.errorString)) {
        Utils.showSnackbar(context, result.errorString!, error: true);
      }

      final auth.User? user = result.user;

      if (user != null) {
        // save in prefs.
        if (Utils.isNotEmpty(user.email)) {
          Preferences.loginEmail = user.email;
        }

        if (Utils.isNotEmpty(user.phoneNumber)) {
          Preferences.loginPhone = user.phoneNumber;
        }
      }
    }
  }

  Future<void> loginWithEmail() async {
    final LoginData? data = await showEmailLoginDialog(context);

    if (data != null) {
      final AuthService auth = AuthService();

      handleAuthResult(
        context,
        await auth.emailSignIn(data.email, data.password),
      );
    }
  }

  Future<void> loginWithPhone() async {
    handleAuthResult(context, await showLoginPhoneDialog(context));
  }

  Future<void> _handleOnPressed() async {
    final AuthService auth = AuthService();

    switch (widget.type) {
      case 'email':
        await loginWithEmail();
        break;
      case 'phone':
        await loginWithPhone();
        break;
      case 'google':
        handleAuthResult(context, await auth.googleSignIn());
        break;
      case 'apple':
        final userCredential = await signInWithApple();

        handleAuthResult(
          context,
          SignInResult(user: userCredential.user, errorString: ''),
        );
        break;
      default:
        handleAuthResult(context, await auth.anonLogin());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'apple') {
      return SignInWithAppleButton(
        onPressed: _handleOnPressed,
      );
    }

    return ElevatedButton.icon(
      icon: Icon(widget.icon),
      onPressed: _handleOnPressed,
      label: Text(widget.text),
    );
  }
}
