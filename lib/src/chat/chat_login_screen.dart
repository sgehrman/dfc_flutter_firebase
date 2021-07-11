import 'package:flutter/material.dart';

class ChatLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connecting')),
      body: const Center(
        child: Text('Connecting to Chat.'),
      ),
    );
  }
}
