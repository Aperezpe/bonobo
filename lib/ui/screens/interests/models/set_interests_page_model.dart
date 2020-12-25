import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:flutter/foundation.dart';

import '../../../models/interest.dart';

class SetInterestsPageModel extends ChangeNotifier {
  SetInterestsPageModel({
    @required this.database,
    @required this.friend,
    @required this.friendSpecialEvents,
    @required this.isNewFriend,
    @required this.onDeleteSpecialEvents,
  }) : assert(friend != null) {
    _initializeInterests();
  }

  final FirestoreDatabase database;
  Friend friend;
  List<SpecialEvent> friendSpecialEvents;
  final bool isNewFriend;
  List<SpecialEvent> onDeleteSpecialEvents;

  final int interestsAllowed = 5;
  List<String> _selectedInterests = [];

  void _initializeInterests() {
    _selectedInterests =
        friend.interests.map((interest) => interest.toString()).toList();
  }

  Stream<List<Interest>> get interestStream => database.interestStream();

  bool get isReadyToSubmit =>
      _selectedInterests.length == interestsAllowed ? true : false;

  String get submitButtonText {
    int remaining = interestsAllowed - _selectedInterests.length;
    if (remaining == 1) {
      return "Add 1 more interest";
    } else if (remaining > 1) {
      return "Add $remaining more interests";
    } else {
      return "Submit";
    }
  }

  Future<void> submit() async {
    friend.interests = _selectedInterests;
    await database.setFriend(friend);
    for (SpecialEvent event in friendSpecialEvents) {
      await database.setSpecialEvent(event, friend);
    }
    for (SpecialEvent event in onDeleteSpecialEvents) {
      await database.deleteSpecialEvent(event);
    }
  }

  bool isSelected(String interestName) =>
      _selectedInterests.contains(interestName);

  void tapInterest(String interestName) {
    if (isSelected(interestName)) {
      _selectedInterests.remove(interestName);
    } else if (_selectedInterests.length < interestsAllowed) {
      _selectedInterests.add(interestName);
    }
    notifyListeners();
  }

  List<dynamic> filterInterests(List<dynamic> interests) {
    List<dynamic> filteredInterests = [];

    for (var interest in interests) {
      int fromAge = interest.ageRange[0];
      int toAge = interest.ageRange[1];
      bool isBetweenRange = fromAge <= friend.age && toAge >= friend.age;
      bool isRightGender =
          interest.gender == "any" || interest.gender == friend.gender;

      if (isBetweenRange && isRightGender) {
        filteredInterests.add(interest);
      }
    }

    return filteredInterests;
  }
}
