import 'dart:async';

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_utils.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/chat_widget.dart';
import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';

class ChatScreenContents extends StatefulWidget {
  const ChatScreenContents({
    required this.title,
    required this.name,
    required this.collectionPath,
  });

  final String title;
  final String name;
  final String collectionPath;

  @override
  _ChatScreenContentsState createState() => _ChatScreenContentsState();
}

class _ChatScreenContentsState extends State<ChatScreenContents> {
  final GlobalKey<ChatWidgetState> _chatWidgetKey =
      GlobalKey<ChatWidgetState>();

  StreamSubscription<List<ChatMessageModel?>>? _subscription;
  List<ChatMessageModel> _messages = [];

  @override
  void initState() {
    super.initState();

    _subscribe();

    final keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible) {
        // needs a delay so it scrolls after the keyboard is up and ready
        Timer(const Duration(milliseconds: 100), () {
          final scrollController = getScrollController;

          if (scrollController != null) {
            Utils.scrollToEndAnimated(scrollController, reversed: true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    super.dispose();
  }

  ScrollController? get getScrollController {
    return _chatWidgetKey.currentState?.scrollController;
  }

  void _subscribe() {
    bool firstTime = true;

    final Stream<List<ChatMessageModel>> stream =
        ChatMessageUtils.chatMessagesForUser(widget.collectionPath);

    _subscription = stream.listen(
      (data) {
        _messages = data;
        setState(() {});

        SchedulerBinding.instance.addPostFrameCallback((_) {
          final scrollController = getScrollController;
          if (scrollController != null) {
            if (firstTime) {
              firstTime = false;
              Utils.scrollToEnd(scrollController, reversed: true);
            } else {
              Utils.scrollToEndAnimated(scrollController, reversed: true);
            }
          }
        });
      },
      onError: (Object error) {
        // setState(() {
        //   _summary = widget.afterError(_summary, error);
        // });
      },
      onDone: () {
        // setState(() {
        //   _summary = widget.afterDone(_summary);
        // });
      },
    );
  }

  IconButton _scrollToBottomButton() {
    return IconButton(
      icon: const Icon(Icons.keyboard_arrow_down),
      onPressed: () {
        final scrollController = getScrollController;

        if (scrollController != null) {
          Utils.scrollToEndAnimated(scrollController, reversed: true);
        }
      },
    );
  }

  ChatUserModel _getUser() {
    final userProvider = context.read<FirebaseUserProvider>();

    if (userProvider.hasUser) {
      return ChatUserModel(
        name: userProvider.displayName,
        email: userProvider.email,
        userId: userProvider.userId,
        avatar: userProvider.photoUrl,
      );
    }

    return ChatUserModel(
      name: 'No user',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [_scrollToBottomButton()],
      ),
      body: Builder(
        builder: (context) {
          List<ChatMessageModel>? messages = _messages;

          if (Utils.isNotEmpty(messages)) {
            messages = messages.reversed.take(100).toList();
          } else {
            messages = [
              ChatMessageModel(
                user: ChatUserModel(
                  // userId:  '' just a generic message, no user
                  name: widget.name,
                ),
                text: 'Hi, send us your suggestions, comments, criticisms etc.',
              ),
            ];
          }

          return ChatWidget(
            key: _chatWidgetKey,
            messages: messages,
            userModel: _getUser(),
            onPressAvatar: (ChatUserModel user) {
              print('OnPressAvatar: ${user.name}');
            },
            onLongPressAvatar: (ChatUserModel user) {
              print('OnLongPressAvatar: ${user.name}');
            },
          );
        },
      ),
    );
  }
}
