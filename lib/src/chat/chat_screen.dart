import 'package:dfc_flutter_firebase/src/chat/chat_admin_screen_contents.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_screen_contents.dart';
import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.title,
    required this.collectionPath,
    required this.name,
    this.admin = false,
  });

  final String title;
  final String name;
  final bool admin;
  final String collectionPath;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<FirebaseUserProvider>(context);

    if (widget.admin && userProvider.isAdmin) {
      return ChatAdminScreenContents(
        title: widget.title,
        name: widget.name,
        collectionPath: widget.collectionPath,
      );
    }

    return ChatScreenContents(
      collectionPath: widget.collectionPath,
      title: widget.title,
      name: widget.name,
    );
  }
}
