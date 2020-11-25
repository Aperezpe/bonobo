import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:flutter/foundation.dart';

import 'interest.dart';

class SetInterestsPageModel extends ChangeNotifier {
  SetInterestsPageModel({
    @required this.database,
    this.isLoading = false,
    this.friend,
  });
  final FirestoreDatabase database;
  Friend friend;
  bool isLoading;

  final int interestsAllowed = 5;
  List<String> _selectedInterests = [];

  void selectedInterests(List<String> interests) {
    _selectedInterests = interests;
    notifyListeners();
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
}