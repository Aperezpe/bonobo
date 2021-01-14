import 'package:bonobo/ui/models/product.dart';
import 'package:bonobo/ui/style/fontStyle.dart';
import 'package:flutter/material.dart';

class ClickableProduct extends StatelessWidget {
  ClickableProduct({
    @required this.product,
    @required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(8, 0, 15, 5),
              child: Column(
                children: [
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  // Text(
                  //   product.distributor,
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(fontSize: 14),
                  // ),
                  Text(
                    "\$${product.price}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
