import 'package:calendar_view/entities/event.dart';
import 'package:calendar_view/views/calendar/calendar_view.dart';
import 'package:calendar_view/views/event_list.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key key, this.selectedDates, this.events, this.onEdit})
      : super(key: key);
  final List<DateTime> selectedDates;
  final Map<DateTime, List<Event>> events;
  final ValueChanged<Event> onEdit;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  AnimationController scrollAnimationController;

  final GlobalKey _calendarKey = GlobalKey();
  double calendarHeight;
  double calendarMinHeight = 160;
  double calendarMaxHeight;

  double startY;
  double endY;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (calendarMaxHeight == null) {
        calendarMaxHeight = _calendarKey.currentContext.size.height;
        double widthPerCell = _calendarKey.currentContext.size.width / 7;
        double heightPerCell = widthPerCell / 1.3;
        calendarMinHeight = 64 + heightPerCell * 2;
      }
    });
    scrollAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  Future<void> _playAnimation() async {
    if (calendarHeight == calendarMinHeight) {
      await _collapseAnimation();
    } else {
      await _expandAnimation();
    }
  }

  Future<void> _collapseAnimation() async {
    try {
      await scrollAnimationController
          .forward(from: scrollAnimationController.value)
          .orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  Future<void> _expandAnimation() async {
    try {
      await scrollAnimationController
          .reverse(from: scrollAnimationController.value)
          .orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!Navigator.of(context).canPop() &&
            scrollAnimationController.value == 1) {
          scrollAnimationController.reverse();
          return false;
        }
        return true;
      },
      child: buildContainer(),
    );
  }

  Container buildContainer() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
                animation: scrollAnimationController.view,
                builder: (context, child) {
                  double height;
                  if (calendarMaxHeight != null) {
                    double range = calendarMaxHeight - calendarMinHeight;
                    height = calendarMinHeight +
                        range * (1 - scrollAnimationController.value);
                  }
                  return SizedBox(
                    height: height,
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: CalendarView(
                        events: widget.events,
                        key: _calendarKey,
                        animation: scrollAnimationController.view,
                        collapseView: scrollAnimationController.value == 1,
                        selected: widget.selectedDates,
                        onDateSelected: (datetTime) => setState(() {
                          widget.selectedDates[0] = datetTime;
                        }),
                      ),
                    ),
                  );
                }),
            Expanded(
              child: GestureDetector(
                child: EventList(
                  events: widget.events[widget.selectedDates[0]],
                  onEdit: widget.onEdit,
                ),
                onVerticalDragDown: (DragDownDetails details) {
                  startY = details.localPosition.dy;
                },
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  endY = details.localPosition.dy;
                  double diff = startY - endY;
                  startY = details.localPosition.dy;

                  double newHeight =
                      (calendarHeight ?? calendarMaxHeight) - diff;

                  if (newHeight >= calendarMinHeight &&
                      newHeight <= calendarMaxHeight) {
                    double range = calendarMaxHeight - calendarMinHeight;
                    double percent = (newHeight - calendarMinHeight) / range;
                    percent = (percent * 10).round() / 10;
                    if (percent != scrollAnimationController.value)
                      scrollAnimationController.animateTo(1 - percent,
                          duration: Duration(milliseconds: 0));
                    // setState(() {
                    calendarHeight = newHeight;
                    // });
                  }
                },
                onVerticalDragEnd: (DragEndDetails details) {
                  double mid = calendarMinHeight +
                      (calendarMaxHeight - calendarMinHeight) / 2;
                  // setState(() {
                  if (calendarHeight != null)
                    calendarHeight =
                        calendarHeight > mid ? null : calendarMinHeight;
                  _playAnimation();
                  // });
                },
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
