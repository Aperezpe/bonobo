import 'package:bonobo/services/auth.dart';
import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/loading_screen.dart';
import 'package:bonobo/ui/models/product.dart';
import 'package:bonobo/ui/screens/favorites.dart';
import 'package:bonobo/ui/screens/sign_in/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key, @required this.databaseBuilder})
      : super(key: key);

  final Database Function(String) databaseBuilder;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
          if (snapshot.data == null) {
            return SignInPage.create(context);
          } else {
            print("signing in user: ${user.uid}");
            return Provider<Database>(
              create: (_) => databaseBuilder(user.uid),
              child: MainPage(),
            );
          }
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
