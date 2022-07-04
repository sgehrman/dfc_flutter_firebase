import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:dfc_flutter_firebase/src/login/user_login_button.dart';
import 'package:flutter/material.dart';

class UserLoginView extends StatefulWidget {
  const UserLoginView({
    this.googleClientId,
    this.anonymousLogin = true,
    this.appleLogin = false,
  });

  final bool anonymousLogin;
  final bool appleLogin;
  final String? googleClientId;

  @override
  State<StatefulWidget> createState() => UserLoginViewState();
}

class UserLoginViewState extends State<UserLoginView> {
  UserLoginViewState() {
    _setup();
  }

  AuthService auth = AuthService();
  String appName = '';

  Future<void> _setup() async {
    final name = await Utils.getAppName();

    setState(() {
      appName = name;
    });
  }

  List<Widget> _buttons() {
    final List<Widget> result = [];

    result.addAll(<Widget>[
      const UserLoginButton(
        text: 'Login with Email',
        icon: Icons.email,
        type: 'email',
      ),
      const SizedBox(height: 10),
      const UserLoginButton(
        text: 'Login with Phone',
        icon: Icons.phone,
        type: 'phone',
      ),
      const SizedBox(height: 10),
      UserLoginButton(
        text: 'Login with Google',
        icon: Icons.golf_course, // SNG needs svg
        type: 'google',
        googleClientId: widget.googleClientId,
      ),
    ]);

    if (widget.appleLogin && Utils.isIOS || Utils.isMacOS) {
      result.addAll(<Widget>[
        const SizedBox(height: 10),
        const UserLoginButton(
          text: 'Sign in With Apple',
          icon: Icons.person, // not used
          type: 'apple',
        ),
      ]);
    }

    if (widget.anonymousLogin) {
      result.addAll(<Widget>[
        const SizedBox(height: 4),
        const UserLoginButton(
          text: 'Anonymous Login',
          icon: Icons.person,
          type: 'anon',
        ),
      ]);
    }

    return result;
  }

  Widget loginButtons(BuildContext context) {
    // IntrinsicWidth and CrossAxisAlignment.stretch make all children equal width
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buttons(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text(
            appName,
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          Text(
            'Login to get started',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 40),
          loginButtons(context),
        ],
      ),
    );
  }
}
