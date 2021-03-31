import 'package:bonobo/services/auth.dart';
import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/custom_list_tile.dart';
import 'package:bonobo/ui/screens/favorites/favorites_page.dart';
import 'package:bonobo/ui/screens/my_friends/my_friends_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthBase, Database>(
      builder: (_, auth, database, __) => Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.pink,
                      Colors.orange,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: _buildUserAvatar(auth),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  CustomListTile(
                    title: "My Friends",
                    icon: Icons.people,
                    onTap: () => Navigator.of(context).push(
                      // PageRouteBuilder(
                      //   pageBuilder: (context, __, ___) =>
                      //       MyFriendsPage.create(context),
                      // ),
                      MaterialPageRoute(
                        builder: (context) => MyFriendsPage.create(context),
                      ),
                    ),
                  ),
                  CustomListTile(
                    title: "Favorites",
                    icon: Icons.favorite,
                    onTap: () => Navigator.of(context).push(
                      // PageRouteBuilder(
                      //   pageBuilder: (_, __, ___) => FavoritesPage(),
                      // ),
                      MaterialPageRoute(builder: (context) => FavoritesPage()),
                    ),
                  ),
                  CustomListTile(
                    title: "Sign Out",
                    icon: Icons.power_settings_new,
                    onTap: () => auth.signOut(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(AuthBase auth) {
    return Container(
      child: FutureBuilder<User>(
        future: auth.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data;
            return Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: user.photoURL == null
                      ? AssetImage('assets/placeholder.jpg')
                      : NetworkImage(user.photoURL),
                ),
                SizedBox(height: 15),
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            print("Drawer error: ${snapshot.error}");
          }
          return CircleAvatar(
            radius: 45,
          );
        },
      ),
    );
  }
}