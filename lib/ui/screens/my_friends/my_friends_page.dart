import 'package:bonobo/services/auth.dart';
import 'package:bonobo/services/database.dart';
import 'package:bonobo/services/storage.dart';
import 'package:bonobo/services/storage_path.dart';
import 'package:bonobo/ui/common_widgets/list_item_builder.dart';
import 'package:bonobo/ui/common_widgets/platform_alert_dialog.dart';
import 'package:bonobo/ui/common_widgets/platform_exception_alert_dialog.dart';
import 'package:bonobo/ui/models/gender.dart';
import 'package:bonobo/ui/screens/friend/friend_page.dart';
import 'package:bonobo/ui/screens/my_friends/friend_list_tile.dart';
import 'package:bonobo/ui/screens/my_friends/set_friend_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'models/friend.dart';
import 'models/special_event.dart';

class MyFriendsPage extends StatelessWidget {
  MyFriendsPage({
    @required this.database,
    @required this.allSpecialEvents,
    @required this.auth,
  });
  final Auth auth;
  final FirestoreDatabase database;
  final List<SpecialEvent> allSpecialEvents;

  void _deleteFriend(BuildContext context, Friend friend) async {
    final res = await PlatformAlertDialog(
      title: "Delete?",
      content: "Are you sure want to delete ${friend.name}?",
      defaultAtionText: "Yes",
      cancelActionText: "Cancel",
    ).show(context);

    try {
      if (res) {
        final storageService =
            FirebaseStorageService(uid: database.uid, friend: friend);

        await storageService.deleteFriendProfileImage();
        database.deleteFriend(friend);
        for (SpecialEvent event in allSpecialEvents) {
          if (event.friendId == friend.id) {
            database.deleteSpecialEvent(event);
          }
        }
      }
    } catch (e) {
      await PlatformAlertDialog(
        title: "Error",
        content: "Something went wrong",
        defaultAtionText: "Ok",
      ).show(context);
    }
  }

  List<SpecialEvent> getFriendSpecialEvents(Friend friend) {
    List<SpecialEvent> friendSpecialEvents = allSpecialEvents
        .where((event) => event.friendId == friend?.id)
        .toList();
    if (friendSpecialEvents.isEmpty) return [];
    return friendSpecialEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Friends"),
        actions: [
          FlatButton(
            onPressed: auth.signOut,
            child: Text(
              "Sign Out",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SetFriendForm.show(context),
        child: Icon(Icons.add),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return StreamBuilder<List<Friend>>(
      stream: database.friendsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListItemsBuilder<Friend>(
            snapshot: snapshot,
            itemBuilder: (context, friend) => _buildFriendCard(context, friend),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("An error occurred"));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFriendCard(BuildContext context, Friend friend) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.18,
      child: Container(
        child: FriendListTile(
          backgroundImage: NetworkImage(friend.imageUrl),
          friend: friend,
          onTap: () => {
            FriendPage.show(
              context,
              database: database,
              friend: friend,
              friendSpecialEvents: getFriendSpecialEvents(friend),
            ),
          },
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Edit',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () => SetFriendForm.show(
            context,
            friend: friend,
            friendSpecialEvents: getFriendSpecialEvents(friend),
          ),
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _deleteFriend(context, friend),
        ),
      ],
    );
  }
}
