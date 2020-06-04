import 'package:calendar_view/bloc/calendar.dart';
import 'package:calendar_view/components/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CalendarViewMonthPicker extends StatefulWidget {
  CalendarViewMonthPicker({this.context, Key key}) : super(key: key);
  final BuildContext context;

  @override
  _CalendarViewMonthPickerState createState() =>
      _CalendarViewMonthPickerState();
}

class _CalendarViewMonthPickerState extends State<CalendarViewMonthPicker> {
  CalendarBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = Provider.of(widget.context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildMonthPicker(context);
  }

  Widget _buildMonthPicker(context) {
    ThemeData theme = Theme.of(context);

    return Dialog(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: _buildDialogContent(theme),
    );
  }

  StreamBuilder<DateTime> _buildDialogContent(ThemeData theme) {
    return StreamBuilder<DateTime>(
        stream: bloc.monthStream,
        builder: (context, snapshot) {
          DateTime monthDateTime = snapshot.data ?? bloc.monthDateTime;
          String year = DateFormat("yyyy").format(monthDateTime);

          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  // color: theme.accentColor,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => addYear(-1),
                        icon: Icon(
                          Icons.chevron_left,
                          size: 32,
                          // color: Colors.white,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          year,
                          style: theme.textTheme.headline4.copyWith(
                              // color: Colors.white,
                              fontWeight: FontWeight.w200),
                        ),
                      ),
                      IconButton(
                        onPressed: () => addYear(1),
                        icon: Icon(
                          Icons.chevron_right,
                          size: 32,
                          // color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: List.generate(
                        4,
                        (i) => Row(
                              children: List.generate(3, (j) {
                                DateTime dateTime = DateTime(
                                    monthDateTime.year, i * 3 + j + 1, 1);

                                return _buildMonth(monthDateTime, dateTime);
                              }),
                            )),
                  ),
                ),
                FillFlatButton(
                  text: "Done",
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          );
        });
  }

  Expanded _buildMonth(DateTime monthDateTime, DateTime dateTime) {
    ThemeData theme = Theme.of(context);
    String month = DateFormat("MMM").format(dateTime);
    bool isSelected = monthDateTime.month == dateTime.month;
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSelected ? theme.accentColor.withOpacity(0.1) : null),
        child: InkWell(
          onTap: () {
            updateDate(dateTime);
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  month,
                  style: theme.textTheme.subtitle1.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
              Container(
                height: 2,
                color: isSelected
                    ? theme.accentColor.withOpacity(0.4)
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addYear(int n) {
    DateTime _dateTime = bloc.monthDateTime;

    updateDate(DateTime(_dateTime.year + n, _dateTime.month, _dateTime.day));
  }

  void updateDate(DateTime dateTime) {
    bloc.updateMonth(dateTime);
  }
}
