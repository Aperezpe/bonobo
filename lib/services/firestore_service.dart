import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  Future<List<DocumentSnapshot>> getDocument({@required String path}) async {
    final QuerySnapshot result =
        await Firestore.instance.collection(path).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents;
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
