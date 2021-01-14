import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SignInTextField extends StatelessWidget {
  SignInTextField({
    @required this.controller,
    this.hintText = "",
    this.icon,
    this.textInputAction,
    this.onEditingComplete,
    this.obscureText = false,
    this.errorText = '',
    @required this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputAction textInputAction;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final String errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(icon),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        fillColor: Color(0xffEAEAEA),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        enabled: enabled,
      ),
      obscureText: obscureText,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
    );
  }
}
