import 'package:flutter/foundation.dart';

class Product {
  String id;
  String name;
  double price;
  List<dynamic> ageRange;
  String distributor;
  String event;
  String imageUrl;
  List<dynamic> categories;
  String itemUrl;
  String gender;
  String itemId;

  Product({
    @required this.id,
    @required this.name,
    @required this.price,
    @required this.event,
    @required this.ageRange,
    @required this.distributor,
    @required this.imageUrl,
    @required this.itemUrl,
    @required this.categories,
    @required this.gender,
    @required this.itemId,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    String name = data['name'];
    double price = data['price'] + .0;
    List<dynamic> ageRange = data['age_range'];
    String distributor = data['distributor'];
    String event = data['event'];
    List<dynamic> categories = data['categories'];
    String imageUrl = data['image_url'];
    String itemUrl = data['item_url'];
    String gender = data['gender'];
    String itemId = data['item_id'];

    return Product(
      id: documentId,
      name: name,
      price: price,
      event: event,
      imageUrl: imageUrl,
      itemUrl: itemUrl,
      ageRange: ageRange,
      distributor: distributor,
      categories: categories,
      gender: gender,
      itemId: itemId,
    );
  }
}
