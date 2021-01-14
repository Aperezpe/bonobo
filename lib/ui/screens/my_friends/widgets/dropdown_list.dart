import 'package:flutter/material.dart';

class DropdownList extends StatefulWidget {
  DropdownList({
    @required this.onChanged,
    @required this.items,
    this.labelText,
    this.dropdownValue = 0,
  });
  final ValueChanged<int> onChanged;
  final dynamic items;
  final int dropdownValue;
  final String labelText;

  @override
  _DropdownListState createState() => _DropdownListState();
}

class _DropdownListState extends State<DropdownList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField(
          isExpanded: true,
          value: widget.dropdownValue,
          items: widget.items,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            fillColor: Colors.white,
            filled: true,
            labelText: widget.labelText,
          ),
        ),
      ],
    );
  }
}
