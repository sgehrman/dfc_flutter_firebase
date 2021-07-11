abstract class Serializable {
  Map<String, dynamic> toMap({bool types = false});
}

abstract class Editable extends Serializable {
  String get identifier;
  String get displayName;
}
