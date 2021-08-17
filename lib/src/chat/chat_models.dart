import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:dfc_flutter_firebase/src/firebase/serializable.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_model.dart';

class ChatUser {
  ChatUser({
    this.uid,
    this.name,
    this.email,
    this.avatar,
  });

  ChatUser.fromJson(Map<dynamic, dynamic> json) {
    uid = json.strVal('uid');
    name = json.strVal('name');
    email = json.strVal('email');
    avatar = json.strVal('avatar');
  }

  String? uid;
  String? name;
  String? email;
  String? avatar;

  String get initials {
    String result = '?';

    if (name != null && name!.isNotEmpty) {
      result = name![0];

      final List<String> names = name!.split(' ');
      if (names.length > 1) {
        final String lastName = names.last;

        if (lastName.isNotEmpty) {
          result += lastName[0];
        }
      }
    } else if (email != null && email!.isNotEmpty) {
      result = email![0];

      if (email!.length > 1) {
        result += email![1];
      }
    }

    return result.toUpperCase();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['uid'] = uid;
    data['name'] = name;
    data['email'] = email;
    data['avatar'] = avatar;

    return data;
  }
}

// ====================================================================

class ChatMessage extends Serializable {
  ChatMessage({
    required this.text,
    required this.user,
    required this.toUid,
    this.id,
    this.image,
    this.imageId,
    DateTime? createdAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  ChatMessage.fromMap(Map json) {
    id = json.strVal('id');
    text = json.strVal('text');
    image = json.strVal('image');
    imageId = json.strVal('imageId');
    createdAt = DateTime.fromMillisecondsSinceEpoch(json.intVal('createdAt'));
    user = ChatUser.fromJson(json.mapVal<dynamic, dynamic>('user')!);
    toUid = json.strVal('toUid');
  }

  String? text;
  late DateTime createdAt;
  late ChatUser user;
  String? toUid;
  String? image;
  String? imageId;
  String? id;

  @override
  Map<String, dynamic> toMap({bool types = false}) {
    final Map<String, dynamic> data = <String, dynamic>{};

    try {
      data['id'] = id;
      data['text'] = text;
      data['image'] = image;
      data['imageId'] = imageId;
      data['createdAt'] = createdAt.millisecondsSinceEpoch;
      data['user'] = user.toJson();
      data['toUid'] = toUid;
    } catch (e) {
      print(e);
    }
    return data;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class ChatMessageUtils {
  static Stream<List<ChatMessage>> stream({
    List<WhereQuery>? where,
  }) {
    final c = Collection('messages');

    if (Utils.isNotEmpty(where)) {
      return c.orderedStreamData<ChatMessage>(
        where: where,
      );
    }

    return c.orderedStreamData();
  }

  static Future<List<ChatMessage?>> getData() {
    return Collection('messages').getData<ChatMessage>();
  }

  static Future<bool> uploadChatMessage(ChatMessage resource) async {
    final collection = Collection('messages');

    try {
      await collection.addOrdered(resource.toMap());

      return true;
    } catch (error) {
      print('uploadChatMessage exception: $error');

      return false;
    }
  }

  static Future<bool> deleteChatMessage(String? id) async {
    final doc = Document('messages/$id');

    try {
      final ChatMessage? message = await doc.getData<ChatMessage>();
      if (Utils.isNotEmpty(message?.imageId)) {
        await ImageUrlUtils.deleteImageStorage(
          message!.imageId,
          ImageUrlUtils.chatImageFolder,
        );
      }

      await doc.delete();

      return true;
    } catch (error) {
      print('deleteChatMessage exception: $error');

      return false;
    }
  }

  static Future<bool> deleteMessagesFromStream(
    Stream<List<ChatMessage?>> chatStream,
  ) async {
    final List<ChatMessage?> list = await chatStream.first;

    for (final ChatMessage? chat in list) {
      await deleteChatMessage(chat!.id);
    }

    return true;
  }

  static Future<bool> deleteChatMessages() async {
    final List<ChatMessage?> list = await getData();

    await Future.forEach(list, (ChatMessage? item) {
      if (Utils.isNotEmpty(item!.imageId)) {
        ImageUrlUtils.deleteImageStorage(
          item.imageId,
          ImageUrlUtils.chatImageFolder,
        );
      }
    });

    return Collection('messages').delete();
  }

  static Future<bool> updateChatMessages(List<ChatMessage> list) async {
    await deleteChatMessages();

    // can't use normal forEach
    await Future.forEach(list, (ChatMessage item) {
      return ChatMessageUtils.uploadChatMessage(item);
    });

    return true;
  }
}
