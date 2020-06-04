import 'package:calendar_view/bloc/calendar.dart';
import 'package:calendar_view/entities/event.dart';
import 'package:calendar_view/views/calendar/calendar_view_basic.dart';
import 'package:calendar_view/views/calendar/calendar_view_collapse.dart';
import 'package:calendar_view/views/calendar/calendar_view_date.dart';
import 'package:calendar_view/views/calendar/calendar_view_month_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CalendarView extends StatelessWidget {
  final Map<DateTime, List<Event>> events;
  final List<DateTime> selected;
  final bool collapseView;
  final ValueChanged<DateTime> onDateSelected;
  final Color monthColor;
  final Animation<double> animation;
  final DateTime defaultValue;
  CalendarView({
    this.events,
    this.onDateSelected,
    this.collapseView = false,
    this.selected = const [],
    this.monthColor,
    this.animation,
    this.defaultValue,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<CalendarBloc>(
      create: (_) => CalendarBloc()
        ..updateMonth(DateTime.now())
        ..updateSelectedDate(defaultValue),
      dispose: (_, CalendarBloc bloc) => bloc.dispose(),
      child: CalendarViewContainer(
        events: events,
        onDateSelected: onDateSelected,
        collapseView: collapseView,
        selected: selected,
        monthColor: monthColor,
        animation: animation,
      ),
    );
  }
}

class CalendarViewContainer extends StatefulWidget {
  final Map<DateTime, List<Event>> events;
  final List<DateTime> selected;
  final bool collapseView;
  final Function onDateSelected;
  final Color monthColor;
  final Animation<double> animation;
  CalendarViewContainer({
    this.events,
    this.onDateSelected,
    this.collapseView = false,
    this.selected = const [],
    this.monthColor,
    this.animation,
    Key key,
  }) : super(key: key);

  @override
  _CalendarViewContainerState createState() => _CalendarViewContainerState();
}

class _CalendarViewContainerState extends State<CalendarViewContainer> {
  List<String> dateLabels;

  Animation<double> opacity;
  CalendarBloc get bloc {
    return Provider.of<CalendarBloc>(context, listen: false);
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
  void initState() {
    DateTime dateTime = DateTime.now();
    dateTime = dateTime.subtract(Duration(days: (dateTime.weekday)));
    DateFormat dateFormat = DateFormat.E();
    dateLabels = List.generate(
      7,
      (i) => dateFormat
          .format(
            dateTime.add(
              Duration(days: i),
            ),
          )
          .substring(0, 1),
    );

    if (widget.animation != null)
      opacity = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: widget.animation,
          curve: Interval(
            0.0,
            1.0,
            curve: Curves.easeInOutBack,
          ),
        ),
      );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildMonthControllWithAnimation(),
          _buildDayHeader(),
          widget.collapseView
              ? CalanderViewCollapse(
                  events: widget.events,
                  onDateSelected: widget.onDateSelected,
                  selected: widget.selected,
                )
              : CalanderViewBasic(
                  events: widget.events,
                  onDateSelected: widget.onDateSelected,
                  selected: widget.selected,
                ),
          SizedBox(height: 12)
        ],
      ),
    );
  }

  Container _buildDayHeader() {
    return Container(
      child: GridView.count(
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 7,
        childAspectRatio: 1.3,
        children: List.generate(7, (i) {
          return CalendarViewDate(dateLabels[i],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ));
        }),
      ),
    );
  }

  Widget _buildMonthControllWithAnimation() {
    return widget.animation == null
        ? _buildMonthControll()
        : AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              return _buildMonthControll();
            },
          );
  }

  Container _buildMonthControll() {
    ThemeData theme = Theme.of(context);
    double opacityValue;
    if (opacity == null) {
      opacityValue = widget.collapseView ? 0 : 1;
    } else {
      opacityValue =
          opacity.value < 0 ? 0 : opacity.value > 1 ? 1 : opacity.value;
    }
    Color textColor = widget.monthColor == null
        ? null
        : widget.monthColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;
    return Container(
        height: 64,
        color: widget.monthColor,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 0,
              left: -24 * (1.0 - opacityValue),
              child: Opacity(
                opacity: opacityValue,
                child: IconButton(
                  onPressed: () => addMonth(-1),
                  icon: Icon(
                    Icons.chevron_left,
                    size: 32,
                    color: textColor,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              left: 16 + 32 * (opacityValue),
              right: 16 + 32 * (opacityValue),
              child: Container(
                alignment: Alignment.centerLeft,
                child: StreamBuilder<DateTime>(
                    stream: bloc.monthStream,
                    builder: (context, snapshot) {
                      DateTime dateTime = snapshot.data ?? bloc.monthDateTime;
                      String month = DateFormat("MMMM yyyy").format(dateTime);

                      return InkWell(
                        onTap: widget.collapseView ? null : showMonthPicker,
                        child: Container(
                          child: Text(
                            month,
                            style: theme.textTheme.headline4.copyWith(
                                color: textColor, fontWeight: FontWeight.w200),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: -24 * (1.0 - opacityValue),
              child: Opacity(
                opacity: opacityValue,
                child: IconButton(
                  onPressed: () => addMonth(1),
                  icon: Icon(
                    Icons.chevron_right,
                    size: 32,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void showMonthPicker() {
    showDialog(
        context: context,
        builder: (_) => CalendarViewMonthPicker(context: context));
  }

  void addMonth(int n) {
    DateTime _dateTime = bloc.monthDateTime;
    updateDate(DateTime(_dateTime.year, _dateTime.month + n, _dateTime.day));
  }

  void addYear(int n) {
    DateTime _dateTime = bloc.monthDateTime;

    updateDate(DateTime(_dateTime.year + n, _dateTime.month, _dateTime.day));
  }

  void updateDate(DateTime dateTime) {
    bloc.updateMonth(dateTime);
  }
}
