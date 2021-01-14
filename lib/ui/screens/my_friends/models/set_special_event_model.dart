import 'dart:io';

import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/screens/interests/set_interests_page.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/storage.dart';

import 'friend.dart';

class SetSpecialEventModel extends ChangeNotifier {
  SetSpecialEventModel({
    @required this.friend,
    @required this.database,
    @required this.friendSpecialEvents,
    @required this.isNewFriend,
    this.selectedImage,
  }) {
    if (friendSpecialEvents == null) friendSpecialEvents = [];
    onDeleteSpecialEvents = [];
    firebaseStorageService =
        FirebaseStorageService(uid: database.uid, friend: friend);
  }

  final Friend friend;
  final FirestoreDatabase database;
  final bool isNewFriend;
  final File selectedImage;
  List<SpecialEvent> friendSpecialEvents;
  List<SpecialEvent> onDeleteSpecialEvents;
  FirebaseStorageService firebaseStorageService;

  bool get isEmpty => friendSpecialEvents.isEmpty;

  void addSpecialEvent(List<String> events) {
    friendSpecialEvents.add(SpecialEvent(
      id: documentUUID(),
      name: events[0],
      date: DateTime.now(),
      friendId: friend.id,
    ));
    notifyListeners();
  }

  void updateSpecialEvent(
    int index, {
    String name,
    DateTime date,
    bool isConcurrent,
  }) {
    friendSpecialEvents[index] = SpecialEvent(
        id: friendSpecialEvents[index].id,
        name: name ?? friendSpecialEvents[index].name,
        date: date ?? friendSpecialEvents[index].date,
        isConcurrent: isConcurrent ?? friendSpecialEvents[index].isConcurrent);

    notifyListeners();
  }

  void deleteSpecialEvent(int index, SpecialEvent specialEvent) {
    friendSpecialEvents.removeAt(index);
    onDeleteSpecialEvents.add(specialEvent);

    notifyListeners();
  }

  Future<void> onSave() async {
    try {
      if (friend.interests.isEmpty)
        throw PlatformException(
          code: "01",
          message: "User has to re-select interest",
        );

      if (selectedImage != null) {
        firebaseStorageService.putFriendProfileImage(image: selectedImage);
        notifyListeners();
        await firebaseStorageService.uploadTask.onComplete;
        friend.imageUrl =
            await firebaseStorageService.getFriendProfileImageURL();
      } else {
        friend.imageUrl = friend.imageUrl ??
            await firebaseStorageService.getDefaultProfileUrl();
      }

      await database.setFriend(friend);
      for (SpecialEvent event in friendSpecialEvents) {
        await database.setSpecialEvent(event, friend);
      }
      for (SpecialEvent event in onDeleteSpecialEvents) {
        await database.deleteSpecialEvent(event);
      }
    } catch (e) {
      rethrow;
    }
  }

  void goToInterestsPage(BuildContext context) {
    SetInterestsPage.show(
      context,
      database: database,
      friend: friend,
      friendSpecialEvents: friendSpecialEvents,
      isNewFriend: isNewFriend,
      onDeleteSpecialEvents: onDeleteSpecialEvents,
      selectedImage: selectedImage,
    );
  }
}
