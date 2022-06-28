import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore_converter.dart';
import 'package:dfc_flutter_firebase/src/image/image_url_utils.dart';

class ChatMessageUtils {
  static String userIdToCollectionPath(String userId) =>
      '/private/$userId/messages';

  static String userIdToDocumentPath(String userId, String docId) =>
      '${userIdToCollectionPath(userId)}/messages/$docId';

  static Stream<List<ChatMessageModel>> chatMessagesForUser({
    required String collectionPath,
  }) {
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

  static Future<List<ChatMessageModel?>> getMessagesForUser({
    required String collectionPath,
  }) {
    return Collection(collectionPath).getData<ChatMessageModel>();
  }

  static Future<bool> uploadChatMessage({
    required String collectionPath,
    required ChatMessageModel model,
  }) async {
    final collection = Collection(collectionPath);

    try {
      await collection.document(model.id).upsert(model.toJson());

      return true;
    } catch (error) {
      print('uploadChatMessage exception: $error');

      return false;
    }
  }

  static Future<bool> deleteChatMessage({
    required String collectionPath,
    required String id,
  }) async {
    final doc = Document('$collectionPath/$id');

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

  static Future<bool> deleteMessagesFromStream({
    required Stream<List<ChatMessageModel?>> stream,
    required String collectionPath,
  }) async {
    final List<ChatMessageModel?> list = await stream.first;

    for (final ChatMessageModel? chat in list) {
      await deleteChatMessage(collectionPath: collectionPath, id: chat!.id);
    }

    return true;
  }

  static Future<bool> deleteMessages({required String collectionPath}) async {
    final List<ChatMessageModel?> list =
        await getMessagesForUser(collectionPath: collectionPath);

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
