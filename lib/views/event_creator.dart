import 'package:calendar_view/components/button.dart';
import 'package:calendar_view/components/time_picker.dart';
import 'package:calendar_view/entities/event.dart';
import 'package:calendar_view/helper/date.dart';
import 'package:calendar_view/helper/time.dart';
import 'package:calendar_view/views/calendar/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCreator extends StatefulWidget {
  EventCreator({this.onEventCreate, this.dateTime, Key key, this.event})
      : super(key: key);
  final Function(Event, bool) onEventCreate;
  final DateTime dateTime;
  final Event event;
  @override
  _EventCreatorState createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator>
    with TickerProviderStateMixin {
  DateTime _startDateTime;
  DateTime _endDateTime;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.event == null) {
      _startDateTime = DateTime.now();
      if (widget.dateTime != null)
        _startDateTime = DateTime(widget.dateTime.year, widget.dateTime.month,
            widget.dateTime.day, _startDateTime.hour, _startDateTime.minute);
      if (_startDateTime.minute > 0) {
        _startDateTime = _startDateTime
            .add(Duration(hours: 1, minutes: -_startDateTime.minute));
      }
      _endDateTime = _startDateTime.add(Duration(hours: 1));
    } else {
      _startDateTime =
          DateTime.fromMillisecondsSinceEpoch(widget.event.startDateTime);
      _endDateTime =
          DateTime.fromMillisecondsSinceEpoch(widget.event.endDateTime);
      _titleController.text = widget.event.subject;
      _messageController.text = widget.event.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildCreateEventForm(context));
  }

  Widget _buildCreateEventForm(context) {
    ThemeData theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildTopContainer(theme),
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: _buildDateTimeField(
                              label: "On",
                              hintText: "--/--/----",
                              type: TextFieldType.date),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          height: 60,
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        Expanded(
                          flex: 1,
                          child: _buildDateTimeField(
                            label: "At",
                            hintText: "--:--",
                            type: TextFieldType.time,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 24,
                    ),
                    _buildTextField(
                      label: "Note",
                      hintText: "(Optional)",
                      controller: _messageController,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    ButtonTheme(
                      minWidth: double.maxFinite,
                      buttonColor: Colors.blueGrey.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: RaisedButton(
                        elevation: 0,
                        onPressed: () => createEvent(widget.event != null),
                        child: Text(
                          widget.event == null ? "Create" : "Save",
                          style: theme.textTheme.subtitle1
                              .copyWith(color: theme.accentColor),
                        ),
                      ),
                    ),
                    widget.event == null
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(top: 4),
                            child: ButtonTheme(
                              minWidth: double.maxFinite,
                              buttonColor: Colors.red.withOpacity(1),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: RaisedButton(
                                elevation: 0,
                                onPressed: createEvent,
                                child: Text(
                                  "Delete",
                                  style: theme.textTheme.subtitle1
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildTopContainer(ThemeData theme) {
    return Container(
      color: theme.primaryColor,
      padding: EdgeInsets.fromLTRB(24, 0, 72, 16),
      child: TextFormField(
        autofocus: _titleController.text.isEmpty,
        controller: _titleController,
        cursorColor: Colors.white,
        maxLines: 3,
        minLines: 1,
        decoration: InputDecoration(
          labelText: "Subject",
          contentPadding: EdgeInsets.only(top: 0, bottom: 4),
          labelStyle: theme.textTheme.headline6.copyWith(
            color: Colors.white70,
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        style: theme.textTheme.headline4.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildDateTimeField({
    String label,
    String hintText,
    TextFieldType type = TextFieldType.text,
  }) {
    ThemeData theme = Theme.of(context);

    TextStyle textStyle = theme.textTheme.headline6;
    TextStyle subTextStyle =
        theme.textTheme.subtitle1.copyWith(color: Theme.of(context).hintColor);
    Duration duration = _endDateTime.difference(_startDateTime);
    int hour = (duration.inMinutes / 60).floor();
    int minute = duration.inMinutes % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(color: theme.disabledColor),
        ),
        SizedBox(
          height: 6,
        ),
        Builder(builder: (_context) {
          return InkWell(
            onTap: type == TextFieldType.text
                ? null
                : () {
                    if (type == TextFieldType.date) {
                      DateTime dateTime = _startDateTime;
                      showDatePickerDialog(
                        _context,
                        dateTime,
                        theme,
                      );
                    } else if (type == TextFieldType.time) {
                      showTimeRangePicker(_context, theme);
                    }
                  },
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  type == TextFieldType.date
                      ? Text(DateUtils.monthDayYear.format(_startDateTime),
                          style: textStyle)
                      : Row(
                          children: <Widget>[
                            Text(
                              DateFormat.Hm().format(_startDateTime),
                              style: textStyle,
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: theme.hintColor,
                            ),
                            Text(DateFormat.Hm().format(_endDateTime),
                                style: textStyle),
                          ],
                        ),
                  Text(
                    type == TextFieldType.time
                        ? TimeHelper.toDurationText(hour, minute)
                        : DateFormat.EEEE().format(_startDateTime),
                    style: subTextStyle,
                  )
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextField({
    String label,
    String hintText,
    TextEditingController controller,
    TextFieldType type = TextFieldType.text,
  }) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(color: theme.disabledColor),
        ),
        TextFormField(
          controller: controller,
          readOnly: type != TextFieldType.text,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: theme.disabledColor,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.blueGrey.withOpacity(0.3), width: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Future showTimeRangePicker(BuildContext _context, ThemeData theme) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    return showDialog(
      context: _context,
      builder: (_) => Dialog(
        insetPadding:
            EdgeInsets.fromLTRB(8, padding.top + 8, 8, padding.bottom + 8),
        elevation: 16,
        child: TimeRangePicker(
          startTime: TimeOfDay.fromDateTime(_startDateTime),
          endTime: TimeOfDay.fromDateTime(_endDateTime),
          todayDate: _startDateTime,
          onConfirm: (start, end) {
            setState(() {
              _startDateTime = DateTime(
                _startDateTime.year,
                _startDateTime.month,
                _startDateTime.day,
                start.hour,
                start.minute,
              );
              _endDateTime = DateTime(
                _endDateTime.year,
                _endDateTime.month,
                _endDateTime.day,
                end.hour,
                end.minute,
              );
            });
          },
        ),
      ),
    );
  }

  Future showDatePickerDialog(
      BuildContext _context, DateTime dateTime, ThemeData theme) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    return showDialog(
      context: _context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 16,
        insetPadding:
            EdgeInsets.fromLTRB(8, padding.top + 8, 8, padding.bottom + 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CalendarView(
                defaultValue: dateTime,
                // monthColor: theme.primaryColor,
                onDateSelected: (DateTime dateTime) {
                  setState(() {
                    _startDateTime = DateTime(
                      dateTime.year,
                      dateTime.month,
                      dateTime.day,
                      _startDateTime.hour,
                      _startDateTime.minute,
                    );
                    _endDateTime = DateTime(
                      dateTime.year,
                      dateTime.month,
                      dateTime.day,
                      _endDateTime.hour,
                      _endDateTime.minute,
                    );
                  });
                },
              ),
              FillFlatButton(
                text: "Confirm",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  createEvent([bool isEdit]) {
    if (_titleController.text.isEmpty) return;

    Event event = widget.event ?? Event();
    event.subject = _titleController.text;
    event.note = _messageController.text;
    event.startDateTime = _startDateTime.millisecondsSinceEpoch;
    event.endDateTime = _endDateTime.millisecondsSinceEpoch;
    widget.onEventCreate(event, isEdit);

    _titleController.clear();
    _messageController.clear();
  }
}

enum TextFieldType {
  text,
  date,
  time,
}
