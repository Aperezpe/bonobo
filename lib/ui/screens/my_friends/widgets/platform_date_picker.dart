import 'package:bonobo/ui/common_widgets/platform_widget.dart';
import 'package:bonobo/ui/screens/my_friends/widgets/ios_date_picker.dart';
import 'package:flutter/material.dart';

typedef DropdownButtonBuilder<T> = Widget Function(T selectedValue);

// TODO: User cupertino pickers for everything
class PlatformDatePicker extends PlatformWidget {
  PlatformDatePicker({
    this.selectedDate,
    this.selectDate,
    this.initialDate,
    this.dropdownButton,
  });

  final DateTime initialDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;
  final DropdownButtonBuilder<DateTime> dropdownButton;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return IOSDatePicker(
      initialDate: initialDate,
      selectedDate: selectedDate,
      selectDate: selectDate,
      dropdownButton: dropdownButton,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return IOSDatePicker(
      initialDate: initialDate,
      selectedDate: selectedDate,
      selectDate: selectDate,
      dropdownButton: dropdownButton,
    );
  }
}
