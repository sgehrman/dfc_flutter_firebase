import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:intl/intl.dart';

class MessageContainer extends StatelessWidget {
  const MessageContainer({
    required this.message,
    required this.isUser,
  });

  final ChatMessageModel message;
  final bool isUser;

  Widget _bubble() {
    if (message.text.isNotEmpty) {
      Widget child;

      if (message.text == '_tu_') {
        child = const Icon(
          Icons.thumb_up,
          color: Colors.white,
        );
      } else {
        child = ParsedText(
          parse: Utils.matchArray(),
          text: message.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        );
      }

      return ChatBubble(
        clipper: isUser
            ? ChatBubbleClipper1(type: BubbleType.sendBubble)
            : ChatBubbleClipper1(type: BubbleType.receiverBubble),
        backGroundColor: isUser ? Colors.blue[600] : Colors.green[600],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: child,
      );
    }

    return NothingWidget();
  }

  String userName() {
    String? result = '';

    if (message.user.name.isNotEmpty) {
      result = message.user.name;
    } else if (message.user.email.isNotEmpty) {
      result = message.user.email;
    }

    if (result.isNotEmpty) {
      result += ',  ';
    }

    return result +
        DateFormat('EEE h:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(message.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        padding: const EdgeInsets.only(right: 8, left: 8),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            _bubble(),
            if (Utils.isNotEmpty(message.image))
              Image.network(
                message.image,
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                userName(),
                style: TextStyle(
                  fontSize: 10,
                  color: Utils.isDarkMode(context)
                      ? Colors.white54
                      : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
