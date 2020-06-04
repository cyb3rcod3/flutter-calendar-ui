import 'package:intl/intl.dart';

class DateUtils {
  static DateFormat get monthDayYear =>
      DateFormat.MMMd().addPattern(",").add_y();
  static DateFormat get hourMinute =>
      DateFormat.Hm();
}
