import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_model.dart';

class ChatMessageUtils {
  static Stream<List<ChatMessageModel>> stream({
    List<WhereQuery>? where,
  }) {
    final c = Collection('messages');

    if (Utils.isNotEmpty(where)) {
      return c.orderedStreamData<ChatMessageModel>(
        where: where,
      );
    }

    return c.orderedStreamData();
  }

  static Future<List<ChatMessageModel?>> getData() {
    return Collection('messages').getData<ChatMessageModel>();
  }

  static Future<bool> uploadChatMessage(ChatMessageModel resource) async {
    final collection = Collection('messages');

    try {
      await collection.addOrdered(resource.toJson());

      return true;
    } catch (error) {
      print('uploadChatMessage exception: $error');

      return false;
    }
  }

  static Future<bool> deleteChatMessage(String? id) async {
    final doc = Document('messages/$id');

    try {
      final ChatMessageModel? message = await doc.getData<ChatMessageModel>();
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
    Stream<List<ChatMessageModel?>> chatStream,
  ) async {
    final List<ChatMessageModel?> list = await chatStream.first;

    for (final ChatMessageModel? chat in list) {
      await deleteChatMessage(chat!.id);
    }

    return true;
  }

  static Future<bool> deleteChatMessages() async {
    final List<ChatMessageModel?> list = await getData();

    await Future.forEach(list, (ChatMessageModel? item) {
      if (Utils.isNotEmpty(item!.imageId)) {
        ImageUrlUtils.deleteImageStorage(
          item.imageId,
          ImageUrlUtils.chatImageFolder,
        );
      }
    });

    return Collection('messages').delete();
  }

  static Future<bool> updateChatMessages(List<ChatMessageModel> list) async {
    await deleteChatMessages();

    // can't use normal forEach
    await Future.forEach(list, (ChatMessageModel item) {
      return ChatMessageUtils.uploadChatMessage(item);
    });

    return true;
  }
}
