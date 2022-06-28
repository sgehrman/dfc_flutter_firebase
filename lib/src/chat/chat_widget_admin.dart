import 'dart:math' as math;

import 'package:dfc_flutter_firebase/src/chat/chat_message_utils.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_widget_user.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore_converter.dart';
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
  ChatMessageModel? _clickedChat;
  List<ChatMessageModel> _chatMessages = [];

  @override
  void initState() {
    super.initState();

    stream = ChatMessageUtils.chatMessagesForUser(
      collectionPath: widget.collectionPath,
    );

    _queryChats();
  }

  Future<void> _queryChats() async {
    final store = AuthService().store;

    if (store != null) {
      try {
        final query = store.collectionGroup('messages');

        final snapshot = await query.snapshots().first;

        final results = snapshot.docs.map(
          (doc) {
            return FirestoreConverter.convert(
              ChatMessageModel,
              doc.data(),
              doc.id,
              Document.withRef(doc.reference),
            ) as ChatMessageModel;
          },
        ).toList();

        final Map<String, ChatMessageModel> map = {};

        // we only need the last message, so this limits it to one message per user
        for (final r in results) {
          map[r.user.userId] = r;
        }

        _chatMessages = map.values.toList();
        setState(() {});
      } catch (err) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: _chatMessages.length,
          itemBuilder: (context, index) {
            final ChatMessageModel chat = _chatMessages[index];

            final String title =
                'From: ${chat.user.userId} message: ${chat.text.substring(0, math.min(10, chat.text.length))}';

            return ListTile(
              title: Text(title),
              onTap: () {
                _clickedChat = chat;
                setState(() {});
                // Navigator.of(context).push(
                //   MaterialPageRoute<void>(
                //     builder: (context) => ChatScreen(
                //       title: widget.title,
                //       name: widget.name,
                //       collectionPath: widget.collectionPath,
                //     ),
                //   ),
                // );
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
        ),
        if (_clickedChat != null)
          Positioned.fill(
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ChatWidgetUser(
                title: 'Admin',
                name: 'admin',
                collectionPath: ChatMessageUtils.userIdToCollectionPath(
                  _clickedChat?.user.userId ?? '',
                ),
                scrollController: ScrollController(),
              ),
            ),
          ),
      ],
    );
  }
}
