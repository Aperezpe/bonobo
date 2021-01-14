import 'package:flutter/foundation.dart';

class Interest {
  Interest({
    @required this.id,
    @required this.name,
    @required this.ageRange,
    @required this.gender,
    @required this.imageUrl,
  });

  String id;
  String name;
  List<dynamic> ageRange;
  String gender;
  String imageUrl;

  factory Interest.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    final String name = data['name'];
    final List<dynamic> ageRange = data['age_range'];
    final String gender = data['gender'];
    final String imageUrl = data['image_url'] == ""
        ? 'https://wallpaperaccess.com/full/1137905.jpg'
        : data['image_url'];

    return Interest(
      id: documentId,
      name: name,
      ageRange: ageRange,
      gender: gender,
      imageUrl: imageUrl,
    );
  }
}
