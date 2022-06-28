import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore_converter.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_utils.dart';

class ChatMessageUtils {
  static Stream<List<ChatMessageModel>> chatMessagesForUser(
    String collectionPath,
  ) {
    final collection = Collection(collectionPath);

    final Query<Map<String, dynamic>> query =
        collection.ref.orderBy('timestamp');

    return query.snapshots().map(
          (v) => v.docs
              .map(
                (doc) => FirestoreConverter.convert(
                  ChatMessageModel,
                  doc.data(),
                  doc.id,
                  Document.withRef(doc.reference),
                ) as ChatMessageModel,
              )
              .toList(),
        );
  }

  static Future<List<ChatMessageModel?>> getMessagesForUser(String userId) {
    return Collection('/private/$userId/messages').getData<ChatMessageModel>();
  }

  static Future<bool> uploadChatMessage(ChatMessageModel model) async {
    final collection = Collection('messages');

    try {
      await collection.document(model.id).upsert(model.toJson());

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

  static Future<bool> deleteMessages(String userId) async {
    final List<ChatMessageModel?> list = await getMessagesForUser(userId);

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
}
