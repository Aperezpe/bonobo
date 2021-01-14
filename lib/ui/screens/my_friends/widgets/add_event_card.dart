import 'package:bonobo/ui/screens/my_friends/models/set_special_event_model.dart';
import 'package:bonobo/ui/screens/my_friends/models/special_event.dart';
import 'package:bonobo/ui/screens/my_friends/widgets/date_picker.dart';
import '../../../style/fontStyle.dart';

import 'package:flutter/material.dart';

import 'dropdown_list.dart';

class AddEventCard extends StatefulWidget {
  final int index;
  final List<String> events;
  final SetSpecialEventModel model;
  final SpecialEvent specialEvent;

  const AddEventCard({
    Key key,
    this.index,
    this.events,
    this.model,
    this.specialEvent,
  }) : super(key: key);

  @override
  _AddEventCardState createState() => _AddEventCardState();
}

class _AddEventCardState extends State<AddEventCard> {
  int _eventDropdownValue;
  DateTime _specialDate;
  bool _isConcurrent;

  int get eventNumber => widget.index + 1;

  @override
  void initState() {
    _eventDropdownValue = widget.events.indexOf(widget.specialEvent.name);
    _specialDate = widget.specialEvent.date ?? DateTime.now();
    _isConcurrent = widget.specialEvent.isConcurrent ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Container(
          padding: EdgeInsets.only(left: 15.0, right: 18.0),
          child: Column(
            children: [
              DropdownList(
                dropdownValue: _eventDropdownValue,
                labelText: "Event",
                items: [
                  for (int i = 0; i < widget.events.length; i++)
                    DropdownMenuItem(
                      child: Text(widget.events[i]),
                      value: i,
                    )
                ],
                onChanged: (value) => {
                  setState(() => {_eventDropdownValue = value}),
                  widget.model.updateSpecialEvent(
                    widget.index,
                    name: widget.events[value],
                  )
                },
              ),
              DatePicker(
                labelText: 'Date',
                selectedDate: _specialDate,
                selectDate: (date) => {
                  setState(() => _specialDate = date),
                  widget.model.updateSpecialEvent(
                    widget.index,
                    date: _specialDate,
                  ),
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Concurrent", style: p),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 42.0,
                      child: Switch(
                        value: _isConcurrent ?? false,
                        onChanged: (value) => {
                          setState(() => _isConcurrent = value),
                          widget.model.updateSpecialEvent(
                            widget.index,
                            isConcurrent: _isConcurrent,
                          ),
                        },
                        activeColor: Colors.greenAccent,
                        activeTrackColor: Colors.lightGreenAccent[400],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      color: Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Event $eventNumber",
            style: h3,
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.zero,
            child: IconButton(
              splashRadius: 18,
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () => {
                widget.model
                    .deleteSpecialEvent(widget.index, widget.specialEvent),
              },
            ),
          ),
        ],
      ),
    );
  }
}
