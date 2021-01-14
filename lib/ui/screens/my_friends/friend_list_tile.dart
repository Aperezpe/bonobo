import 'package:flutter/material.dart';

import 'models/friend.dart';

class FriendListTile extends StatelessWidget {
  FriendListTile({
    @required this.friend,
    @required this.backgroundImage,
    @required this.onTap,
  });
  final Friend friend;
  final VoidCallback onTap;
  final ImageProvider<Object> backgroundImage;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.all(8),
      leading: ClipOval(
        child: Image(image: backgroundImage),
      ),
      title: Text("${friend.name}", style: TextStyle(fontSize: 18)),
      subtitle: Text(
        "${friend.age}",
        style: TextStyle(fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
