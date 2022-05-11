import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore_refs.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:stream_transform/stream_transform.dart';

class WhereQuery {
  WhereQuery(this.fromUid, this.toUid);

  String? fromUid;
  String? toUid;

  Query where(Query query) {
    Query result = query;

    if (Utils.isNotEmpty(fromUid)) {
      result = result.where('user.uid', isEqualTo: fromUid);
    }

    if (Utils.isNotEmpty(toUid)) {
      result = result.where('toUid', isEqualTo: toUid);
    }

    return result;
  }
}

class Document {
  Document(String path) {
    ref = _store.doc(path);
  }

  Document.withRef(this.ref);

  String path() {
    return ref.path;
  }

  final FirebaseFirestore _store = AuthService().store;
  late DocumentReference<Map<String, dynamic>> ref;

  String get documentId => ref.id;

  Future<T?> getData<T>() {
    return ref.get().then(
          (v) => FirestoreRefs.convert(
            T,
            v.data(),
            documentId,
            Document.withRef(v.reference),
          ) as T?,
        );
  }

  Stream<T> streamData<T>() {
    // remove the null values
    final filter = ref.snapshots().where((v) => v.data() != null);

    return filter.map(
      (v) => FirestoreRefs.convert(
        T,
        v.data(),
        documentId,
        Document.withRef(v.reference),
      ) as T,
    );
  }

  Future<void> upsert(Map<String, dynamic> data) {
    return ref.set(data, SetOptions(merge: true));
  }

  Future<void> delete() {
    return ref.delete();
  }

  Collection collection(String path) {
    return Collection.withRef(ref.collection(path));
  }
}

class Collection {
  Collection(String path) {
    ref = _store.collection(path);
  }

  Collection.withRef(this.ref);

  final FirebaseFirestore _store = AuthService().store;
  late CollectionReference<Map<String, dynamic>> ref;

  String path() {
    return ref.path;
  }

  Document document(String path) {
    return Document.withRef(ref.doc(path));
  }

  Future<List<T>> getData<T>() async {
    final snapshots = await ref.get();
    return snapshots.docs
        .map(
          (doc) => FirestoreRefs.convert(
            T,
            doc.data(),
            doc.id,
            Document.withRef(doc.reference),
          ) as T,
        )
        .toList();
  }

  Stream<List<T>> streamData<T>() {
    return ref.snapshots().map(
          (v) => v.docs
              .map(
                (doc) => FirestoreRefs.convert(
                  T,
                  doc.data(),
                  doc.id,
                  Document.withRef(doc.reference),
                ) as T,
              )
              .toList(),
        );
  }

  // must use add to add the timestamp automatically
  Stream<List<T>> orderedStreamData<T>({List<WhereQuery>? where}) {
    final Query<Map<String, dynamic>> query = ref.orderBy('timestamp');

    if (Utils.isNotEmpty(where)) {
      final List<Stream<List<T>>> streams = [];

      for (final w in where!) {
        final Query<Map<String, dynamic>> tmpQuery =
            w.where(query) as Query<Map<String, dynamic>>;

        streams.add(
          tmpQuery.snapshots().map(
                (v) => v.docs.map((doc) {
                  return FirestoreRefs.convert(
                    T,
                    doc.data(),
                    doc.id,
                    Document.withRef(doc.reference),
                  ) as T;
                }).toList(),
              ),
        );
      }

      Stream<List<T>> stream = streams.first;

      if (streams.length > 1) {
        stream = stream.combineLatest<List<T>, List<T>>(streams[1],
            (List<T> a, List<T> b) {
          final List<T> result = [];
          result.addAll(a);
          result.addAll(b);

          return result;
        });
      }

      return stream.asBroadcastStream();
    } else {
      return query.snapshots().map(
            (v) => v.docs
                .map(
                  (doc) => FirestoreRefs.convert(
                    T,
                    doc.data(),
                    doc.id,
                    Document.withRef(doc.reference),
                  ) as T,
                )
                .toList(),
          );
    }
  }

  // use orderedStreamData above to sort by timestamp
  Future<DocumentReference> addOrdered(Map<String, dynamic> data) {
    data['timestamp'] = FieldValue.serverTimestamp();

    return ref.add(Map<String, dynamic>.from(data));
  }

  Future<bool> delete() async {
    final QuerySnapshot snap = await ref.get();

    try {
      final List<DocumentSnapshot> docs = snap.docs;

      // can't use forEach with await
      await Future.forEach(docs, (DocumentSnapshot d) {
        return d.reference.delete();
      });

      return true;
    } catch (error) {
      print(error);

      return false;
    }
  }
}

class UserData {
  UserData({this.collection});

  final String? collection;
  final AuthService authService = AuthService();

  Stream<T> documentStream<T>() {
    return authService.userStream.switchMap((user) {
      if (user != null) {
        final Document doc = Document('$collection/${user.uid}');
        return doc.streamData<T>();
      } else {
        return Stream<T>.empty();
      }
    });
  }

  Future<T?> getDocument<T>() async {
    final auth.User? user = authService.currentUser;

    if (Utils.isNotEmpty(user?.uid)) {
      final Document doc = Document('$collection/${user!.uid}');
      return doc.getData<T>();
    } else {
      return Future.value();
    }
  }

  Future<void> upsert(Map<String, dynamic> data) async {
    final auth.User? user = authService.currentUser;

    if (user != null && user.uid.isNotEmpty) {
      final Document ref = Document('$collection/${user.uid}');
      return ref.upsert(data);
    }
  }
}
