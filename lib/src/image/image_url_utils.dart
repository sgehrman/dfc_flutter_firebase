import 'dart:typed_data';

import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/image_url_model.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class ImageUrlUtils {
  // folder name constants
  static String get chatImageFolder => 'chat-images';

  static Future<void> uploadImage(ImageUrlModel imageUrl) async {
    final doc = Document('images/${imageUrl.id}');

    try {
      await doc.upsert(imageUrl.toJson());
    } catch (error) {
      print('uploadImage exception: $error');
    }

    return;
  }

  static void addImage(String filename, String url) {
    final link = <String, dynamic>{};

    link['id'] = Utils.uniqueFirestoreId();
    link['name'] = filename;
    link['url'] = url;

    final imageUrl = ImageUrlModel.fromJson(link);

    uploadImage(imageUrl);
  }

  static Future<void> deleteImage(ImageUrlModel imageUrl) async {
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
    final url = await uploadImageDataReturnUrl(
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
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(folder != null ? '$folder/$imageName' : imageName);

    var image = img.decodeImage(imageData)!;

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

    final uploadTask = firebaseStorageRef.putData(Uint8List.fromList(data));

    final taskSnapshot = await uploadTask;

    return taskSnapshot.ref.getDownloadURL();
  }

  static Future<void> deleteImageStorage(
    String? imageId, [
    String? folder,
  ]) {
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(folder != null ? '$folder/$imageId' : imageId!);

    return firebaseStorageRef.delete();
  }
}
