import 'package:flutter/material.dart';

class Event {
  const Event({required this.start, required this.end});

  final TimeOfDay start;
  final TimeOfDay end;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'start': _fmt(start),
    'end': _fmt(end),
  };

  static Event? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final startRaw = raw['start'];
    final endRaw = raw['end'];
    if (startRaw is! String || endRaw is! String) return null;
    final start = _parse(startRaw);
    final end = _parse(endRaw);
    if (start == null || end == null) return null;
    return Event(start: start, end: end);
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? _parse(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
