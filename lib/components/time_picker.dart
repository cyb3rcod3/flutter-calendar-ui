import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:calendar_view/components/button.dart';
import 'package:calendar_view/helper/date.dart';
import 'package:calendar_view/helper/time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeRangePicker extends StatefulWidget {
  const TimeRangePicker(
      {Key key,
      this.todayDate,
      @required this.onConfirm,
      this.startTime,
      this.endTime})
      : super(key: key);

  final DateTime todayDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(TimeOfDay, TimeOfDay) onConfirm;

  @override
  _TimeRangePickerState createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  double startY, endY;

  double startTimeY = 24;
  double endTimeY = 100;
  double currentTimeY = 100;

  ScrollController _scrollController;
  GlobalKey<State> _scrollKey = GlobalKey();
  TimeOfDay now;
  @override
  void initState() {
    super.initState();
    now = TimeOfDay.now();
    currentTimeY = timeToY(now.hour + (now.minute / 60.0));
    initValue();
    _scrollController =
        ScrollController(initialScrollOffset: max(startTimeY - blockHeight, 0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  initValue() {
    TimeOfDay startDate = widget.startTime ?? now;
    TimeOfDay endDate =
        widget.endTime ?? TimeOfDay(hour: now.hour + 1, minute: now.minute);
    double startFraction =
        startDate.hour + (startDate.minute / 15.0).ceil() * 0.25;
    double endFraction = endDate.hour + (endDate.minute / 15.0).ceil() * 0.25;

    startTimeY = timeToY(startFraction);
    endTimeY = timeToY(endFraction);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          DateUtils.monthDayYear.format(widget.todayDate),
          style:
              theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: buildMainContent(theme),
      bottomNavigationBar: FillFlatButton(
        text: "Confirm",
        onPressed: () {
          widget.onConfirm(
            toTime(toTimeFraction(startTimeY)),
            toTime(toTimeFraction(endTimeY)),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  int blockHeight = 10 + 32 + 24;
  double toTimeFraction(pixel, [fraction = 4]) {
    return ((pixel - 9 - marginTop) * fraction / blockHeight).round() /
        fraction;
  }

  double marginTop = 16;

  SingleChildScrollView buildMainContent(ThemeData theme) {
    return SingleChildScrollView(
      key: _scrollKey,
      controller: _scrollController,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: marginTop, bottom: 8),
            child: Column(
              children: List.generate(24, (i) {
                DateTime hour = DateTime(widget.todayDate.year,
                    widget.todayDate.month, widget.todayDate.day, i);
                return Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(DateFormat.Hm().format(hour)),
                        width: 36,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(height: 8),
                                Divider(
                                  height: 1,
                                  color: theme.hintColor,
                                ),
                                Container(height: 32),
                                Divider(height: 1),
                                Container(height: 24),
                              ],
                            ),
                          ),
                          flex: 1),
                    ],
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: currentTimeY - 8,
            left: 0,
            right: 0,
            child: Container(
              height: 16,
              // color: Colors.amber.withOpacity(0.1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 8),
                    alignment: Alignment.centerRight,
                    width: 52,
                    child: now.minute < 15 || now.minute > 45
                        ? null
                        : Text(
                            "${TimeHelper.twoDigit(now.hour)}:${TimeHelper.twoDigit(now.minute)}",
                            style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: 10),
                          ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildSelection(),

          // buildAnimatedBuilder(endTimeY, _endController),
        ],
      ),
    );
  }

  StatefulBuilder buildSelection() {
    return StatefulBuilder(builder: (context, setState) {
      double startHour = toTimeFraction(startTimeY);

      return Positioned.fill(
        left: 52,
        child: Stack(
          children: <Widget>[
            buildTimeFrame(context),
            buildAnimatedBuilder(
              startTimeY,
              (v) {
                if (v <= endTimeY)
                  setState(() {
                    startTimeY = max(v, marginTop + 9).roundToDouble();
                  });
              },
              // absorbing: startTime == endTime,
              reverse: true,
            ),
            buildAnimatedBuilder(endTimeY, (v) {
              if (v >= startTimeY)
                setState(() {
                  endTimeY =
                      min(v.roundToDouble(), (24 * blockHeight).toDouble());
                });
            }),
          ],
        ),
      );
    });
  }

  TimeOfDay toTime(double time) {
    int hour = time.floor();
    int minute = (time.remainder(1.0) * 60).toInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  String toTimeText(double time) {
    int hour = time.floor();
    int minute = (time.remainder(1.0) * 60).toInt();
    return TimeHelper.toText(hour, minute);
  }

  double timeToY(double time) {
    dev.log("time : $time");
    return 9 + marginTop + (time * blockHeight).toDouble();
  }

  String toDurationText(double time) {
    int hour = time.floor();
    int minute = (time.remainder(1.0) * 60).toInt();

    return TimeHelper.toDurationText(hour, minute);
  }

  Widget buildTimeFrame(BuildContext context) {
    double startTime = toTimeFraction(startTimeY);
    double endTime = toTimeFraction(endTimeY);
    double duration = endTime - startTime;
    String durationText = toDurationText(duration);
    double height = endTimeY - startTimeY;
    double minHeight = 24;

    bool isCollapse = height < minHeight;
    TextStyle textStyle = Theme.of(context)
        .textTheme
        .subtitle2
        .copyWith(color: isCollapse ? Theme.of(context).primaryColor : null);
    Widget timeText = Row(
      children: <Widget>[
        Text(toTimeText(startTime), style: textStyle),
        Icon(
          Icons.chevron_right,
          size: 16,
        ),
        Text(toTimeText(endTime), style: textStyle),
        height >= 36 ? Container() : Text(" ($durationText)", style: textStyle)
      ],
    );
    return Positioned(
      top: isCollapse ? startTimeY - minHeight : startTimeY,
      left: 0,
      right: 0,
      child: Column(
        children: <Widget>[
          Container(
            height: isCollapse ? minHeight : 0,
            child: isCollapse ? timeText : null,
            alignment: Alignment.centerLeft,
          ),
          Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: Theme.of(context).primaryColorLight,
            child: isCollapse
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      timeText,
                      height < 36
                          ? Container()
                          : Text(
                              durationText,
                              style: Theme.of(context).textTheme.caption,
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Timer _timer;
  int step;

  Widget buildAnimatedBuilder(double yPosition, ValueChanged<double> onChanged,
      {bool absorbing = false, bool reverse = false}) {
    Color color = Theme.of(context).primaryColor;
    List<Widget> children = [
      Container(
        color: color,
        height: 1,
        width: 12,
      ),
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      Expanded(
        flex: 1,
        child: Container(
          color: color,
          height: 1,
        ),
      )
    ];
    return Positioned(
      top: yPosition - 12 + (reverse ? -14 : 6),
      left: 0,
      right: 0,
      child: AbsorbPointer(
        absorbing: absorbing,
        child: GestureDetector(
          onVerticalDragDown: (DragDownDetails details) {
            startY = details.localPosition.dy;
            if (_timer != null) {
              _timer.cancel();
              _timer = null;
            }
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            endY = details.localPosition.dy;
            double diff = startY - endY;
            startY = details.localPosition.dy;
            final RenderBox renderBoxRed =
                _scrollKey.currentContext.findRenderObject();
            double scrollContentHeight = renderBoxRed.size.height;
            double scrollContentY = renderBoxRed.localToGlobal(Offset.zero).dy;

            double newHeight = yPosition - diff;
            if (yPosition >= 0) {
              yPosition = newHeight;
              double lastScrollY = _scrollKey.currentContext.size.height +
                  _scrollController.offset;
              if ((_timer != null)) {
                double dy = details.globalPosition.dy;
                if (dy > scrollContentY && this.step < 0) {
                  _timer.cancel();
                  _timer = null;
                } else if (dy < scrollContentHeight + scrollContentY &&
                    this.step > 0) {
                  _timer.cancel();
                  _timer = null;
                } else {
                  return;
                }
              } else if (yPosition < _scrollController.offset && startY != 0) {
                this.step = -2;
                _timer = Timer.periodic(Duration(milliseconds: 0), (timer) {
                  _scrollController
                      .jumpTo(_scrollController.offset + this.step);

                  onChanged(_scrollController.offset - step);
                  if (_scrollController.offset <= 0) {
                    timer.cancel();
                    _timer = null;
                  }
                });
                return;
              } else if (yPosition > lastScrollY && startY != 0) {
                this.step = 2;

                _timer = Timer.periodic(Duration(milliseconds: 0), (timer) {
                  lastScrollY = scrollContentHeight + _scrollController.offset;
                  onChanged(lastScrollY + step);
                  _scrollController.jumpTo(_scrollController.offset + step);

                  if (_scrollController.offset + step >
                      _scrollController.position.maxScrollExtent) {
                    timer.cancel();
                    _timer = null;
                  }
                });
                return;
              }

              onChanged(yPosition);
            }
          },
          onVerticalDragEnd: (DragEndDetails details) {
            if (_timer != null) {
              _timer.cancel();
              _timer = null;
            }

            startY = null;
            onChanged(timeToY(toTimeFraction(yPosition)));
          },
          child: Container(
            height: 32,
            alignment: reverse ? Alignment.bottomCenter : Alignment.topCenter,
            color: Colors
                .transparent, //(reverse ? Colors.blue : Colors.orange).withOpacity(0.4),
            child: Row(
              children: reverse ? children.reversed.toList() : children,
            ),
          ),
        ),
      ),
    );
  }
}
