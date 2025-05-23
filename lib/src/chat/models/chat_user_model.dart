import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_user_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class ChatUserModel extends ModelToMap {
  ChatUserModel({
    this.id = '',
    this.userId = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.avatar = '',
  }) {
    if (id.isEmpty) {
      id = Utils.uniqueFirestoreId();
    }
  }

  factory ChatUserModel.fromJson(Map<String, dynamic> json) =>
      _$ChatUserModelFromJson(json);

  @JsonKey(includeFromJson: false, includeToJson: false)
  Document? document;

  String id;
  String userId;
  String name;
  String email;
  String phone;
  String avatar;

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  String getId() {
    return id;
  }

  @override
  Map<String, dynamic> toJson() => _$ChatUserModelToJson(this);

  String get initials {
    var result = '?';

    if (name.isNotEmpty) {
      result = name[0];

      final names = name.split(' ');
      if (names.length > 1) {
        final lastName = names.last;

        if (lastName.isNotEmpty) {
          result += lastName[0];
        }
      }
    } else if (email.isNotEmpty) {
      result = email[0];

      if (email.length > 1) {
        result += email[1];
      }
    }

    return result.toUpperCase();
  }
}
