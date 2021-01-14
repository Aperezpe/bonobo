import 'package:bonobo/services/database.dart';
import 'package:bonobo/ui/common_widgets/circle_image_button.dart';
import 'package:bonobo/ui/common_widgets/list_item_builder.dart';
import 'package:bonobo/ui/models/product.dart';
import 'package:bonobo/ui/screens/friend/widgets/clickable_product.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:bonobo/ui/screens/friend/widgets/range_slider.dart';
import 'package:bonobo/ui/screens/friend/widgets/tabs.dart';
import 'package:bonobo/ui/screens/my_friends/models/friend.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:bonobo/ui/style/fontStyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../style/fontStyle.dart';
import 'models/friend_page_model.dart';

class FriendPage extends StatelessWidget {
  FriendPage({@required this.model});
  final FriendPageModel model;

  static Future<void> show(
    BuildContext context, {
    @required Friend friend,
    @required List<SpecialEvent> friendSpecialEvents,
    @required FirestoreDatabase database,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<FriendPageModel>(
          create: (context) => FriendPageModel(
            database: database,
            friend: friend,
            friendSpecialEvents: friendSpecialEvents,
          ),
          child: Consumer<FriendPageModel>(
            builder: (context, model, __) => FriendPage(
              model: model,
            ),
          ),
        ),
      ),
    );
  }

  Friend get friend => model.friend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friend.name),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.pink,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(friend.imageUrl),
                    ),
                  ),
                ),
              ),
              BudgetSlider(model: model),
              Tabs(model: model),
              _buildRecommendations(),
            ],
          ),
        ),
      ),
    );
  }

  _buildRecommendations() {
    return StreamBuilder<List<Product>>(
      stream: model.queryProductsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Product> products = model.queryProducts(
              snapshot.data, model.specialEventsNames[model.selectedTab]);
          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: products.length,
            shrinkWrap: true,
            primary: false,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .9,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (context, index) {
              return ClickableProduct(
                onTap: () {},
                product: products[index],
              );
            },
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
