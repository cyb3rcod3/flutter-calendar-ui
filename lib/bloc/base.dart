import 'dart:async';

import 'package:flutter/material.dart';

class BaseBloc<T> {
  BaseBloc({T initialValue}) {
    _controller.add(initialValue);
    initializeStream(_controller.stream.asBroadcastStream());
  }

  void initializeStream(Stream<T> stream) {
    stream.listen((T data) {
      _data = data;
    });
    _stream = stream;
  }

  StreamController<T> _controller = StreamController<T>();

  Stream<T> _stream;
  Stream<T> get stream => _stream;

  T _data;
  T get data => _data;

  StreamSink<T> get sink => _controller.sink;
  StreamController<T> get streamController => _controller;

  BuildContext _context;
  BuildContext get context => _context;

  ThemeData _theme;

  ThemeData get theme => _theme;
  TextTheme get textTheme => _theme.textTheme;

  Color get primaryColor => _theme.primaryColor;
  Color get accentColor => _theme.accentColor;

  Size get screenSize => MediaQuery.of(context).size;
  EdgeInsets get screenPadding => MediaQuery.of(context).padding;

  Object arguments(BuildContext context) =>
      ModalRoute.of(context).settings.arguments;

  void register(BuildContext context) {
    this._context = context;
    this._theme = Theme.of(context);
  }

  void dispose() {
    _controller.close();
  }
}
