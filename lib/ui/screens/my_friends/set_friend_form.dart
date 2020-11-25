import 'package:bonobo/services/auth.dart';
import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/bottom_clickable.dart';
import 'package:bonobo/ui/common_widgets/platform_exception_alert_dialog.dart';
import 'package:bonobo/ui/screens/interests/set_interests_page.dart';
import 'package:bonobo/ui/screens/my_friends/models/set_friend_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/friend.dart';

class SetFriendForm extends StatefulWidget {
  SetFriendForm({@required this.model});
  final model;

  static Future<void> show(
    BuildContext context, {
    Friend friend,
  }) async {
    final database = Provider.of<Database>(context);
    final auth = Provider.of<AuthBase>(context);
    final user = await auth.currentUser();
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Provider<SetFriendModel>(
          create: (context) => SetFriendModel(
            uid: user.uid,
            database: database,
            friend: friend,
          ),
          child: Consumer<SetFriendModel>(
            builder: (context, model, __) => SetFriendForm(model: model),
          ),
        ),
      ),
    );
  }

  @override
  _SetFriendFormState createState() => _SetFriendFormState();
}

class _SetFriendFormState extends State<SetFriendForm> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();

  SetFriendModel get _model => widget.model;
  Friend get _friend => _model.friend;
  bool get _isNewFriend => _model.isNewFriend;

  String _name = "";
  int _age;

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _onSetInterests() {
    if (_validateAndSaveForm()) {
      SetInterestsPage.show(
        context,
        database: _model.database,
        friend: _model.getFriend(),
      );
    }
  }

  void _onSave() async {
    if (_validateAndSaveForm()) {
      try {
        await _model.submit();
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

  /// Initialize values on form if editing friend
  @override
  void initState() {
    super.initState();
    _name = _friend?.name;
    _age = _friend?.age;
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(_isNewFriend ? "New Friend" : 'Edit Friend'),
        actions: _isNewFriend
            ? null
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
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: BottomClickable(
        text: _isNewFriend
            ? "Add Interests"
            : 'Edit ${_friend.name}\'s Interests',
        onTap: _onSetInterests,
        color: Colors.pink,
        textColor: Colors.white,
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildFormFields(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      TextFormField(
        focusNode: _nameFocusNode,
        textInputAction: TextInputAction.next,
        initialValue: _name,
        decoration: InputDecoration(
          labelText: 'Name',
        ),
        validator: (value) => value.isNotEmpty ? null : "Name can't be empty",
        onSaved: (value) => _model.updateName(value),
        onEditingComplete: _nameEditingComplete,
      ),
      TextFormField(
        focusNode: _ageFocusNode,
        initialValue: _age?.toString(),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: 'Age'),
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        validator: (value) => value.isNotEmpty ? null : "Age can't be empty",
        onSaved: (value) => _model.updateAge(int.tryParse(value) ?? 0),
      ),
    ];
  }
}
