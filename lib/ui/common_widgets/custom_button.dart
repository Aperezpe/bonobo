import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    @required this.text,
    this.color,
    this.disableColor,
    this.textColor,
    @required this.onPressed,
    this.height: 50,
    this.width: 350,
    this.padding,
  });

  final String text;
  final Color color;
  final Color textColor;
  final Color disableColor;
  final VoidCallback onPressed;
  final double height;
  final double width;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color,
      disabledColor: disableColor,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.0,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      padding: padding != null ? padding : EdgeInsets.all(15.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      onPressed: onPressed,
    );
  }
}
