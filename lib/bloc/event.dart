import 'dart:developer';

import 'package:calendar_view/bloc/base.dart';
import 'package:calendar_view/entities/event.dart';
import 'package:calendar_view/resources/database.dart';

class EventBloc extends BaseBloc<EventBundle> {
  AppDatabase db = AppDatabase();
  Future<EventBundle> retrieveEvents() async {
    try {
      List<Event> events = await (await db.init()).getEvents();

      EventBundle bundle = EventBundle(eventMap: toMap(events));
      sink.add(bundle);

      return bundle;
    } catch (e) {}
    return null;
  }

  Stream startStream() {
    log("startStream: $data");

    if (data == null) {
      retrieveEvents(); //.then((value) => sink.add(value));
    }
    return stream;
  }

  Future createEvent(Event event, bool isEdit) async {
    try {
      AppDatabase database = await db.init();

      if (isEdit == null)
        await database.deleteEvent(event);
      else
        await (isEdit ? database.updateEvent(event) : database.addEvent(event));
      await retrieveEvents();
    } catch (e) {}
  }
}

Map<DateTime, List<Event>> toMap(List<Event> events) {
  Map<DateTime, List<Event>> eventMap = {};
  log("toMap: ${events.length}");

  events.forEach((element) {
    if (element.startDateTime == null) return;
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(element.startDateTime);

    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
    log("E: ${element.subject} $dateTime");

    eventMap[dateTime] ??= [];
    eventMap[dateTime].add(element);
  });
  return eventMap.map((key, value) => MapEntry(
      key, value..sort((v1, v2) => v1.startDateTime - v2.startDateTime)));
}

class EventBundle {
  final Map<DateTime, List<Event>> eventMap;

  EventBundle({this.eventMap});
}
