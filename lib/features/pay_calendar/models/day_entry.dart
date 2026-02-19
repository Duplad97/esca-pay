import 'package:flutter/material.dart' show TimeOfDay;

import 'event.dart';
import 'game_session.dart';
import 'benefit.dart';
import 'deduction.dart';

class DayEntry {
  const DayEntry({
    required this.hours,
    required this.rooms,
    this.sessions = const <GameSession>[],
    this.events = const <Event>[],
    this.benefits = const <Benefit>[],
    this.deductions = const <Deduction>[],
    this.startTime,
    this.endTime,
    this.profileId,
  });

  final double hours;
  final int rooms;
  final List<GameSession> sessions;
  final List<Event> events;
  final List<Benefit> benefits;
  final List<Deduction> deductions;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? profileId;

  bool get isEmpty =>
      hours <= 0 &&
      rooms <= 0 &&
      sessions.isEmpty &&
      events.isEmpty &&
      benefits.isEmpty &&
      deductions.isEmpty;

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
    required double eventFine,
  }) {
    final normalSessionsCount = sessions
        .where((s) => s.type == SessionType.normal)
        .length;
    final jumpInCount = sessions
        .where((s) => s.type == SessionType.jumpIn)
        .length;
    final benefitsTotal = benefits.fold<double>(
      0.0,
      (sum, benefit) => sum + benefit.amount,
    );
    final deductionsTotal = deductions.fold<double>(
      0.0,
      (sum, deduction) => sum + deduction.amount,
    );
    return (hours * hourlyWage) +
        (normalSessionsCount * perRoomBonus) +
        (jumpInCount * jumpInRate) +
        (events.length * eventFine) +
        benefitsTotal -
        deductionsTotal;
  }
}
