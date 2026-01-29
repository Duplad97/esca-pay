import 'package:hive/hive.dart';

import '../../features/pay_calendar/models/event.dart';
import '../../features/pay_calendar/models/game_session.dart';
import '../../features/pay_calendar/models/benefit.dart';

class StoredDayEntry {
  const StoredDayEntry({
    required this.hours,
    required this.rooms,
    required this.sessions,
    required this.events,
    required this.benefits,
  });

  final double hours;
  final int rooms;
  final List<GameSession> sessions;
  final List<Event> events;
  final List<Benefit> benefits;
}

class DayEntriesStorage {
  static const boxName = 'day_entries';

  Box<dynamic>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(boxName);
  }

  Map<String, StoredDayEntry> loadAll() {
    final box = _box;
    if (box == null) return <String, StoredDayEntry>{};

    final result = <String, StoredDayEntry>{};
    for (final dynamic k in box.keys) {
      if (k is! String) continue;
      final v = box.get(k);
      if (v is! Map) continue;

      final hoursRaw = v['hours'];
      final roomsRaw = v['rooms'];
      if (hoursRaw is! num || roomsRaw is! num) continue;

      final hours = hoursRaw.toDouble();
      final rooms = roomsRaw.toInt();
      final sessions = _parseSessions(v['sessions']);
      final events = _parseEvents(v['events']);
      final benefits = _parseBenefits(v['benefits']);
      if (hours <= 0 &&
          rooms <= 0 &&
          sessions.isEmpty &&
          events.isEmpty &&
          benefits.isEmpty) {
        continue;
      }

      result[k] = StoredDayEntry(
        hours: hours,
        rooms: rooms,
        sessions: sessions,
        events: events,
        benefits: benefits,
      );
    }
    return result;
  }

  Future<void> setEntry({
    required String dayKey,
    required double hours,
    required int rooms,
    required List<GameSession> sessions,
    required List<Event> events,
    required List<Benefit> benefits,
    String? startTime,
    String? endTime,
  }) async {
    final data = <String, dynamic>{
      'hours': hours,
      'rooms': rooms,
      'sessions': sessions.map((s) => s.toJson()).toList(growable: false),
      'events': events.map((e) => e.toJson()).toList(growable: false),
      'benefits': benefits.map((b) => b.toJson()).toList(growable: false),
    };
    if (startTime != null) data['startTime'] = startTime;
    if (endTime != null) data['endTime'] = endTime;
    await _box?.put(dayKey, data);
  }

  Future<void> deleteEntry(String dayKey) async {
    await _box?.delete(dayKey);
  }

  Future<void> clearAll() async {
    await _box?.clear();
  }

  List<GameSession> _parseSessions(dynamic raw) {
    if (raw is! List) return const <GameSession>[];
    final sessions = <GameSession>[];
    for (final item in raw) {
      final s = GameSession.fromJson(item);
      if (s != null) sessions.add(s);
    }
    return sessions;
  }

  List<Event> _parseEvents(dynamic raw) {
    if (raw is! List) return const <Event>[];
    final events = <Event>[];
    for (final item in raw) {
      final e = Event.fromJson(item);
      if (e != null) events.add(e);
    }
    return events;
  }

  List<Benefit> _parseBenefits(dynamic raw) {
    if (raw is! List) return const <Benefit>[];
    final benefits = <Benefit>[];
    for (final item in raw) {
      final b = Benefit.fromJson(item);
      if (b != null) benefits.add(b);
    }
    return benefits;
  }
}
