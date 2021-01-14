import 'package:bonobo/ui/screens/friend/models/friend_page_model.dart';
import 'package:bonobo/ui/style/fontStyle.dart';
import 'package:flutter/material.dart';

class BudgetSlider extends StatefulWidget {
  final FriendPageModel model;
  BudgetSlider({@required this.model});

  @override
  _BudgetSliderState createState() => _BudgetSliderState();
}

class _BudgetSliderState extends State<BudgetSlider> {
  RangeValues onStartValues;

  /// Prevents rangeValues to be equal
  void _onChangeEnd(RangeValues endValues) {
    if (onStartValues.start != endValues.start) {
      if (endValues.start == endValues.end) {
        widget.model.updateBudget(
          RangeValues(endValues.start - 10, endValues.end),
        );
      }
    } else if (onStartValues.end != endValues.end) {
      if (endValues.start == endValues.end) {
        widget.model.updateBudget(
          RangeValues(endValues.start, endValues.end + 10),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 15, bottom: 10),
          child: Text(
            "Budget",
            style: h3,
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 18, right: 18),
          child: Row(
            children: [
              Container(width: 25, child: Text("${widget.model.startValue}")),
              Expanded(
                child: RangeSlider(
                  values: widget.model.currentRangeValues,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  onChanged: widget.model.updateBudget,
                  onChangeStart: (values) => onStartValues = values,
                  onChangeEnd: _onChangeEnd,
                ),
              ),
              Container(
                width: 40,
                child: widget.model.endValue == 100
                    ? Text("${widget.model.endValue}+")
                    : Text("${widget.model.endValue}"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
