import 'package:bonobo/ui/models/interest.dart';
import 'package:flutter/material.dart';

class ClickableInterest extends StatelessWidget {
  ClickableInterest({
    this.interest,
    this.onTap,
    this.color,
    this.opacity: .3,
  });

  final Interest interest;
  final VoidCallback onTap;
  final Color color;
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          children: <Widget>[
            Center(
              child: Image.network(
                interest.imageUrl,
                color: Colors.black.withOpacity(opacity),
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),
            Center(
                child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "${interest.name}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
