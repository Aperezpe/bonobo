import 'package:bonobo/services/auth.dart';
import 'package:flutter/material.dart';
import '../../../resize/size_config.dart';

class HomePage extends StatefulWidget {
  HomePage({@required this.auth});
  final AuthBase auth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName;

  Future<void> getUserName() async {
    String un = await widget.auth.getUserName();
    setState(() {
      userName = un;
    });
  }

  @override
  void initState() {
    userName = "";
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          FlatButton(
            child: Text("Sign Out"),
            onPressed: widget.auth.signOut,
          ),
        ],
      ),
      body: Center(
        child: Container(
          height: SizeConfig.blockSizeVertical * 20,
          width: SizeConfig.blockSizeHorizontal * 50,
          child: Text(
            "Welcome! $userName",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
