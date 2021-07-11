import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_models.dart';
import 'package:intl/intl.dart';
import 'package:dfc_flutter/dfc_flutter.dart';

class MessageContainer extends StatelessWidget {
  const MessageContainer({
    required this.message,
    this.isUser,
  });

  final ChatMessage message;
  final bool? isUser;

  Widget bubble() {
    if (message.text!.isNotEmpty) {
      Widget child;

      if (message.text == '_tu_') {
        child = const Icon(
          Icons.thumb_up,
          color: Colors.white,
        );
      } else {
        child = ParsedText(
          parse: Utils.matchArray(),
          text: message.text!,
          style: const TextStyle(
            color: Colors.white,
          ),
        );
      }

      return Bubble(
        color: isUser! ? Utils.darken(Colors.blue) : Utils.darken(Colors.green),
        nip: isUser! ? BubbleNip.rightBottom : BubbleNip.leftBottom,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: child,
        ),
      );
    }

    return NothingWidget();
  }

  String userName() {
    String? result = '';

    if (message.user.name != null && message.user.name!.isNotEmpty) {
      result = message.user.name;
    } else if (message.user.email != null && message.user.email!.isNotEmpty) {
      result = message.user.email;
    }

    if (result!.isNotEmpty) {
      result += ',  ';
    }

    return result + DateFormat('EEE h:mm a').format(message.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: Column(
          crossAxisAlignment:
              isUser! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            bubble(),
            if (Utils.isNotEmpty(message.image))
              SuperImage(
                SuperImageSource(url: message.image),
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
                enableViewer: true,
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                userName(),
                style: TextStyle(
                  fontSize: 10.0,
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
