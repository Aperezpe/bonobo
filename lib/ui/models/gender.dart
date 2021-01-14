import 'package:flutter/foundation.dart';

class Gender {
  Gender({@required this.type});
  String type;

  factory Gender.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    return Gender(
      type: documentId,
    );
  }
}
