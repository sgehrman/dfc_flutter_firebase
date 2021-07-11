import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:dfc_flutter_firebase/src/login/phone_verifier.dart';
import 'package:provider/provider.dart';

class LoginPhoneDialog extends StatefulWidget {
  @override
  _LoginPhoneDialogState createState() => _LoginPhoneDialogState();
}

class _LoginPhoneDialogState extends State<LoginPhoneDialog> {
  final PhoneVerifyier _phoneVerifier = PhoneVerifyier();
  final TextEditingController _smsCodeController = TextEditingController();
  TextEditingController? _phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _phoneController = TextEditingController();
    _phoneController!.text = Preferences.loginPhone ?? '';
  }

  @override
  void dispose() {
    _phoneController!.dispose();

    _smsCodeController.dispose();
    super.dispose();
  }

  List<Widget> _children(BuildContext context) {
    final PhoneVerifyier phoneVerifier = Provider.of<PhoneVerifyier>(context);

    if (!phoneVerifier.hasVerificationId) {
      return <Widget>[
        TextFormField(
          decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: 'Type a phone to format',
              hintStyle: TextStyle(color: Colors.black.withOpacity(.3)),
              errorStyle: const TextStyle(color: Colors.red)),
          keyboardType: TextInputType.phone,
          controller: _phoneController,
          inputFormatters: PhoneInputUtils.inputFormatters(),
          validator: (v) => PhoneInputUtils.validator(v),
        ),
      ];
    }

    return <Widget>[
      Text('A 6-digit code was sent to ${_phoneController!.text}'),
      TextField(
        keyboardType: TextInputType.number,
        controller: _smsCodeController,
        decoration: const InputDecoration(
          labelText: 'Verification code',
          helperText: 'Enter the 6-digit code',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        'Login with Phone',
        style: Theme.of(context).textTheme.headline5,
      ),
      contentPadding:
          const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        ChangeNotifierProvider.value(
          value: _phoneVerifier,
          child: Builder(
            builder: (BuildContext context) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _children(context),
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.lock_open, size: 16),
          onPressed: () async {
            if (!_phoneVerifier.hasVerificationId) {
              if (_formKey.currentState!.validate()) {
                print(formatAsPhoneNumber(_phoneController!.text));

                await _phoneVerifier.verifyPhoneNumber(_phoneController!.text);
              }
            } else {
              final SignInResult result = await AuthService().phoneSignIn(
                  _phoneVerifier.verificationId!,
                  _smsCodeController.text.trim());

              Navigator.of(context).pop(result);
            }
          },
          label: const Text('Login'),
        ),
      ],
    );
  }
}

Future<SignInResult?> showLoginPhoneDialog(BuildContext context) async {
  return showGeneralDialog<SignInResult>(
    barrierColor: Colors.black.withOpacity(0.5),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: LoginPhoneDialog(),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      // never gets called, but is required
      return Container();
    },
  );
}
