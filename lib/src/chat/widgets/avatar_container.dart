import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:flutter/material.dart';

class AvatarContainer extends StatelessWidget {
  const AvatarContainer({
    required this.user,
    this.onPress,
    this.onLongPress,
    this.isUser,
  });

  final ChatUserModel user;
  final bool? isUser;
  final void Function(ChatUserModel)? onPress;
  final void Function(ChatUserModel)? onLongPress;

  ImageProvider? avatarImage() {
    if (user.avatar.isNotEmpty) {
      return NetworkImage(user.avatar);
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
        backgroundColor: isUser! ? Colors.blue[600] : Colors.green[600],
        foregroundColor: Colors.white,
        child: Text(user.initials),
      ),
    );
  }
}
