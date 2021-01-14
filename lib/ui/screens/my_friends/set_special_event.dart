import 'dart:io';

import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/bottom_button.dart';
import 'package:bonobo/ui/common_widgets/loading_screen.dart';
import 'package:bonobo/ui/common_widgets/platform_exception_alert_dialog.dart';
import 'package:bonobo/ui/models/event.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:bonobo/ui/screens/my_friends/widgets/add_event_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/friend.dart';
import 'models/set_special_event_model.dart';

class SetSpecialEvent extends StatelessWidget {
  SetSpecialEvent({@required this.model});
  final SetSpecialEventModel model;

  static Future<void> show(
    BuildContext context, {
    @required Friend friend,
    @required FirestoreDatabase database,
    @required bool isNewFriend,
    @required List<SpecialEvent> friendSpecialEvents,
    File selectedImage,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<SetSpecialEventModel>(
          create: (context) => SetSpecialEventModel(
            database: database,
            friend: friend,
            friendSpecialEvents: friendSpecialEvents,
            isNewFriend: isNewFriend,
            selectedImage: selectedImage,
          ),
          child: Consumer<SetSpecialEventModel>(
            builder: (context, model, _) => SetSpecialEvent(
              model: model,
            ),
          ),
        ),
      ),
    );
  }

  SetSpecialEventModel get _model => model;
  Friend get _friend => _model.friend;
  bool get _isNewFriend => _model.isNewFriend;

  void _onSave(BuildContext context) async {
    try {
      await _model.onSave();
      Navigator.popUntil(context, (route) => route.isFirst);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  // Return [Add] or [Save, Add] actions if is New Friend or
  // Edit Friend respectively
  List<Widget> _buildActions(List<String> events, BuildContext context) {
    final actions = [
      FlatButton(
        child: Text(
          'Save',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        onPressed: () => _onSave(context),
      ),
      FlatButton(
        child: Text(
          'Add',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        onPressed: () => _model.addSpecialEvent(events),
      ),
    ];

    return _isNewFriend ? [actions[1]] : actions;
  }

  Widget _buildContent(List<String> events) {
    if (_model.firebaseStorageService?.uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _model.firebaseStorageService.uploadTask.events,
        builder: (context, snapshot) => LoadingScreen(),
      );
    } else {
      final specialEvents = _model.friendSpecialEvents;
      return ListView(
        padding: EdgeInsets.only(bottom: 80),
        children: [
          for (var specialEvent in specialEvents)
            AddEventCard(
              key: ValueKey(specialEvent.id),
              index: _model.friendSpecialEvents.indexOf(specialEvent),
              events: events,
              model: _model,
              specialEvent: specialEvent,
            ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: _model.database.eventsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final events = snapshot.data.map((e) => e.name).toList();
          return Scaffold(
            appBar: AppBar(
              elevation: 2.0,
              title: Text(_isNewFriend ? "New Friend" : 'Edit Friend'),
              actions: _buildActions(events, context),
            ),
            body: _buildContent(events),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: BottomButton(
              onPressed: _model.isEmpty ||
                      _model.firebaseStorageService?.uploadTask != null
                  ? null
                  : () => _model.goToInterestsPage(context),
              color: Colors.pink,
              text: _isNewFriend
                  ? "Add Interests 😍"
                  : 'Edit ${_friend.name}\'s Interests 😍',
              textColor: Colors.white,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Something went wrong"));
        }
        return CircularProgressIndicator();
      },
    );
  }
}
