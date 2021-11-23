import 'dart:math' as math;

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_models.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_screen_contents.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:flutter/material.dart';

class ChatAdminScreenContents extends StatefulWidget {
  const ChatAdminScreenContents({
    required this.title,
    required this.name,
  });

  final String title;
  final String name;

  @override
  _ChatAdminScreenContentsState createState() =>
      _ChatAdminScreenContentsState();
}

class _ChatAdminScreenContentsState extends State<ChatAdminScreenContents> {
  final Stream<List<ChatMessage>> stream = ChatMessageUtils.stream(
    where: [WhereQuery('', 'admin')],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Admin')),
      body: StreamBuilder<List<ChatMessage>>(
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
            final List<ChatMessage> resources = snap.data ?? [];

            return ListView.builder(
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final ChatMessage chat = resources[index];

                final String title =
                    'From: ${chat.user.uid} message: ${chat.text!.substring(0, math.min(10, chat.text!.length))}';

                return ListTile(
                  title: Text(title),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => ChatScreenContents(
                          toUid: chat.user.uid,
                          stream: ChatMessageUtils.stream(
                            where: [
                              WhereQuery(chat.user.uid, 'admin'),
                              WhereQuery('admin', chat.user.uid),
                            ],
                          ),
                          isAdmin: true,
                          title: widget.title,
                          name: widget.name,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      final deleteStream = ChatMessageUtils.stream(
                        where: [
                          WhereQuery(chat.user.uid, 'admin'),
                          WhereQuery('admin', chat.user.uid),
                        ],
                      );

                      ChatMessageUtils.deleteMessagesFromStream(deleteStream);
                    },
                  ),
                );
              },
            );
          }
          return LoadingWidget();
        },
      ),
    );
  }
}
