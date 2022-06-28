import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/chat_input.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/message_listview.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    required this.messages,
    required this.userModel,
    required this.collectionPath,
    required this.scrollController,
    this.onLongPressAvatar,
    this.onLongPressMessage,
    this.onPressAvatar,
  });

  final List<ChatMessageModel> messages;
  final ChatUserModel userModel;
  final String collectionPath;
  final Function(ChatUserModel)? onPressAvatar;
  final Function(ChatUserModel)? onLongPressAvatar;
  final Function(ChatMessageModel)? onLongPressMessage;
  final ScrollController scrollController;

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MessageListView(
          scrollController: widget.scrollController,
          userModel: widget.userModel,
          messages: widget.messages,
          onLongPressAvatar: widget.onLongPressAvatar,
          onPressAvatar: widget.onPressAvatar,
          onLongPressMessage: widget.onLongPressMessage,
        ),
        ChatInput(
          collectionPath: widget.collectionPath,
          userModel: widget.userModel,
        ),
      ],
    );
  }
}
