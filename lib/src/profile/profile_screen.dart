import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:dfc_flutter_firebase/src/profile/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<FirebaseUserProvider>(context);

    String userName = 'Profile';
    if (userProvider.hasUser) {
      userName = userProvider.identity;
    }

    return Scaffold(
      appBar: AppBar(title: Text(userName)),
      body: ProfileWidget(),
    );
  }
}
