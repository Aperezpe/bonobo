import 'package:bonobo/resize/size_config.dart';
import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/app_bar_button.dart';
import 'package:bonobo/ui/common_widgets/custom_app_bar.dart';
import 'package:bonobo/ui/common_widgets/loading_screen.dart';
import 'package:bonobo/ui/common_widgets/profile_page/profile_page.dart';
import 'package:bonobo/ui/models/friend.dart';
import 'package:bonobo/ui/screens/friend/event_type.dart';
import 'package:bonobo/ui/common_widgets/profile_page/widgets/products_grid.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class FriendPage extends StatefulWidget {
  FriendPage({
    Key key,
    @required this.friend,
    @required this.allSpecialEvents,
  }) : super(key: key);

  final Friend friend;
  final List<SpecialEvent> allSpecialEvents;

  static Widget create(BuildContext context, {@required Friend friend}) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<SpecialEvent>>(
      stream: database.specialEventsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FriendPage(friend: friend, allSpecialEvents: snapshot.data);
        }
        return LoadingScreen();
      },
    );
  }

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage>
    with SingleTickerProviderStateMixin {
  RangeValues sliderValues = RangeValues(0, 100);
  List<Tab> myTabs = [Tab(text: "General")];
  List<SpecialEvent> friendSpecialEvents = [];

  @override
  void initState() {
    super.initState();

    friendSpecialEvents = FriendSpecialEvents.getFriendSpecialEvents(
      widget.friend,
      widget.allSpecialEvents,
    );

    friendSpecialEvents.forEach((event) {
      if (event.name == "Anniversary" || event.name == "Babyshower")
        myTabs.add(Tab(text: event.name));
    });

    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TabController _tabController;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final is700Wide = SizeConfig.screenWidth >= 700;
    final database = Provider.of<Database>(context, listen: false);

    return Scaffold(
      body: ProfilePage(
        dismissableAppBar: CustomAppBar(
          leading: AppBarButton(
            icon: LineIcons.angleLeft,
            onTap: () => Navigator.of(context).pop(),
          ),
          isDismissable: true,
          title: widget.friend.name,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom:
                  Radius.elliptical(MediaQuery.of(context).size.width, 100.0),
            ),
          ),
        ),
        database: database,
        title: widget.friend.name,
        rangeSliderCallBack: (values) => setState(() => sliderValues = values),
        sliverTabs: SliverToBoxAdapter(
          child: Container(
            height: SizeConfig.safeBlockVertical * 5.5,
            margin: EdgeInsets.only(
              left: SizeConfig.safeBlockHorizontal * 2.5,
              right: SizeConfig.safeBlockHorizontal * 2.5,
              bottom: SizeConfig.safeBlockVertical,
            ),
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              tabs: [
                for (var tab in myTabs) Tab(text: tab.text),
              ],
              labelPadding: EdgeInsets.only(
                left: SizeConfig.safeBlockHorizontal * 4,
                right: SizeConfig.safeBlockHorizontal * 4,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito-Sans',
                fontSize: SizeConfig.subtitleSize,
              ),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              indicator: RectangularIndicator(
                topLeftRadius: 100,
                topRightRadius: 100,
                bottomLeftRadius: 100,
                bottomRightRadius: 100,
                color: Colors.deepPurpleAccent,
              ),
            ),
          ),
        ),
        body: Container(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (var tab in myTabs)
                ProductsGridView(
                  sliderValues: sliderValues,
                  productStream: database.queryFriendProductsStream(
                    friend: widget.friend,
                    eventType: getEventType(tab.text),
                  ),
                  gender: widget.friend.gender,
                  database: database,
                  eventType: getEventType(tab.text),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
