import 'package:hive/hive.dart';

import '../../features/pay_calendar/models/game_session.dart';

class StoredDayEntry {
  const StoredDayEntry({
    required this.hours,
    required this.rooms,
    required this.sessions,
  });

  final double hours;
  final int rooms;
  final List<GameSession> sessions;
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
      if (hours <= 0 && rooms <= 0 && sessions.isEmpty) continue;

      result[k] = StoredDayEntry(hours: hours, rooms: rooms, sessions: sessions);
    }
    return result;
  }

  Future<void> setEntry({
    required String dayKey,
    required double hours,
    required int rooms,
    required List<GameSession> sessions,
  }) async {
    await _box?.put(dayKey, <String, dynamic>{
      'hours': hours,
      'rooms': rooms,
      'sessions': sessions.map((s) => s.toJson()).toList(growable: false),
    });
  }

  Future<void> deleteEntry(String dayKey) async {
    await _box?.delete(dayKey);
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
}
