import 'package:bonobo/ui/screens/friend/models/friend_page_model.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../extensions/string_capitalize.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  Future<void> setData({String path, Map<String, dynamic> data}) async {
    final reference = Firestore.instance.document(path);
    await reference.setData(data);
  }

  Future<void> deleteData({String path}) async {
    final reference = Firestore.instance.document(path);
    await reference.delete();
  }

  Stream<List<T>> queryInterestsStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentId),
    @required Friend friend,
  }) {
    CollectionReference ref = Firestore.instance.collection(path);
    Query query;

    // Query interests by friend age
    if (friend.age < 3) {
      query = ref.where('age_range', arrayContains: 0);
    } else if (friend.age >= 3 && friend.age < 12) {
      query = ref.where('age_range', arrayContains: 3);
    } else {
      query = ref.where('age_range', arrayContains: 12);
    }

    //TODO: Make sure that friend.gender is NEVER null
    query = query.where('gender', whereIn: [
      "",
      friend.gender.capitalize(),
      friend.gender.unCapitalize()
    ]);

    final snapshots = query.snapshots();
    return snapshots.map((snapshots) => snapshots.documents
        .map((snapshot) => builder(snapshot.data, snapshot.documentID))
        .toList());
  }

  // Query product stream by event OR categories
  Stream<List<T>> queryProductsStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentId),
    @required Friend friend,
    @required int startPrice,
    @required int endPrice,
    EventType eventType,
  }) {
    CollectionReference ref = Firestore.instance.collection(path);
    Query query;

    switch (eventType) {
      // TODO: possibly create a girl baby shower and boy baby shower
      // because this will show both since friend.gender is not relevant
      case EventType.babyShower:
        query = ref.where('event', isEqualTo: "Babyshower");
        break;
      case EventType.anniversary:
        query = ref
            .where('event', isEqualTo: "Anniversary")
            .where('gender', whereIn: [friend.gender, ""]);
        break;
      default:
        query = ref.where('categories', arrayContainsAny: friend.interests);
        break;
    }
    final snapshots = query.snapshots();
    return snapshots.map((snapshots) => snapshots.documents
        .map((snapshot) => builder(snapshot.data, snapshot.documentID))
        .toList());
  }

  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentId),
  }) {
    final reference = Firestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshots) => snapshots.documents
        .map((snapshot) => builder(snapshot.data, snapshot.documentID))
        .toList());
  }
}
