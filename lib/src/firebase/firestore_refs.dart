import 'package:dfc_flutter_firebase/src/chat/chat_models.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';

typedef FirestoreRefConverter = dynamic Function(
    Type t, Map<String, dynamic> data, String id, Document document);

class FirestoreRefs {
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

    if (t == ChatMessage) {
      return ChatMessage.fromMap(data);
    } else {
      if (converter != null) {
        return converter!(t, data, id, document);
      }
    }
  }
}
