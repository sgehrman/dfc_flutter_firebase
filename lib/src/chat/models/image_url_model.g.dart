// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_url_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageUrlModel _$ImageUrlModelFromJson(Map<String, dynamic> json) =>
    ImageUrlModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$ImageUrlModelToJson(ImageUrlModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
    };
