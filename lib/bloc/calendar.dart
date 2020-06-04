import 'dart:async';

import 'package:calendar_view/bloc/base.dart';

class CalendarBloc extends BaseBloc<DateTime> {
  StreamController<DateTime> _monthStreamController =
      StreamController<DateTime>();
  Stream<DateTime> monthStream;

  DateTime _dateTime;
  DateTime get dateTime => _dateTime ?? DateTime.now();

  DateTime _monthDateTime;
  DateTime get monthDateTime => _monthDateTime ?? DateTime.now();
  DateTime collapseDateTime;

  CalendarBloc() {
    monthStream = _monthStreamController.stream.asBroadcastStream();

    stream.listen((DateTime data) {
      _dateTime = data;
    });
    monthStream.listen((DateTime data) {
      _monthDateTime = data;
    });
  }

  void dispose() {
    super.dispose();
    _monthStreamController.close();
  }

  void updateSelectedDate(DateTime dateTime) {
    sink.add(dateTime);
  }

  void updateMonth(DateTime dateTime) {
    _monthStreamController.sink.add(dateTime);
  }
}
