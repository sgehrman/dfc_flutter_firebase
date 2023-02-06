import 'dart:async';

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_message_utils.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/chat_widget.dart';
import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';

class ChatWidgetUser extends StatefulWidget {
  const ChatWidgetUser({
    required this.title,
    required this.name,
    required this.collectionPath,
    required this.scrollController,
  });

  final String title;
  final String name;
  final String collectionPath;
  final ScrollController scrollController;

  @override
  _ChatWidgetUserState createState() => _ChatWidgetUserState();
}

class _ChatWidgetUserState extends State<ChatWidgetUser> {
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
          Utils.scrollToEndAnimated(widget.scrollController, reversed: true);
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

  void _subscribe() {
    bool firstTime = true;

    final Stream<List<ChatMessageModel>> stream =
        ChatMessageUtils.chatMessagesForUser(
      collectionPath: widget.collectionPath,
    );

    _subscription = stream.listen(
      (data) {
        _messages = data;
        setState(() {});

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (firstTime) {
            firstTime = false;
            Utils.scrollToEnd(widget.scrollController, reversed: true);
          } else {
            Utils.scrollToEndAnimated(widget.scrollController, reversed: true);
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

  ChatUserModel _getUser() {
    final userProvider = context.read<FirebaseUserProvider>();

    print(
      '${userProvider.identity} ${userProvider.email} ${userProvider.userId} ${userProvider.photoUrl} ',
    );

    if (userProvider.hasUser) {
      return ChatUserModel(
        name: userProvider.identity,
        email: userProvider.email,
        phone: userProvider.phoneNumber,
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
    List<ChatMessageModel>? messages = _messages;

    if (Utils.isNotEmpty(messages)) {
      messages = messages.reversed.take(100).toList();
    } else {
      messages = [
        ChatMessageModel(
          user: ChatUserModel(
            // just a generic message, no user
            name: widget.name,
          ),
          text: 'Hi, send us your suggestions, comments, criticisms etc.',
        ),
      ];
    }

    return ChatWidget(
      scrollController: widget.scrollController,
      collectionPath: widget.collectionPath,
      messages: messages,
      userModel: _getUser(),
      onPressAvatar: (ChatUserModel user) {
        print('OnPressAvatar: $user');
      },
      onLongPressAvatar: (ChatUserModel user) {
        print('OnLongPressAvatar: ${user.name}');
      },
    );
  }
}
