import 'package:bonobo/ui/screens/friend/models/friend_page_model.dart';
import 'package:bonobo/ui/style/fontStyle.dart';
import 'package:flutter/material.dart';

class Tabs extends StatelessWidget {
  final FriendPageModel model;
  Tabs({@required this.model});

  List<String> get specialEventsNames => model.specialEventsNames;

  bool isTabSelected(int i) => model.selectedTab == i;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < specialEventsNames.length; i++)
              Container(
                padding: EdgeInsets.only(right: 8.0),
                child: FlatButton(
                  onPressed: () => model.updateSelectedTab(i),
                  child: Text(
                    specialEventsNames[i],
                    style: p.apply(
                      color: isTabSelected(i) ? Colors.white : null,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: Colors.grey),
                  ),
                  color: isTabSelected(i) ? Colors.black54 : Colors.grey[300],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
