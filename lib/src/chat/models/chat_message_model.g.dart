// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      user: ChatUserModel.fromJson(json['user'] as Map<String, dynamic>),
      text: json['text'] as String? ?? '',
      toUid: json['toUid'] as String? ?? '',
      id: json['id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      imageId: json['imageId'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'timestamp': instance.timestamp,
      'user': instance.user.toJson(),
      'toUid': instance.toUid,
      'image': instance.image,
      'imageId': instance.imageId,
      'id': instance.id,
    };
