import 'package:calendar_view/bloc/event.dart';
import 'package:calendar_view/entities/event.dart';
import 'package:calendar_view/pages/calendar.dart';
import 'package:calendar_view/views/event_creator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController appBarAnimationController;
  final EventBloc _eventBloc = EventBloc();
  PersistentBottomSheetController _bottomSheetController;

  ThemeData get theme => Theme.of(context);
  List<DateTime> _selectedDates = [];

  @override
  void initState() {
    DateTime dateTime = DateTime.now();
    dateTime.subtract(Duration(days: dateTime.weekday));
    _selectedDates.add(DateTime(dateTime.year, dateTime.month, dateTime.day));

    super.initState();

    appBarAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (c) => _eventBloc..register(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false, //new line
        appBar: AppBar(
          leading: _bottomSheetController == null ? Icon(Icons.menu) : null,
          automaticallyImplyLeading: _bottomSheetController == null,
          iconTheme: theme.iconTheme.copyWith(color: theme.disabledColor),
          brightness: _bottomSheetController == null
              ? theme.brightness
              : Brightness.dark,
          backgroundColor: _bottomSheetController == null
              ? theme.canvasColor
              : theme.primaryColor,
          elevation: 0,
        ),
        body: StreamBuilder<EventBundle>(
            stream: _eventBloc.startStream(),
            builder: (context, snapshot) {
              return CalendarPage(
                events: _eventBloc.data?.eventMap ?? {},
                selectedDates: _selectedDates,
                onEdit: (event) => showEditorBottomSheet(context, event),
              );
            }),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    bool isShowBottomSheet = _bottomSheetController != null;
    return StreamBuilder(
      stream: _eventBloc.startStream(),
      builder: (_context, snapshot) {
        return FloatingActionButton(
          onPressed: () {
            if (isShowBottomSheet) {
              FocusScope.of(context).requestFocus(null);
              _bottomSheetController.close();
            } else
              showEditorBottomSheet(_context);
          },
          child: Icon(
            isShowBottomSheet ? Icons.clear : Icons.add,
            color: isShowBottomSheet ? theme.errorColor : null,
          ),
          backgroundColor:
              isShowBottomSheet ? theme.canvasColor : theme.primaryColor,
        );
      },
    );
  }

  void showEditorBottomSheet(BuildContext _context, [Event event]) {
    return setState(() {
      _bottomSheetController = showBottomSheet(
        context: _context,
        builder: (context) => EventCreator(
          dateTime: _selectedDates.isEmpty ? null : _selectedDates[0],
          event: event,
          onEventCreate: (Event event, bool isEdit) {
            _eventBloc.createEvent(event, isEdit);
            Navigator.of(context).pop();
          },
        ),
      );
      _bottomSheetController.closed.then((_) {
        setState(() {
          _bottomSheetController = null;
        });
      });
    });
  }
}
