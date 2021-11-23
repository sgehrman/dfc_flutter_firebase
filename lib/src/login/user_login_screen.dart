import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:dfc_flutter_firebase/src/login/user_login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({
    this.title,
    this.anonymousLogin = true,
  });

  final String? title;
  final bool anonymousLogin;

  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // remove window once logged in
    final userProvider = Provider.of<FirebaseUserProvider>(context);
    if (userProvider.hasUser) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }

    return Scaffold(
      // without the app bar, the status bar text was white on white
      appBar: AppBar(title: Text(widget.title ?? '')),
      body: UserLoginView(
        anonymousLogin: widget.anonymousLogin,
      ),
    );
  }
}
