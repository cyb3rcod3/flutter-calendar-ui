import 'package:calendar_view/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(new MyApp());
  });
}

Map<int, Color> primarySwatch = {
  50: Color(0xffe6f9ee),
  100: Color(0xffc0f0d4),
  200: Color(0xff97e6b8),
  300: Color(0xff6ddb9c),
  400: Color(0xff4dd486),
  500: Color(0xff2ecc71),
  600: Color(0xff29c769),
  700: Color(0xff23c05e),
  800: Color(0xff1db954),
  900: Color(0xff12ad42),
};
MaterialColor primaryColor =
    MaterialColor(primarySwatch[500].value, primarySwatch);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // fontFamily: "Yantramanav",
        primarySwatch: primaryColor,
        accentColor: Colors.redAccent,
      ),
      darkTheme: ThemeData(
        // fontFamily: "Yantramanav",
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        accentColor: Colors.redAccent,
      ),
      themeMode: ThemeMode.system,
      home: HomePage(title: 'Calendar'),
      debugShowCheckedModeBanner: false,
    );
  }
}
