import 'dart:math' as math;

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_widget_user.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_utils.dart';
import 'package:flutter/material.dart';

class ChatWidgetAdmin extends StatefulWidget {
  const ChatWidgetAdmin({
    required this.title,
    required this.name,
    required this.collectionPath,
  });

  final String title;
  final String name;
  final String collectionPath;

  @override
  _ChatWidgetAdminState createState() => _ChatWidgetAdminState();
}

class _ChatWidgetAdminState extends State<ChatWidgetAdmin> {
  late Stream<List<ChatMessageModel>> stream;

  @override
  void initState() {
    super.initState();

    stream = ChatMessageUtils.chatMessagesForUser(
      collectionPath: widget.collectionPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Admin')),
      body: StreamBuilder<List<ChatMessageModel>>(
        stream: stream,
        builder: (context, snap) {
          bool hasData = false;

          if (snap.hasError) {
            print('snap.hasError');
            print(snap);
          }

          if (snap.hasData && !snap.hasError) {
            hasData = true;
          }

          if (hasData) {
            final List<ChatMessageModel> resources = snap.data ?? [];

            return ListView.builder(
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final ChatMessageModel chat = resources[index];

                final String title =
                    'From: ${chat.user.userId} message: ${chat.text.substring(0, math.min(10, chat.text.length))}';

                return ListTile(
                  title: Text(title),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => ChatWidgetUser(
                          title: widget.title,
                          name: widget.name,
                          collectionPath: widget.collectionPath,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      final deleteStream = ChatMessageUtils.chatMessagesForUser(
                        collectionPath: widget.collectionPath,
                      );

                      ChatMessageUtils.deleteMessagesFromStream(
                        stream: deleteStream,
                        collectionPath: widget.collectionPath,
                      );
                    },
                  ),
                );
              },
            );
          }

          return const LoadingWidget();
        },
      ),
    );
  }
}
