DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

DateTime addCalendarDays(DateTime day, int days) {
  final d = dateOnly(day);
  return DateTime(d.year, d.month, d.day + days);
}

String shortWeekday(DateTime dt) {
  const names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[dt.weekday - 1];
}

String shortMonthName(DateTime dt) {
  const names = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[dt.month - 1];
}

String selectedDayLabel(DateTime dt) {
  final d = dateOnly(dt);
  return '${shortWeekday(d)}, ${d.day} ${shortMonthName(d)} ${d.year}';
}

String weekRangeLabel(DateTime anyDayInWeek) {
  return weekRangeLabelWith(anyDayInWeek, DateTime.monday);
}

String weekRangeLabelWith(DateTime anyDayInWeek, int weekStartWeekday) {
  final start = startOfWeekWith(anyDayInWeek, weekStartWeekday);
  final end = addCalendarDays(start, 6);
  final startText = '${shortMonthName(start)} ${start.day}';
  final endText = '${shortMonthName(end)} ${end.day}';

  if (start.year == end.year && start.month == end.month) {
    return '${shortMonthName(start)} ${start.day}–${end.day} ${start.year}';
  }
  if (start.year == end.year) {
    return '$startText–$endText ${start.year}';
  }
  return '$startText ${start.year}–$endText ${end.year}';
}

String dayKey(DateTime dt) {
  final d = dateOnly(dt);
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

DateTime startOfWeek(DateTime day) {
  return startOfWeekWith(day, DateTime.monday);
}

DateTime startOfWeekWith(DateTime day, int weekStartWeekday) {
  final d = dateOnly(day);
  final start = weekStartWeekday.clamp(DateTime.monday, DateTime.sunday);
  final delta = (d.weekday - start + 7) % 7;
  return addCalendarDays(d, -delta);
}

int daysInMonth(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  return DateTime(first.year, first.month + 1, 0).day;
}

String monthTitle(DateTime month) {
  const names = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${names[month.month - 1]} ${month.year}';
}
