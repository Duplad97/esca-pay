import 'package:flutter/material.dart';

import '../../shared/utils/date_time_utils.dart';
import '../../shared/storage/storage.dart';
import 'models/day_entry.dart';
import 'models/game_session.dart';
import 'models/rates.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/edit_day_sheet.dart';
import 'widgets/edit_sessions_sheet.dart';
import 'widgets/rates_sheet.dart';
import 'widgets/summary_card.dart';
import 'widgets/selected_day_header.dart';
import 'widgets/top_bar.dart';

class PayCalendarPage extends StatefulWidget {
  const PayCalendarPage({super.key});

  @override
  State<PayCalendarPage> createState() => _PayCalendarPageState();
}

class _PayCalendarPageState extends State<PayCalendarPage> {
  DateTime _visibleMonth = dateOnly(DateTime.now());
  DateTime _selectedDay = dateOnly(DateTime.now());

  double _hourlyWage = 1600.0;
  double _perRoomBonus = 600.0;

  final Map<String, DayEntry> _entriesByDayKey = <String, DayEntry>{};

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    _loadSavedRates();
    _loadSavedDayEntries();
  }

  void _loadSavedRates() {
    final savedHourly = settingsStorage.getHourlyWage();
    final savedPerRoom = settingsStorage.getPerRoomBonus();
    if (savedHourly == null && savedPerRoom == null) return;
    setState(() {
      if (savedHourly != null) _hourlyWage = savedHourly;
      if (savedPerRoom != null) _perRoomBonus = savedPerRoom;
    });
  }

  void _loadSavedDayEntries() {
    final stored = dayEntriesStorage.loadAll();
    if (stored.isEmpty) return;
    setState(() {
      for (final entry in stored.entries) {
        _entriesByDayKey[entry.key] = DayEntry(
          hours: entry.value.hours,
          rooms: entry.value.rooms,
          sessions: entry.value.sessions,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFFFF0F7),
              Color(0xFFF2F3FF),
              Color(0xFFEFFFFA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              TopBar(
                month: _visibleMonth,
                onPrevMonth: () => setState(() {
                  _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
                }),
                onNextMonth: () => setState(() {
                  _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
                }),
                onRates: () => _openRatesSheet(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: SummaryRow(
                  weekLabel: weekRangeLabel(_selectedDay),
                  weekTotal: _earningsForWeekContaining(_selectedDay),
                  monthLabel: monthTitle(_visibleMonth),
                  monthTotal: _earningsForMonth(_visibleMonth),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: SelectedDayHeader(
                  selectedDay: _selectedDay,
                  entry: _entryForDay(_selectedDay),
                  dayTotal: _earningsForDay(_selectedDay),
                  onPrevDay: () => _selectDay(_selectedDay.subtract(const Duration(days: 1))),
                  onNextDay: () => _selectDay(_selectedDay.add(const Duration(days: 1))),
                  onEditSessions: () => _openSessionsSheet(context, _selectedDay),
                  onEditDay: () => _openEditSheet(context, _selectedDay, colorScheme),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CalendarGrid(
                    month: _visibleMonth,
                    selectedDay: _selectedDay,
                    hasEntryForDay: (DateTime day) => _hasEntryForDay(day),
                    onSelectDay: (DateTime day) => _selectDay(day),
                    onEditDay: (DateTime day) {
                      _selectDay(day);
                      _openEditSheet(context, day, colorScheme);
                    },
                    onToday: () => _selectDay(DateTime.now()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDay(DateTime day) {
    final d = dateOnly(day);
    setState(() {
      _selectedDay = d;
      if (_visibleMonth.year != d.year || _visibleMonth.month != d.month) {
        _visibleMonth = DateTime(d.year, d.month, 1);
      }
    });
  }

  double _earningsForDay(DateTime day) {
    final entry = _entriesByDayKey[dayKey(day)];
    if (entry == null) return 0;
    return entry.earnings(hourlyWage: _hourlyWage, perRoomBonus: _perRoomBonus);
  }

  DayEntry? _entryForDay(DateTime day) => _entriesByDayKey[dayKey(day)];

  bool _hasEntryForDay(DateTime day) => _entriesByDayKey.containsKey(dayKey(day));

  double _earningsForWeekContaining(DateTime day) {
    final start = startOfWeek(day);
    double total = 0;
    for (var i = 0; i < 7; i++) {
      total += _earningsForDay(start.add(Duration(days: i)));
    }
    return total;
  }

  double _earningsForMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final count = daysInMonth(first);
    double total = 0;
    for (var i = 0; i < count; i++) {
      total += _earningsForDay(first.add(Duration(days: i)));
    }
    return total;
  }

  Future<void> _openEditSheet(BuildContext context, DateTime day, ColorScheme colorScheme) async {
    final key = dayKey(day);
    final existing = _entriesByDayKey[key];
    final result = await showModalBottomSheet<DayEntry?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return EditDaySheet(
          day: day,
          initialHours: existing?.hours ?? 0,
          initialRooms: existing?.rooms ?? 0,
          initialSessions: existing?.sessions ?? const [],
          hourlyWage: _hourlyWage,
          perRoomBonus: _perRoomBonus,
        );
      },
    );

    if (!mounted || result == null) return;

    if (result.isEmpty) {
      setState(() {
        _entriesByDayKey.remove(key);
      });
      await dayEntriesStorage.deleteEntry(key);
      return;
    }

    setState(() {
      _entriesByDayKey[key] = result;
    });
    await dayEntriesStorage.setEntry(
      dayKey: key,
      hours: result.hours,
      rooms: result.rooms,
      sessions: result.sessions,
    );
  }

  Future<void> _openSessionsSheet(BuildContext context, DateTime day) async {
    final key = dayKey(day);
    final existing = _entriesByDayKey[key];
    final initial = existing?.sessions ?? const <GameSession>[];

    void persistSessions(List<GameSession> sessions) async {
      final current = _entriesByDayKey[key];
      final prevRooms = current?.rooms ?? 0;
      final prevSessionsCount = current?.sessions.length ?? 0;
      final userCustomizedRooms = current != null && prevRooms != prevSessionsCount;
      final nextRooms = userCustomizedRooms ? prevRooms : sessions.length;
      final nextHours = current?.hours ?? 0;

      final nextEntry = DayEntry(hours: nextHours, rooms: nextRooms, sessions: sessions);

      if (!mounted) return;
      if (nextEntry.isEmpty) {
        setState(() {
          _entriesByDayKey.remove(key);
        });
        await dayEntriesStorage.deleteEntry(key);
        return;
      }

      setState(() {
        _entriesByDayKey[key] = nextEntry;
      });
      await dayEntriesStorage.setEntry(
        dayKey: key,
        hours: nextEntry.hours,
        rooms: nextEntry.rooms,
        sessions: nextEntry.sessions,
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return EditSessionsSheet(
          initialSessions: initial,
          onSessionsChanged: persistSessions,
        );
      },
    );
  }

  Future<void> _openRatesSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return RatesSheet(
          initialHourlyWage: _hourlyWage,
          initialPerRoomBonus: _perRoomBonus,
        );
      },
    );

    if (!context.mounted) return;
    if (result is! Rates) return;
    setState(() {
      _hourlyWage = result.hourlyWage;
      _perRoomBonus = result.perRoomBonus;
    });
    await settingsStorage.setHourlyWage(_hourlyWage);
    await settingsStorage.setPerRoomBonus(_perRoomBonus);
  }
}
