import 'package:bonobo/services/auth.dart';
import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/loading_screen.dart';
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
            return Provider<Database>(
              create: (_) => databaseBuilder(user.uid),
              child: Consumer<Database>(
                builder: (context, database, _) {
                  print("User: ${user.uid} is signing in...");
                  return MainPage(auth: auth, database: database);
                  // _buildMyFriendsPage(database, auth);
                },
              ),
            );
          }
        } else {
          return LoadingScreen();
        }
      },
    );
  }

  // StreamBuilder<List<SpecialEvent>> _buildMyFriendsPage(
  //     Database database, Auth auth) {
  //   return StreamBuilder<List<SpecialEvent>>(
  //     stream: database.specialEventsStream(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         return MyFriendsPage(
  //           auth: auth,
  //           database: database,
  //           allSpecialEvents: snapshot.data,
  //         );
  //       }
  //       if (snapshot.hasError) {
  //         return Center(
  //           child: Text("Something went wrong!"),
  //         );
  //       }
  //       return LoadingScreen();
  //     },
  //   );
  // }
}
