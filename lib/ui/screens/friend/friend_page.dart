import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/screens/friend/event_type.dart';
import 'package:bonobo/ui/screens/friend/widgets/products_grid.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:bonobo/ui/style/fontStyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class FriendPage extends StatefulWidget {
  FriendPage({
    Key key,
    @required this.friend,
    @required this.friendSpecialEvents,
    @required this.database,
  }) : super(key: key);

  final Friend friend;
  final List<SpecialEvent> friendSpecialEvents;
  final FirestoreDatabase database;

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage>
    with SingleTickerProviderStateMixin {
  Friend get friend => widget.friend;

  RangeValues onStartValues;
  RangeValues currentValues;
  RangeValues onEndValues;

  ScrollController _scrollController;
  TabController _tabController;
  List<Tab> myTabs = [];

  TextEditingController _minController;
  TextEditingController _maxController;

  double get _min => double.parse(_minController.text);
  double get _max => double.parse(_maxController.text);

  @override
  void initState() {
    super.initState();
    onStartValues = RangeValues(0, 100);
    currentValues = onStartValues;
    onEndValues = currentValues;

    widget.friendSpecialEvents.forEach((event) {
      myTabs.add(Tab(text: event.name));
    });

    _tabController = TabController(vsync: this, length: myTabs.length);
    _scrollController = ScrollController();
    _minController = TextEditingController();
    _maxController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friend.name),
      ),
      body: Container(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, value) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: CircleAvatar(
                            radius: 61,
                            backgroundColor: Colors.grey[300],
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(friend.imageUrl),
                            ),
                          ),
                        ),
                      ),
                      _buildBudgetFilter(),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 35,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    tabs: [
                      for (var event in widget.friendSpecialEvents)
                        Container(width: 100, child: Tab(text: event.name)),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle:
                        TextStyle(fontWeight: FontWeight.normal),
                    indicator: RectangularIndicator(
                      topLeftRadius: 100,
                      topRightRadius: 100,
                      bottomLeftRadius: 100,
                      bottomRightRadius: 100,
                      color: Colors.deepPurpleAccent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (var tab in myTabs)
                  ProductsGridView.create(
                    friend: friend,
                    database: widget.database,
                    onEndValues: currentValues,
                    eventType: getEventType(tab.text),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetFilter() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      height: 61,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextField(
              controller: _minController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Min",
              ),
            ),
          ),
          Container(width: 40, child: Text("To", textAlign: TextAlign.center)),
          Expanded(
            child: TextField(
              controller: _maxController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Max",
              ),
            ),
          ),
          SizedBox(width: 15),
          Container(
            child: RaisedButton(
              onPressed: () =>
                  setState(() => currentValues = RangeValues(_min, _max)),
              child: Text("Apply"),
            ),
          ),
        ],
      ),
    );
  }
}
