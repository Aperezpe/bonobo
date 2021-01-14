import 'dart:io';

import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/bottom_button.dart';
import 'package:bonobo/ui/common_widgets/loading_screen.dart';
import 'package:bonobo/ui/common_widgets/platform_exception_alert_dialog.dart';
import 'package:bonobo/ui/screens/interests/models/set_interests_page_model.dart';
import 'package:bonobo/ui/screens/interests/widgets/clickable_box.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/interest.dart';

class SetInterestsPage extends StatelessWidget {
  SetInterestsPage({
    @required this.model,
  });
  final SetInterestsPageModel model;

  bool get isReadyToSubmit => model.isReadyToSubmit;
  Friend get friend => model.friend;

  static Future<void> show(
    BuildContext context, {
    @required Friend friend,
    @required FirestoreDatabase database,
    @required List<SpecialEvent> friendSpecialEvents,
    @required bool isNewFriend,
    @required List<SpecialEvent> onDeleteSpecialEvents,
    File selectedImage,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<SetInterestsPageModel>(
          create: (context) => SetInterestsPageModel(
            database: database,
            friend: friend,
            isNewFriend: isNewFriend,
            friendSpecialEvents: friendSpecialEvents,
            onDeleteSpecialEvents: onDeleteSpecialEvents,
            selectedImage: selectedImage,
          ),
          child: Consumer<SetInterestsPageModel>(
            builder: (context, model, __) => SetInterestsPage(
              model: model,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    try {
      await model.submit();
      Navigator.popUntil(context, (route) => route.isFirst);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Displays loading screen

    return Scaffold(
      appBar: AppBar(
        title: Text("Interests"),
        actions: model.isNewFriend
            ? []
            : [
                FlatButton(
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  // TODO: Snackbar or something when is not ready to submit
                  onPressed: isReadyToSubmit ? () => _submit(context) : null,
                ),
              ],
      ),
      body: _buildContent(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BottomButton(
        onPressed: isReadyToSubmit ? () => _submit(context) : null,
        color: isReadyToSubmit ? Colors.orange[600] : Colors.grey,
        text: model.submitButtonText,
        textColor: isReadyToSubmit ? Colors.black : Colors.white,
        disableColor: Colors.grey,
      ),
    );
  }

  Widget _buildContent() {
    if (model.firebaseStorage?.uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: model.firebaseStorage.uploadTask.events,
        builder: (context, snapshot) => LoadingScreen(),
      );
    } else {
      return StreamBuilder<List<Interest>>(
        stream: model.queryInterestsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            snapshot.data.sort((a, b) => a.name.compareTo(b.name));
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 80),
              itemCount: snapshot.data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return _buildInterestCard(context, snapshot.data[index]);
              },
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("An error occurred"));
          }
          return Center(child: CircularProgressIndicator());
        },
      );
    }
  }

  _buildInterestCard(BuildContext context, Interest interest) {
    return ClickableInterest(
      interest: interest,
      onTap: () => model.tapInterest(interest),
      color: model.isSelected(interest.name) ? Colors.pink : Colors.white,
      opacity: model.isSelected(interest.name) ? .7 : .2,
    );
  }
}
