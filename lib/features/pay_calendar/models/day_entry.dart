import 'package:flutter/material.dart' show TimeOfDay;

import 'game_session.dart';

class DayEntry {
  const DayEntry({
    required this.hours,
    required this.rooms,
    this.sessions = const <GameSession>[],
    this.startTime,
    this.endTime,
  });

  final double hours;
  final int rooms;
  final List<GameSession> sessions;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  bool get isEmpty => hours <= 0 && rooms <= 0 && sessions.isEmpty;

  bool get hasTimeTracking => startTime != null && endTime != null;

  /// Calculate hours from start and end time
  static double calculateHours(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    // Handle case where shift spans midnight
    final totalMinutes = endMinutes >= startMinutes
        ? endMinutes - startMinutes
        : (24 * 60) - startMinutes + endMinutes;

    return totalMinutes / 60.0;
  }

  double earnings({
    required double hourlyWage,
    required double perRoomBonus,
    required double jumpInRate,
  }) {
    final jumpInCount = sessions
        .where((s) => s.type == SessionType.jumpIn)
        .length;
    return (hours * hourlyWage) +
        (rooms * perRoomBonus) +
        (jumpInCount * jumpInRate);
  }
}
