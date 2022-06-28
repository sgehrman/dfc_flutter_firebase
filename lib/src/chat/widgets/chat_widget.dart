import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/chat_input.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/message_listview.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    required this.messages,
    required this.user,
    required this.toUid,
    this.onLongPressAvatar,
    this.onLongPressMessage,
    this.onPressAvatar,
    Key? key,
  }) : super(key: key);

  final List<ChatMessageModel> messages;
  final ChatUserModel user;
  final String? toUid;
  final Function(ChatUserModel)? onPressAvatar;
  final Function(ChatUserModel)? onLongPressAvatar;
  final Function(ChatMessageModel)? onLongPressMessage;

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController(keepScrollOffset: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MessageListView(
          scrollController: scrollController,
          user: widget.user,
          messages: widget.messages,
          onLongPressAvatar: widget.onLongPressAvatar,
          onPressAvatar: widget.onPressAvatar,
          onLongPressMessage: widget.onLongPressMessage,
        ),
        ChatInput(
          toUid: widget.toUid,
          user: widget.user,
        ),
      ],
    );
  }
}
