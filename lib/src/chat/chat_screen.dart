import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_widget_admin.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_widget_user.dart';
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
  ScrollController scrollController = ScrollController(keepScrollOffset: false);

  IconButton _scrollToBottomButton() {
    return IconButton(
      icon: const Icon(Icons.keyboard_arrow_down),
      onPressed: () {
        Utils.scrollToEndAnimated(scrollController, reversed: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<FirebaseUserProvider>(context);

    Widget content;

    if (widget.admin && userProvider.isAdmin) {
      content = ChatWidgetAdmin(
        title: widget.title,
        name: widget.name,
        collectionPath: widget.collectionPath,
      );
    } else {
      content = ChatWidgetUser(
        scrollController: scrollController,
        collectionPath: widget.collectionPath,
        title: widget.title,
        name: widget.name,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [_scrollToBottomButton()],
      ),
      body: content,
    );
  }
}
