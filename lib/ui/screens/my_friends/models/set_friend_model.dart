import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/platform_alert_dialog.dart';
import 'package:bonobo/ui/models/gender.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:bonobo/ui/screens/my_friends/set_special_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../services/storage.dart';

import 'friend.dart';

class SetFriendModel extends ChangeNotifier {
  final String uid;
  final FirestoreDatabase database;
  final List<SpecialEvent> friendSpecialEvents;
  final Friend friend;
  final List<Gender> genders;

  String name = "";
  int age = 0;
  bool isNewFriend;
  int genderDropdownValue = 0;
  List<int> ageRange;
  File selectedImage;
  FirebaseStorageService firebaseStorage;
  String profileImageUrl;

  SetFriendModel({
    @required this.uid,
    @required this.database,
    @required this.friendSpecialEvents,
    @required this.genders,
    this.friend,
  }) {
    isNewFriend = friend == null ? true : false;
    firebaseStorage = FirebaseStorageService(uid: uid, friend: friend);
    initializeGenderDropdownValue();
    initializeAgeRange();
  }

  Future<dynamic> getImageOrURL() async {
    if (selectedImage != null) return selectedImage;
    if (isNewFriend) return await firebaseStorage.getDefaultProfileUrl();
    return friend.imageUrl;
  }

  Future pickImage(BuildContext context) async {
    try {
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: 'Crop It',
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          ),
        );

        selectedImage = cropped ?? selectedImage;

        notifyListeners();
      }
    } catch (e) {
      PlatformAlertDialog(
        content: e.toString(),
        title: "Hello",
        defaultAtionText: "Ok",
      ).show(context);
      // print(e.toString());
    }
  }

  Future<void> _uploadProfileImage() async {
    firebaseStorage.putFriendProfileImage(image: selectedImage);
    notifyListeners();
    await firebaseStorage.uploadTask.onComplete;
  }

  /// [Adding new friend]: Returns a friend instance with the data gathered
  /// from from form + initial valules
  ///
  /// [Editing friend]: Returns friend instance with data gathered from form +
  /// previous values on friend instance
  ///
  /// Used in submit() and setInterestPage.

  Future<void> onSave() async {
    try {
      if (ageRangeChanged() || genderChanged())
        throw PlatformException(
          code: "01",
          message: "User has to re-select interests",
        );

      if (selectedImage != null) {
        await _uploadProfileImage();
        friend.imageUrl = await firebaseStorage.getFriendProfileImageURL();
      }

      final newFriend = _setFriend();
      await database.setFriend(newFriend);
    } catch (e) {
      rethrow;
    }
  }

  void initializeGenderDropdownValue() {
    if (isNewFriend) return;
    final genderTypes = genders.map((gender) => gender.type).toList();
    genderDropdownValue = genderTypes.indexOf(friend.gender);
  }

  void initializeAgeRange() {
    if (isNewFriend) return;
    if (friend.age >= 0 && friend.age <= 2) {
      ageRange = [0, 2];
    } else if (friend.age >= 3 && friend.age <= 11) {
      ageRange = [3, 11];
    } else {
      ageRange = [12, 100];
    }
  }

  bool genderChanged() {
    if (isNewFriend) return false;
    if (genders[genderDropdownValue].type != friend.gender) {
      return true;
    }
    return false;
  }

  bool ageRangeChanged() {
    if (isNewFriend) return false;
    if (friend.age != age) {
      if (age >= ageRange[0] && age <= ageRange[1]) return false;
      return true;
    }
    return false;
  }

  void updateBorderColor() {
    notifyListeners();
  }

  void onGenderDropdownChange(int value) {
    genderDropdownValue = value;
    updateBorderColor();
  }

  void updateName(String name) => updateWith(name: name);
  void updateAge(int age) => updateWith(age: age);

  void updateWith({
    String name,
    int age,
  }) {
    this.name = name ?? this.name;
    this.age = age ?? this.age;
  }

  void goToSpecialEvents(BuildContext context) async {
    final newFriend = _setFriend();
    SetSpecialEvent.show(
      context,
      database: database,
      friend: newFriend,
      friendSpecialEvents: friendSpecialEvents,
      isNewFriend: isNewFriend,
      selectedImage: selectedImage,
    );
  }

  Friend _setFriend() {
    return Friend(
      id: isNewFriend ? documentIdFromCurrentDate() : friend.id,
      uid: uid,
      name: name,
      age: age,
      imageUrl: friend?.imageUrl,
      gender: genders[genderDropdownValue].type,
      interests: (isNewFriend || ageRangeChanged() || genderChanged())
          ? []
          : friend.interests,
    );
  }
}
