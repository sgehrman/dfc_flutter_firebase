import 'package:json_annotation/json_annotation.dart';

part 'chat_user_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class ChatUserModel {
  ChatUserModel({
    this.id = '',
    this.userId = '',
    this.name = '',
    this.email = '',
    this.avatar = '',
  });

  String id;
  String userId;
  String name;
  String email;
  String avatar;

  @override
  String toString() {
    return toJson().toString();
  }

  factory ChatUserModel.fromJson(Map<String, dynamic> json) =>
      _$ChatUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatUserModelToJson(this);

  String get initials {
    String result = '?';

    if (name.isNotEmpty) {
      result = name[0];

      final List<String> names = name.split(' ');
      if (names.length > 1) {
        final String lastName = names.last;

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
