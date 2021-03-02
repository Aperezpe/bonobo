import 'package:bonobo/ui/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoMainScaffold extends StatelessWidget {
  const CupertinoMainScaffold({
    Key key,
    @required this.currentTab,
    @required this.onSelectedTab,
    @required this.widgetBuilder,
  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;
  final Map<TabItem, WidgetBuilder> widgetBuilder;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor:
            CupertinoTheme.of(context).barBackgroundColor.withOpacity(1.0),
        border: Border(top: BorderSide(width: 1.5, color: Colors.grey[200])),
        items: [
          _buildItem(TabItem.home),
          _buildItem(TabItem.myFriends),
          _buildItem(TabItem.calendar),
          _buildItem(TabItem.favorites),
        ],
        onTap: (index) => onSelectedTab(TabItem.values[index]),
      ),
      tabBuilder: (context, index) {
        final item = TabItem.values[index];
        return CupertinoTabView(
          builder: (context) => widgetBuilder[item](context),
        );
      },
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    final itemData = TabItemData.allTabs[tabItem];
    return BottomNavigationBarItem(
      icon: Icon(
        itemData.icon,
      ),
      activeIcon: Icon(
        itemData.activeIcon,
      ),
    );
  }
}
