import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_url_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
)
class ImageUrlModel extends ModelToMap {
  ImageUrlModel({
    this.id = '',
    this.name = '',
    this.url = '',
  }) {
    if (id.isEmpty) {
      id = Utils.uniqueFirestoreId();
    }
  }

  @JsonKey(ignore: true)
  dynamic document;

  String id;
  String name;
  String url;

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  String getId() {
    return id;
  }

  factory ImageUrlModel.fromJson(Map<String, dynamic> json) =>
      _$ImageUrlModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageUrlModelToJson(this);
}
