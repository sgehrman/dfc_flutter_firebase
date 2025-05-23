import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:dfc_flutter_firebase/src/login/login_apple.dart';
import 'package:dfc_flutter_firebase/src/login/login_email.dart';
import 'package:dfc_flutter_firebase/src/login/login_phone.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class UserLoginButton extends StatefulWidget {
  const UserLoginButton({
    required this.text,
    required this.icon,
    required this.type,
    this.googleClientId,
  });

  final IconData icon;
  final String text;
  final String type;
  final String? googleClientId;

  @override
  State<UserLoginButton> createState() => _UserLoginButtonState();
}

class _UserLoginButtonState extends State<UserLoginButton> {
  void handleAuthResult(BuildContext context, SignInResult? result) {
    if (result != null) {
      if (Utils.isNotEmpty(result.errorString)) {
        Utils.showSnackbar(context, result.errorString!, error: true);
      }

      final user = result.user;

      if (user != null) {
        // save in prefs.
        if (Utils.isNotEmpty(user.email)) {
          Preferences().loginEmail = user.email;
        }

        if (Utils.isNotEmpty(user.phoneNumber)) {
          Preferences().loginPhone = user.phoneNumber;
        }
      }
    }
  }

  Future<void> loginWithEmail() async {
    final data = await showEmailLoginDialog(context);

    if (data != null) {
      final auth = AuthService();

      final signIn = await auth.emailSignIn(data.email, data.password);
      if (mounted) {
        handleAuthResult(context, signIn);
      }
    }
  }

  Future<void> loginWithPhone() async {
    final signIn = await showLoginPhoneDialog(context);

    if (mounted) {
      handleAuthResult(context, signIn);
    }
  }

  Future<void> _handleOnPressed() async {
    final auth = AuthService();

    switch (widget.type) {
      case 'email':
        await loginWithEmail();
        break;
      case 'phone':
        await loginWithPhone();
        break;
      case 'google':
        if (Utils.isNotEmpty(widget.googleClientId)) {
          final signIn = await auth.googleSignIn(widget.googleClientId!);

          if (mounted) {
            handleAuthResult(context, signIn);
          }
        } else {
          print('### googleClientId is required.');
        }
        break;
      case 'apple':
        final userCredential = await signInWithApple();

        if (mounted) {
          handleAuthResult(
            context,
            SignInResult(user: userCredential.user, errorString: ''),
          );
        }
        break;
      default:
        final signIn = await auth.anonLogin();

        if (mounted) {
          handleAuthResult(context, signIn);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'apple') {
      return SignInWithAppleButton(onPressed: _handleOnPressed);
    }

    return ElevatedButton.icon(
      icon: Icon(widget.icon),
      onPressed: _handleOnPressed,
      label: Text(widget.text),
    );
  }
}
