import 'package:bonobo/services/database.dart';
import 'package:bonobo/services/storage.dart';
import 'package:bonobo/ui/models/interest.dart';
import 'package:bonobo/ui/models/product.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendPageModel extends ChangeNotifier {
  FriendPageModel({
    @required this.database,
    @required this.friend,
    @required this.friendSpecialEvents,
  }) : assert(friend != null, friendSpecialEvents != null) {
    // TODO: toList() is unnecesary since I dont need to return value
    specialEventsNames.add("All");
    friendSpecialEvents.map((e) => specialEventsNames.add(e.name)).toList();
    selectedTab = 0;
  }

  final FirestoreDatabase database;
  final Friend friend;
  final List<SpecialEvent> friendSpecialEvents;
  FirebaseStorageService firebaseStorage;
  EventType eventType = EventType.any;
  RangeValues currentRangeValues = RangeValues(0, 100);
  int get startValue => currentRangeValues.start.round();
  int get endValue => currentRangeValues.end.round();

  List<String> specialEventsNames = [];
  int selectedTab;

  Stream<List<Product>> get queryProductsStream => database.queryProductsStream(
        friend: friend,
        startPrice: startValue,
        endPrice: endValue,
        eventType: eventType,
      );

  bool inAgeRange(Product product) =>
      friend.age >= product.ageRange[0] && friend.age <= product.ageRange[1];
  bool correctGender(Product product) =>
      (product.gender == friend.gender) || (product.gender == "");
  bool inBudget(Product product) {
    if (endValue >= 100) return product.price >= startValue;
    return product.price >= startValue && product.price <= endValue;
  }

  /// Query list of products by ageRange, gender, and budget OR just budget
  List<Product> queryProducts(List<Product> products, String eventName) {
    if (eventType == EventType.any)
      return products
          .where(inAgeRange)
          .where(correctGender)
          .where(inBudget)
          .toList();

    return products.where(inBudget).toList();
  }

  void updateBudget(RangeValues values) {
    currentRangeValues = values;
    print(currentRangeValues);
    notifyListeners();
  }

  void updateSelectedTab(int value) {
    selectedTab = value;

    switch (specialEventsNames[value]) {
      case "Babyshower":
        eventType = EventType.babyShower;
        break;
      case "Anniversary":
        eventType = EventType.anniversary;
        break;
      default:
        eventType = EventType.any;
        break;
    }
    notifyListeners();
  }
}

enum EventType {
  babyShower,
  anniversary,
  any,
}
