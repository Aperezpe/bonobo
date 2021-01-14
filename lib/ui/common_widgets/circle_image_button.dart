import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircleImageButton extends StatelessWidget {
  CircleImageButton({
    this.text,
    this.textColor,
    this.color,
    @required this.onPressed,
    @required this.imagePath,
  });

  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onPressed;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(150),
        child: Container(
          color: Colors.red,
          child: InkWell(
            child: CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(imagePath),
            ),
            onTap: onPressed,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 12.0,
          ),
        ],
      ),
    );
  }
}
