import 'package:flutter/material.dart';

import 'date_time_utils.dart';

String monthTitleL10n(BuildContext context, DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  return MaterialLocalizations.of(context).formatMonthYear(first);
}

String selectedDayLabelL10n(BuildContext context, DateTime day) {
  return MaterialLocalizations.of(context).formatFullDate(dateOnly(day));
}

String dayTitleShortL10n(BuildContext context, DateTime day) {
  return MaterialLocalizations.of(context).formatShortMonthDay(dateOnly(day));
}

String weekRangeLabelL10n(
  BuildContext context,
  DateTime anyDayInWeek,
  int weekStartWeekday,
) {
  final start = startOfWeekWith(anyDayInWeek, weekStartWeekday);
  final end = start.add(const Duration(days: 6));

  final l = MaterialLocalizations.of(context);
  final startText = l.formatShortMonthDay(start);
  final endText = l.formatShortMonthDay(end);

  if (start.year == end.year) {
    return '$startText–$endText ${start.year}';
  }
  return '$startText ${start.year}–$endText ${end.year}';
}
