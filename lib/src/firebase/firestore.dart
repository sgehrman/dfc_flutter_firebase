import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore_converter.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:stream_transform/stream_transform.dart';

class Document {
  Document(String path) {
    if (_store != null) {
      ref = _store.doc(path);
    }
  }

  Document.withRef(this.ref);

  String path() {
    return ref.path;
  }

  final FirebaseFirestore? _store = AuthService().store;
  late DocumentReference<Map<String, dynamic>> ref;

  String get documentId => ref.id;

  Future<T?> getData<T>() async {
    final v = await ref.get();

    return FirestoreConverter.convert(
      T,
      v.data(),
      documentId,
      Document.withRef(v.reference),
    ) as T?;
  }

  Stream<T> streamData<T>() {
    // remove the null values
    final filter = ref.snapshots().where((v) => v.data() != null);

    return filter.map(
      (v) => FirestoreConverter.convert(
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
    if (_store != null) {
      ref = _store.collection(path);
    }
  }

  Collection.withRef(this.ref);

  final FirebaseFirestore? _store = AuthService().store;
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
          (doc) => FirestoreConverter.convert(
            T,
            doc.data(),
            doc.id,
            Document.withRef(doc.reference),
          ) as T,
        )
        .toList();
  }

  Future<List<T>> getPagedData<T>({
    required int limit,
    String? startAfterDocId,
  }) async {
    var query = ref.limit(limit);

    if (Utils.isNotEmpty(startAfterDocId)) {
      final startAfterDoc = await ref.doc(startAfterDocId).get();

      query = query.startAfterDocument(startAfterDoc);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) => FirestoreConverter.convert(
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
                (doc) => FirestoreConverter.convert(
                  T,
                  doc.data(),
                  doc.id,
                  Document.withRef(doc.reference),
                ) as T,
              )
              .toList(),
        );
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

  Future<T?> getDocument<T>() {
    final auth.User? user = authService.currentUser;

    if (Utils.isNotEmpty(user?.uid)) {
      final Document doc = Document('$collection/${user!.uid}');

      return doc.getData<T>();
    } else {
      return Future.value();
    }
  }

  Future<void> upsert(Map<String, dynamic> data) {
    final auth.User? user = authService.currentUser;

    if (user != null && user.uid.isNotEmpty) {
      final Document ref = Document('$collection/${user.uid}');

      return ref.upsert(data);
    }

    return Future.value();
  }
}
