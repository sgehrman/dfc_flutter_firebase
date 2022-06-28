import 'package:dfc_flutter_firebase/src/chat/models/chat_message_model.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';

typedef FirestoreRefConverter = dynamic Function(
  Type t,
  Map<String, dynamic> data,
  String id,
  Document document,
);

class FirestoreConverter {
  static FirestoreRefConverter? converter;

  static dynamic convert(
    Type t,
    Map<String, dynamic>? data,
    String id,
    Document document,
  ) {
    // data is null if you try to get a specific object and it doesn't exist.
    if (data == null) {
      // this should never happen, it would break null-safety
      return null;
    }

    // always adding id so we can delete by id if needed
    data['id'] = id;

    if (t == ChatMessageModel) {
      final result = ChatMessageModel.fromJson(data);
      result.document = document;

      return result;
    } else {
      if (converter != null) {
        return converter!(t, data, id, document);
      } else {
        print('### $t not found in FirestoreRefs.convert');
      }
    }
  }
}
