import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/chat/models/chat_user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class ChatMessageModel extends ModelToMap {
  ChatMessageModel({
    required this.user,
    this.text = '',
    this.id = '',
    this.image = '',
    this.imageId = '',
    this.timestamp = 0,
  }) {
    if (id.isEmpty) {
      id = Utils.uniqueFirestoreId();
    }

    if (timestamp == 0) {
      timestamp = DateTime.now().millisecondsSinceEpoch;
    }
  }

  @JsonKey(ignore: true)
  dynamic document;

  String text;
  int timestamp;
  ChatUserModel user;
  String image;
  String imageId;
  String id;

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  String getId() {
    return id;
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}
