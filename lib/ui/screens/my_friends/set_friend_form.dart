import 'package:bonobo/services/auth.dart';
import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/bottom_button.dart';
import 'package:bonobo/ui/common_widgets/custom_text_field.dart';
import 'package:bonobo/ui/common_widgets/platform_dropdown/platform_dropdown.dart';
import 'package:bonobo/ui/common_widgets/platform_exception_alert_dialog.dart';
import 'package:bonobo/ui/models/gender.dart';
import 'package:bonobo/ui/screens/my_friends/models/set_friend_model.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:bonobo/ui/screens/my_friends/widgets/profile_image_builder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/loading_screen.dart';

import 'models/friend.dart';

class SetFriendForm extends StatefulWidget {
  SetFriendForm({@required this.model});
  final SetFriendModel model;

  static Future<void> show(
    BuildContext context, {
    Friend friend,
    List<SpecialEvent> friendSpecialEvents,
  }) async {
    final database = Provider.of<Database>(context);
    final auth = Provider.of<AuthBase>(context);
    final user = await auth.currentUser();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => StreamBuilder<List<Gender>>(
            stream: database.genderStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ChangeNotifierProvider<SetFriendModel>(
                  create: (context) => SetFriendModel(
                    uid: user.uid,
                    database: database,
                    friend: friend,
                    friendSpecialEvents: friendSpecialEvents,
                    genders: snapshot.data,
                  ),
                  child: Consumer<SetFriendModel>(
                    builder: (context, model, __) => SetFriendForm(
                      model: model,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("An error has ocurred"));
              }
              return LoadingScreen();
            }),
      ),
    );
  }

  @override
  _SetFriendFormState createState() => _SetFriendFormState();
}

class _SetFriendFormState extends State<SetFriendForm> {
  GlobalKey<FormState> _formKey;

  FocusNode _nameFocusNode;
  FocusNode _ageFocusNode;

  SetFriendModel get _model => widget.model;
  Friend get _friend => _model.friend;
  bool get _isNewFriend => _model.isNewFriend;

  String _name = "";
  int _age;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameFocusNode = FocusNode();
    _ageFocusNode = FocusNode();
    _name = _friend?.name;
    _age = _friend?.age;
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _onSetEvent() {
    if (_validateAndSaveForm()) {
      _model.goToSpecialEvents(context);
    }
  }

  void _onSave() async {
    if (_validateAndSaveForm()) {
      try {
        await _model.onSave();
        Navigator.pop(context);
      } on PlatformException catch (e) {
        PlatformExceptionAlertDialog(
          title: 'Operation failed',
          exception: e,
        ).show(context);
      }
    }
  }

  void _nameEditingComplete() {
    final newFocus = _name.isNotEmpty ? _ageFocusNode : _nameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }

  void closeDropdown() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 2.0,
        title: Text(_isNewFriend ? "New Friend" : 'Edit Friend'),
        actions: _isNewFriend
            ? []
            : [
                FlatButton(
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: _onSave,
                ),
              ],
      ),
      body: _buildContent(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BottomButton(
        onPressed:
            _model.firebaseStorage?.uploadTask != null ? null : _onSetEvent,
        color: Colors.blue,
        text: _isNewFriend
            ? "Add Events 👉"
            : 'Edit ${_friend.name}\'s Events 👉',
        textColor: Colors.white,
      ),
    );
  }

  Widget _buildContent() {
    // Display a loading screen if image is uploading
    if (_model.firebaseStorage?.uploadTask != null) {
      return StreamBuilder<TaskSnapshot>(
        stream: _model.firebaseStorage.uploadTask.snapshotEvents,
        builder: (context, snapshot) => LoadingScreen(),
      );
    } else {
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ProfileImageBuilder(
                      futureImage: _model.getImageOrURL(),
                      onPressed: () => _model.pickImage(context),
                      selectedImage: _model.selectedImage,
                    ),
                    SizedBox(height: 25),
                    ..._buildFormFields(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  List<Widget> _buildFormFields() {
    return [
      CustomTextField(
        focusNode: _nameFocusNode,
        textInputAction: TextInputAction.next,
        initialValue: _name,
        labelText: "Name",
        validator: (value) => value.isNotEmpty ? null : "Name can't be empty",
        onSaved: (value) => _model.updateName(value),
        onChanged: (value) => _model.updateName(value),
        onEditingComplete: _nameEditingComplete,
      ),
      SizedBox(height: 15),
      CustomTextField(
        focusNode: _ageFocusNode,
        initialValue: _age?.toString(),
        textInputAction: TextInputAction.done,
        labelText: "Age",
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        validator: (value) => value.isNotEmpty ? null : "Age can't be empty",
        onSaved: (value) => _model.updateAge(int.tryParse(value) ?? 0),
        onChanged: (value) => _model.updateAge(int.tryParse(value) ?? 0),
      ),
      SizedBox(height: 15.0),
      PlatformDropdown(
        initialValue: _model.genderTypes[_model.initialGenderValue],
        values: _model.genderTypes,
        onChanged: _model.onGenderDropdownChange,
        title: "Choose Gender",
      ),
    ];
  }
}
