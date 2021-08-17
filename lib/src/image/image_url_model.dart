import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:dfc_flutter_firebase/src/firebase/serializable.dart';
import 'package:image/image.dart' as img;

class ImageUrl extends Serializable {
  ImageUrl({this.name, this.id, this.url});

  factory ImageUrl.fromMap(Map<String, dynamic> data) {
    return ImageUrl(
      id: data.strVal('id'),
      name: data.strVal('name'),
      url: data.strVal('url'),
    );
  }

  final String? id;
  final String? name;
  final String? url;

  @override
  Map<String, dynamic> toMap({bool types = false}) {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['url'] = url;
    map['name'] = name;

    return map;
  }

  @override
  String toString() {
    return 'id: $id, name: $name url: $url';
  }
}

class ImageUrlUtils {
  // folder name constants
  static String get chatImageFolder => 'chat-images';

  static Future<void> uploadImage(ImageUrl imageUrl) async {
    final doc = Document('images/${imageUrl.id}');

    try {
      await doc.upsert(imageUrl.toMap());
    } catch (error) {
      print('uploadImage exception: $error');
    }

    return;
  }

  static void addImage(String filename, String url) {
    final Map<String, dynamic> link = <String, dynamic>{};

    link['id'] = Utils.uniqueFirestoreId();
    link['name'] = filename;
    link['url'] = url;

    final ImageUrl imageUrl = ImageUrl.fromMap(link);

    uploadImage(imageUrl);
  }

  static Future<void> deleteImage(ImageUrl imageUrl) async {
    final doc = Document('images/${imageUrl.id}');

    try {
      await doc.delete();

      // delete from firebase too
      await deleteImageStorage(imageUrl.name);
    } catch (error) {
      print('deleteImage exception: $error');
    }
  }

  // saves as JPG by default since they are smallest
  // set to false for PNG with transparency
  static Future<String> uploadImageData(
    String imageName,
    Uint8List imageData, {
    bool saveAsJpg = true,
    int maxWidth = 1024,
  }) async {
    final String url = await uploadImageDataReturnUrl(
      imageName,
      imageData,
      saveAsJpg: saveAsJpg,
      maxWidth: maxWidth,
    );

    ImageUrlUtils.addImage(imageName, url);

    return url;
  }

  static Future<String> uploadImageDataReturnUrl(
    String imageName,
    Uint8List imageData, {
    bool saveAsJpg = true,
    int maxWidth = 1024,
    String? folder,
  }) async {
    final Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(folder != null ? '$folder/$imageName' : imageName);

    img.Image image = img.decodeImage(imageData)!;

    // shrink image
    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    List<int> data;
    if (saveAsJpg) {
      data = img.encodeJpg(image, quality: 70);
    } else {
      // png can be large, use jpg unless you need transparency
      data = img.encodePng(image, level: 7);
    }

    final UploadTask uploadTask =
        firebaseStorageRef.putData(Uint8List.fromList(data));

    final taskSnapshot = await uploadTask;
    final String url = await taskSnapshot.ref.getDownloadURL();

    return url;
  }

  static Future<void> deleteImageStorage(
    String? imageId, [
    String? folder,
  ]) async {
    final Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(folder != null ? '$folder/$imageId' : imageId!);

    return firebaseStorageRef.delete();
  }
}
