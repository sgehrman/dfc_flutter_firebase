import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/avatar_container.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/message_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    required this.userModel,
    this.scrollController,
    this.messages,
    this.onLongPressAvatar,
    this.onLongPressMessage,
    this.onPressAvatar,
    this.renderAvatarOnTop,
    this.changeVisible,
    this.visible,
  });

  final List<ChatMessageModel>? messages;
  final ChatUserModel userModel;
  final void Function(ChatUserModel)? onPressAvatar;
  final void Function(ChatUserModel)? onLongPressAvatar;
  final bool? renderAvatarOnTop;
  final void Function(ChatMessageModel)? onLongPressMessage;
  final ScrollController? scrollController;
  final Function? changeVisible;
  final bool? visible;

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  bool showDateFlag(int index) {
    bool showDate = false;

    if (index == widget.messages!.length - 1) {
      showDate = true;
    } else {
      final DateTime nextDate = DateTime.fromMillisecondsSinceEpoch(
        widget.messages![index + 1].timestamp,
      );

      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
        widget.messages![index].timestamp,
      );

      if (nextDate.difference(date).inDays != 0) {
        showDate = true;
      }
    }

    return showDate;
  }

  Widget dateWidget({required bool showDate, required int index}) {
    if (showDate) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          DateFormat('MMM dd').format(
            DateTime.fromMillisecondsSinceEpoch(
              widget.messages![index].timestamp,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    }

    return NothingWidget();
  }

  Widget avatarWidget({required int index, required bool leftSide}) {
    final bool isUser =
        widget.messages![index].user.userId == widget.userModel.userId;
    bool addAvatar = false;

    if (leftSide && !isUser) {
      addAvatar = true;
    } else if (!leftSide && isUser) {
      addAvatar = true;
    }

    if (addAvatar) {
      return AvatarContainer(
        user: widget.messages![index].user,
        onPress: widget.onPressAvatar,
        onLongPress: widget.onLongPressAvatar,
        isUser: isUser,
      );
    }

    return NothingWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // hides keyboard
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            controller: widget.scrollController,
            reverse: true,
            itemCount: widget.messages!.length,
            itemBuilder: (context, i) {
              final bool showDate = showDateFlag(i);

              return Align(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: <Widget>[
                      dateWidget(showDate: showDate, index: i),
                      Row(
                        mainAxisAlignment: widget.messages![i].user.userId ==
                                widget.userModel.userId
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          avatarWidget(index: i, leftSide: true),
                          GestureDetector(
                            onLongPress: () {
                              if (widget.onLongPressMessage != null) {
                                widget.onLongPressMessage!(widget.messages![i]);
                              } else {
                                showBottomSheet<dynamic>(
                                  context: context,
                                  builder: (context) => Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color:
                                              Color.fromRGBO(180, 180, 180, 1),
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.content_copy),
                                      title: const Text('Copy to clipboard'),
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: widget.messages![i].text,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            child: MessageContainer(
                              isUser: widget.messages![i].user.userId ==
                                  widget.userModel.userId,
                              message: widget.messages![i],
                            ),
                          ),
                          avatarWidget(index: i, leftSide: false),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
