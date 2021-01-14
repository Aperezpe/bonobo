import 'package:bonobo/services/api_path.dart';
import 'package:bonobo/services/firestore_service.dart';
import 'package:bonobo/ui/models/event.dart';
import 'package:bonobo/ui/models/gender.dart';
import 'package:bonobo/ui/models/interest.dart';
import 'package:bonobo/ui/models/product.dart';
import 'package:bonobo/ui/screens/friend/models/friend_page_model.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

abstract class Database {
  Future<void> setFriend(Friend friend);
  Future<void> deleteFriend(Friend friend);
  Stream<List<Friend>> friendsStream();
  Stream<List<Interest>> interestStream();
  Stream<List<Product>> productsStream();
  Stream<List<Product>> queryProductsStream({
    @required Friend friend,
    @required int startPrice,
    @required int endPrice,
  });
  Stream<List<Event>> eventsStream();
  Stream<List<Interest>> queryInterestsStream(Friend friend);
  Stream<List<Gender>> genderStream();

  Stream<List<SpecialEvent>> specialEventsStream();
  Future<void> setSpecialEvent(SpecialEvent specialEvent, Friend friend);
  Future<void> deleteSpecialEvent(SpecialEvent specialEvent);
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();
String documentUUID() => Uuid().v1();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;
  final _service = FirestoreService.instance;

  Stream<List<Interest>> interestStream() => _service.collectionStream(
        path: APIPath.interests(),
        builder: (data, documentId) => Interest.fromMap(data, documentId),
      );

  Stream<List<Interest>> queryInterestsStream(Friend friend) =>
      _service.queryInterestsStream(
        path: APIPath.interests(),
        friend: friend,
        builder: (data, documentId) => Interest.fromMap(data, documentId),
      );

  Stream<List<Product>> queryProductsStream({
    @required Friend friend,
    @required int startPrice,
    @required int endPrice,
    EventType eventType,
  }) =>
      _service.queryProductsStream(
        path: APIPath.products(),
        friend: friend,
        startPrice: startPrice,
        endPrice: endPrice,
        eventType: eventType,
        builder: (data, documentId) => Product.fromMap(data, documentId),
      );

  Stream<List<Product>> productsStream() => _service.collectionStream(
        path: APIPath.products(),
        builder: (data, documentId) => Product.fromMap(data, documentId),
      );

  Stream<List<Gender>> genderStream() => _service.collectionStream(
        path: APIPath.genders(),
        builder: (data, documentId) => Gender.fromMap(data, documentId),
      );

  Stream<List<Event>> eventsStream() => _service.collectionStream(
        path: APIPath.events(),
        builder: (data, nameId) => Event.fromMap(data, nameId),
      );

  Future<void> setFriend(Friend friend) async => await _service.setData(
        path: APIPath.friend(uid, friend.id),
        data: friend.toMap(),
      );

  Future<void> deleteFriend(Friend friend) async =>
      await _service.deleteData(path: APIPath.friend(uid, friend.id));

  Stream<List<Friend>> friendsStream() => _service.collectionStream(
        path: APIPath.friends(uid),
        builder: (data, documentId) => Friend.fromMap(data, documentId),
      );

  Stream<List<SpecialEvent>> specialEventsStream() => _service.collectionStream(
        path: APIPath.specialEvents(uid),
        builder: (data, documentId) => SpecialEvent.fromMap(data, documentId),
      );

  Future<void> setSpecialEvent(SpecialEvent specialEvent, Friend friend) async {
    if (friend == null) throw ("Friend can not be null");
    await _service.setData(
      path: APIPath.specialEvent(uid, specialEvent.id),
      data: specialEvent.toMap(friend.id),
    );
  }

  Future<void> deleteSpecialEvent(SpecialEvent specialEvent) async =>
      await _service.deleteData(
          path: APIPath.specialEvent(uid, specialEvent.id));
}
