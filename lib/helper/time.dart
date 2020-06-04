class TimeHelper {
  static String toDurationText(int hour, int minute) {
    List<String> strings = List();
    if (hour > 0) {
      strings.add("$hour hrs");
    }
    if (minute > 0 || hour == 0) {
      strings.add("$minute min");
    }
    return strings.join(", ");
  }

  static String toDurationTextByDuration(Duration duration) {
    int hour = (duration.inMinutes / 60).floor();
    int minute = duration.inMinutes % 60;
    return toDurationText(hour, minute);
  }

  static String toText(int hour, int minute) {
    return "${twoDigit(hour)}:${twoDigit(minute)}";
  }

  static String twoDigit(int digit) {
    if (digit < 10) {
      return "0$digit";
    } else
      return "$digit";
  }
}
