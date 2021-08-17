import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_models.dart';
import 'package:dfc_flutter_firebase/src/chat/widgets/chat_widget.dart';
import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';

class ChatScreenContents extends StatefulWidget {
  const ChatScreenContents({
    required this.stream,
    this.isAdmin = false,
    required this.toUid,
    required this.title,
    required this.name,
  });

  final Stream<List<ChatMessage>> stream;
  final bool isAdmin;
  final String? toUid;
  final String title;
  final String name;

  @override
  _ChatScreenContentsState createState() => _ChatScreenContentsState();
}

class _ChatScreenContentsState extends State<ChatScreenContents> {
  final GlobalKey<ChatWidgetState> _chatWidgetKey =
      GlobalKey<ChatWidgetState>();

  StreamSubscription<List<ChatMessage?>>? _subscription;

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
    _unsubscribe();
    super.dispose();
  }

  ScrollController? get getScrollController {
    return _chatWidgetKey.currentState?.scrollController;
  }

  void _subscribe() {
    bool firstTime = true;

    _subscription = widget.stream.listen(
      (data) {
        SchedulerBinding.instance!.addPostFrameCallback((_) {
          final scrollController = getScrollController;
          if (scrollController != null) {
            if (firstTime) {
              firstTime = false;
              Utils.scrollToEnd(scrollController, reversed: true);

              // Todo: SNG this isn't updating if new items are added that would cause the scroll to add elevation
              // we don't get onScrolled window first comes up since we are already scrolled to the bottom (reverse mode)
              // but we need to sync elevation
              // onScrolled();
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

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
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

  ChatUser _getUser() {
    final userProvider =
        Provider.of<FirebaseUserProvider>(context, listen: false);

    if (userProvider.hasUser) {
      return ChatUser(
        name: userProvider.displayName,
        email: userProvider.email,
        uid: widget.isAdmin ? 'admin' : userProvider.userId,
        avatar: userProvider.photoUrl,
      );
    }

    return ChatUser(
      name: 'No user',
      uid: '',
      avatar: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [_scrollToBottomButton()],
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: widget.stream,
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
            List<ChatMessage>? messages = snap.data;

            if (Utils.isNotEmpty(messages)) {
              messages!.sort((ChatMessage a, ChatMessage b) {
                return a.createdAt.compareTo(b.createdAt);
              });
              messages = messages.reversed.take(100).toList();
            } else {
              messages = [
                ChatMessage(
                  toUid: widget.toUid,
                  user: ChatUser(
                    uid: 'admin',
                    name: widget.name,
                  ),
                  text:
                      'Hi, this is a community chat open to members.  Discuss whatever you like.',
                ),
              ];
            }

            return ChatWidget(
              key: _chatWidgetKey,
              messages: messages,
              user: _getUser(),
              toUid: widget.toUid,
              onPressAvatar: (ChatUser user) {
                print('OnPressAvatar: ${user.name}');
              },
              onLongPressAvatar: (ChatUser user) {
                print('OnLongPressAvatar: ${user.name}');
              },
            );
          }

          return LoadingWidget();
        },
      ),
    );
  }
}
