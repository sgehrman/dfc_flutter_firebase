import 'package:flutter/material.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/chat_models.dart';

class AvatarContainer extends StatelessWidget {
  const AvatarContainer({
    required this.user,
    this.onPress,
    this.onLongPress,
    this.isUser,
  });

  final ChatUser user;
  final bool? isUser;
  final void Function(ChatUser)? onPress;
  final void Function(ChatUser)? onLongPress;

  ImageProvider? avatarImage() {
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      return NetworkImage(user.avatar!);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress?.call(user);
      },
      onLongPress: () {
        onLongPress?.call(user);
      },
      child: CircleAvatar(
        backgroundImage: avatarImage(),
        backgroundColor: isUser!
            ? Utils.darken(Colors.blue, .2)
            : Utils.darken(Colors.green, .2),
        foregroundColor: Colors.white,
        child: Text(user.initials),
      ),
    );
  }
}
