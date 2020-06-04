import 'package:calendar_view/entities/event.dart';
import 'package:calendar_view/helper/time.dart';
import 'package:flutter/material.dart';

class EventList extends StatefulWidget {
  EventList({this.events, Key key, this.onEdit}) : super(key: key);
  final List<Event> events;
  final ValueChanged<Event> onEdit;

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
          color: theme.accentColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8)),
              width: 120,
              height: 8,
            ),
          ),
          Expanded(
            child: widget.events?.isEmpty ?? true
                ? Container(
                    margin: EdgeInsets.only(top: 16),
                    alignment: Alignment.topCenter,
                    child: Text(
                      "No events",
                      style: theme.textTheme.headline6
                          .copyWith(color: Colors.white70),
                    ),
                  )
                : buildListView(theme),
          ),
        ],
      ),
    );
  }

  ListView buildListView(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.events?.length ?? 0,
      itemBuilder: (context, i) {
        Event event = widget.events[i];
        return InkWell(
          onTap: () => widget.onEdit(event),
          child: Container(
            child: Stack(
              children: <Widget>[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        width: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: 4,
                                color: Colors.white38,
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: 4,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: buildEventDetails(event, theme),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => widget.onEdit(event),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  Card buildEventDetails(Event event, ThemeData theme) {
    DateTime startDateTime =
        DateTime.fromMillisecondsSinceEpoch(event.startDateTime);
    DateTime endDateTime =
        DateTime.fromMillisecondsSinceEpoch(event.endDateTime);

    Duration duration = endDateTime.difference(startDateTime);
    return Card(
      elevation: 0,
      color: Colors.white10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  TimeHelper.toText(startDateTime.hour, startDateTime.minute),
                  style:
                      theme.textTheme.subtitle1.copyWith(color: Colors.white),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.white70,
                ),
                Text(
                  TimeHelper.toText(endDateTime.hour, endDateTime.minute),
                  style:
                      theme.textTheme.subtitle1.copyWith(color: Colors.white),
                ),
                Text(
                  " (${TimeHelper.toDurationTextByDuration(duration)})",
                  style:
                      theme.textTheme.subtitle1.copyWith(color: Colors.white70),
                ),
              ],
            ),
            Divider(
              color: Colors.white38,
            ),
            Text(
              event.subject,
              style: theme.textTheme.subtitle1
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              event.note.isNotEmpty ? event.note : "-",
              style: theme.textTheme.subtitle1.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
