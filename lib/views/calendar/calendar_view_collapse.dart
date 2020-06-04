import 'package:calendar_view/bloc/calendar.dart';
import 'package:calendar_view/entities/event.dart';
import 'package:calendar_view/views/calendar/calendar_view_date.dart';
import 'package:flutter/material.dart';
import 'package:infinite_view_pager/infinite_view_pager.dart';
import 'package:provider/provider.dart';

class CalanderViewCollapse extends StatefulWidget {
  final Map<DateTime, List<Event>> events;
  final List<DateTime> selected;
  final Function onDateSelected;

  CalanderViewCollapse(
      {this.events, this.onDateSelected, this.selected = const [], Key key})
      : super(key: key);

  @override
  _CalanderViewCollapseState createState() {
    return _CalanderViewCollapseState();
  }
}

class _CalanderViewCollapseState extends State<CalanderViewCollapse> {
  CalendarBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = Provider.of(context, listen: false);
  }

  int get daysInMonth {
    DateTime _dateTime = bloc.monthDateTime;
    return DateTime(_dateTime.year, _dateTime.month + 1, 1)
        .subtract(Duration(days: 1))
        .day;
  }

  int get firstDayOfMonth {
    DateTime _dateTime = bloc.monthDateTime;
    return (DateTime(_dateTime.year, _dateTime.month, 1).weekday) % 7;
  }

  @override
  Widget build(BuildContext context) {
    return _buildDayLayout();
  }

  Widget _buildDayLayout() {
    return Container(
      height: 60,
      child: InfiniteViewPager(
        onPageChanged: (direction) {
          bloc.collapseDateTime =
              bloc.collapseDateTime.add(Duration(days: 7 * direction));
          if (bloc.collapseDateTime.month != bloc.monthDateTime.month) {
            updateDate(bloc.collapseDateTime);
          }
        },
        pageBuilder: (context, week) => Container(
          child: StreamBuilder<DateTime>(
              stream: bloc.monthStream,
              builder: (context, snapshot) {
                DateTime month = snapshot.data ?? bloc.monthDateTime;
                return StreamBuilder<DateTime>(
                    stream: bloc.stream,
                    builder: (context, snapshot) {
                      return GridView.count(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        childAspectRatio: 1.3,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 7,
                        children: List.generate(7, (i) {
                          initializeCollapseDateTime(month);

                          int day = bloc.collapseDateTime.day + i + week * 7;
                          DateTime dateTime = DateTime(
                              bloc.collapseDateTime.year,
                              bloc.collapseDateTime.month,
                              day);

                          bool notSameMonth = dateTime.month != month.month;
                          List<Event> event = widget.events == null
                              ? []
                              : widget.events[dateTime] ?? [];
                          return InkWell(
                            onTap: () {
                              if (notSameMonth) {
                                updateDate(dateTime);
                              }
                              bloc.collapseDateTime = null;
                              bloc.updateSelectedDate(dateTime);
                              widget.onDateSelected(dateTime);
                            },
                            child: CalendarViewDate(
                              "${dateTime.day}",
                              selected: widget.selected.isNotEmpty &&
                                  widget.selected[0]
                                          .difference(dateTime)
                                          .inDays
                                          .abs() <=
                                      0,
                              notSameMonth: notSameMonth,
                              hasEvent: event.isNotEmpty,
                            ),
                          );
                        }),
                      );
                    });
              }),
        ),
      ),
    );
  }

  void addMonth(int n) {
    DateTime _dateTime = bloc.monthDateTime;
    updateDate(DateTime(_dateTime.year, _dateTime.month + n, _dateTime.day));
  }

  void updateDate(DateTime dateTime) {
    bloc.updateMonth(
        DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch));
  }

  void initializeCollapseDateTime(DateTime month) {
    if (bloc.collapseDateTime == null) {
      bloc.collapseDateTime = DateTime.fromMillisecondsSinceEpoch(
          widget.selected[0].millisecondsSinceEpoch);
      if (bloc.collapseDateTime.weekday > 0)
        bloc.collapseDateTime = bloc.collapseDateTime.subtract(Duration(
          days: bloc.collapseDateTime.weekday % 7,
        ));

      if (widget.selected[0].month != month.month ||
          widget.selected[0].year != month.year) {
        updateDate(widget.selected[0]);
        bloc.updateSelectedDate(widget.selected[0]);
      }
    }
  }
}
