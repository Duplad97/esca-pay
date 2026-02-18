import 'package:esca_pay/features/theme_selector/theme_selector_page.dart';
import 'package:esca_pay/shared/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../app/app_settings_controller.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/storage/storage.dart';
import '../../shared/utils/date_time_utils.dart';
import '../../shared/utils/localized_date_labels.dart';
import '../dev/debug_log_screen.dart';
import 'models/day_entry.dart';
import 'models/event.dart';
import 'models/game_session.dart';
import 'models/benefit.dart';
import 'models/payment_profile.dart';
import 'models/rates.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/edit_day_sheet.dart';
import 'widgets/edit_events_sheet.dart';
import 'widgets/edit_benefits_sheet.dart';
import 'widgets/edit_sessions_sheet.dart';
import 'widgets/rates_sheet.dart';
import 'widgets/selected_day_header.dart';
import 'widgets/selected_days_summary_sheet.dart';
import 'widgets/summary_card.dart';
import 'widgets/top_bar.dart';
import 'widgets/weekly_summary_checkbox.dart';

class PayCalendarPage extends StatefulWidget {
  const PayCalendarPage({super.key});

  @override
  State<PayCalendarPage> createState() => _PayCalendarPageState();
}

class _PayCalendarPageState extends State<PayCalendarPage> {
  DateTime _visibleMonth = dateOnly(DateTime.now());
  DateTime _selectedDay = dateOnly(DateTime.now());
  bool _multiSelectEnabled = false;
  final Set<String> _multiSelectedDayKeys = <String>{};

  double _hourlyWage = 1600.0;
  double _perRoomBonus = 600.0;
  double _jumpInRate = 2300.0;
  double _eventFine = 5000.0;
  int _weekStartWeekday = DateTime.monday;
  String? _localeCode;
  List<PaymentProfile> _paymentProfiles = <PaymentProfile>[];
  String? _defaultProfileId;

  bool _scheduledReminder = false;
  final bool _forceShowReminderCheckbox = false;
  int _debugTapCount = 0;

  final Map<String, DayEntry> _entriesByDayKey = <String, DayEntry>{};

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    _loadSavedRates();
    _loadPaymentProfiles();
    _loadSavedDayEntries();

    // Check if confirmation has expired (from previous day) and reset if needed
    if (NotificationService().isConfirmationExpired()) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationService().resetWeeklyConfirmation();
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_scheduledReminder) {
      final l10n = AppLocalizations.of(context)!;
      NotificationService().scheduleWeeklyPaymentSummaryReminder(
        weekStartWeekday: _weekStartWeekday,
        title: l10n.weeklyPaymentSummaryTitle,
        body: l10n.weeklyPaymentSummaryBody,
      );
      _scheduledReminder = true;
    }
  }

  void _loadSavedRates() {
    final savedHourly = settingsStorage.getHourlyWage();
    final savedPerRoom = settingsStorage.getPerRoomBonus();
    final savedJumpIn = settingsStorage.getJumpInRate();
    final savedEventFine = settingsStorage.getEventFine();
    final savedWeekStart = settingsStorage.getWeekStartWeekday();
    final savedLocaleCode = settingsStorage.getLocaleCode();
    if (savedHourly == null &&
        savedPerRoom == null &&
        savedJumpIn == null &&
        savedEventFine == null &&
        savedWeekStart == null &&
        savedLocaleCode == null) {
      return;
    }
    setState(() {
      if (savedHourly != null) _hourlyWage = savedHourly;
      if (savedPerRoom != null) _perRoomBonus = savedPerRoom;
      if (savedJumpIn != null) _jumpInRate = savedJumpIn;
      if (savedEventFine != null) _eventFine = savedEventFine;
      if (savedWeekStart != null) _weekStartWeekday = savedWeekStart;
      _localeCode = savedLocaleCode;
    });
  }

  void _loadPaymentProfiles() {
    final profiles = paymentProfilesStorage.loadAll();

    // Load default profile ID asynchronously
    paymentProfilesStorage.getDefaultProfileId().then((defaultId) {
      if (mounted) {
        setState(() {
          _defaultProfileId = defaultId;
        });
      }
    });

    setState(() {
      _paymentProfiles = profiles;
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
          events: entry.value.events,
          benefits: entry.value.benefits,
          profileId: entry.value.profileId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(gradient: themeManager.currentTheme.gradient),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              TopBar(
                month: _visibleMonth,
                onPrevMonth: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                    1,
                  );
                }),
                onNextMonth: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                    1,
                  );
                }),
                onRates: () => _openRatesSheet(context),
                onTheme: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ThemeSelectorPage(),
                    ),
                  );
                },
                onMonthTap: () {
                  // Hidden debug logs access: tap 3 times on the month
                  _debugTapCount++;
                  if (_debugTapCount >= 3) {
                    _debugTapCount = 0;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DebugLogScreen(),
                      ),
                    );
                  }
                },
              ),
              WeeklySummaryCheckbox(
                weekStartWeekday: _weekStartWeekday,
                forceShow: _forceShowReminderCheckbox,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> anim) {
                  return SizeTransition(
                    sizeFactor: anim,
                    axisAlignment: -1,
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: _multiSelectEnabled
                    ? const SizedBox.shrink(key: ValueKey('selection_mode_on'))
                    : Column(
                        key: const ValueKey('selection_mode_off'),
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: SummaryRow(
                              weekLabel: weekRangeLabelL10n(
                                context,
                                _selectedDay,
                                _weekStartWeekday,
                              ),
                              weekTotal: _earningsForWeekContaining(
                                _selectedDay,
                              ),
                              monthLabel: monthTitleL10n(
                                context,
                                _visibleMonth,
                              ),
                              monthTotal: _earningsForMonth(_visibleMonth),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: SelectedDayHeader(
                              selectedDay: _selectedDay,
                              entry: _entryForDay(_selectedDay),
                              dayTotal: _earningsForDay(_selectedDay),
                              onPrevDay: () => _selectDay(
                                _selectedDay.subtract(const Duration(days: 1)),
                              ),
                              onNextDay: () => _selectDay(
                                _selectedDay.add(const Duration(days: 1)),
                              ),
                              onEditSessions: () =>
                                  _openSessionsSheet(context, _selectedDay),
                              onEditEvents: () =>
                                  _openEventsSheet(context, _selectedDay),
                              onEditBenefits: () =>
                                  _openBenefitsSheet(context, _selectedDay),
                              onEditDay: () => _openEditSheet(
                                context,
                                _selectedDay,
                                colorScheme,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CalendarGrid(
                    month: _visibleMonth,
                    selectedDay: _selectedDay,
                    hasEntryForDay: (DateTime day) => _hasEntryForDay(day),
                    isDayMultiSelected: (DateTime day) =>
                        _multiSelectedDayKeys.contains(dayKey(day)),
                    onSelectDay: (DateTime day) {
                      if (_multiSelectEnabled) {
                        _toggleMultiSelectedDay(day);
                      } else {
                        _selectDay(day);
                      }
                    },
                    onDragSelectDay: (DateTime day) =>
                        _addMultiSelectedDay(day),
                    onEditDay: (DateTime day) {
                      _selectDay(day);
                      _openEditSheet(context, day, colorScheme);
                    },
                    onToday: () => _selectDay(DateTime.now()),
                    multiSelectEnabled: _multiSelectEnabled,
                    onToggleMultiSelect: _toggleMultiSelect,
                    multiSelectedCount: _multiSelectedDayKeys.length,
                    onClearMultiSelect: () =>
                        setState(_multiSelectedDayKeys.clear),
                    onShowMultiSelectSummary: () =>
                        _openSelectedDaysSummary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleMultiSelect() {
    setState(() {
      _multiSelectEnabled = !_multiSelectEnabled;
      _multiSelectedDayKeys.clear();
      if (_multiSelectEnabled) {
        _multiSelectedDayKeys.add(dayKey(_selectedDay));
      }
    });
  }

  void _setSelectedDayInState(DateTime day) {
    final d = dateOnly(day);
    _selectedDay = d;
    if (_visibleMonth.year != d.year || _visibleMonth.month != d.month) {
      _visibleMonth = DateTime(d.year, d.month, 1);
    }
  }

  void _toggleMultiSelectedDay(DateTime day) {
    final d = dateOnly(day);
    final key = dayKey(d);
    setState(() {
      if (_multiSelectedDayKeys.contains(key)) {
        if (_multiSelectedDayKeys.length == 1) {
          _setSelectedDayInState(d);
          return;
        }

        _multiSelectedDayKeys.remove(key);

        if (dayKey(_selectedDay) == key) {
          _setSelectedDayInState(DateTime.parse(_multiSelectedDayKeys.last));
        }
      } else {
        _multiSelectedDayKeys.add(key);
        _setSelectedDayInState(d);
      }
    });
  }

  void _addMultiSelectedDay(DateTime day) {
    if (!_multiSelectEnabled) return;
    final d = dateOnly(day);
    final key = dayKey(d);
    setState(() {
      _multiSelectedDayKeys.add(key);
      _setSelectedDayInState(d);
    });
  }

  Future<void> _openSelectedDaysSummary(BuildContext context) async {
    if (_multiSelectedDayKeys.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectAtLeastOneDay)));
      return;
    }
    final days = _multiSelectedDayKeys
        .map(DateTime.parse)
        .toList(growable: false);

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
        return SelectedDaysSummarySheet(
          selectedDays: days,
          entryForDay: _entryForDay,
          ratesForEntry: _ratesForEntry,
        );
      },
    );
  }

  void _selectDay(DateTime day) {
    setState(() {
      _setSelectedDayInState(day);
    });
  }

  Rates _ratesForEntry(DayEntry entry) {
    double hourlyWage = _hourlyWage;
    double perRoomBonus = _perRoomBonus;
    double jumpInRate = _jumpInRate;
    double eventFine = _eventFine;

    if (entry.profileId != null) {
      final profile = paymentProfilesStorage.getProfile(entry.profileId!);
      if (profile != null) {
        hourlyWage = profile.hourlyWage;
        perRoomBonus = profile.perRoomBonus;
        jumpInRate = profile.jumpInRate;
        eventFine = profile.eventFine;
      }
    }

    return Rates(
      hourlyWage: hourlyWage,
      perRoomBonus: perRoomBonus,
      jumpInRate: jumpInRate,
      eventFine: eventFine,
      weekStartWeekday: _weekStartWeekday,
      localeCode: _localeCode,
    );
  }

  double _earningsForDay(DateTime day) {
    final entry = _entriesByDayKey[dayKey(day)];
    if (entry == null) return 0;

    final rates = _ratesForEntry(entry);
    return entry.earnings(
      hourlyWage: rates.hourlyWage,
      perRoomBonus: rates.perRoomBonus,
      jumpInRate: rates.jumpInRate,
      eventFine: rates.eventFine,
    );
  }

  DayEntry? _entryForDay(DateTime day) => _entriesByDayKey[dayKey(day)];

  bool _hasEntryForDay(DateTime day) =>
      _entriesByDayKey.containsKey(dayKey(day));

  double _earningsForWeekContaining(DateTime day) {
    final start = startOfWeekWith(day, _weekStartWeekday);
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

  Future<void> _openEditSheet(
    BuildContext context,
    DateTime day,
    ColorScheme colorScheme,
  ) async {
    final latestProfiles = paymentProfilesStorage.loadAll();
    final latestDefaultProfileId = await paymentProfilesStorage
        .getDefaultProfileId();
    if (mounted) {
      setState(() {
        _paymentProfiles = latestProfiles;
        _defaultProfileId = latestDefaultProfileId;
      });
    }

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
          initialEvents: existing?.events ?? const [],
          hourlyWage: _hourlyWage,
          perRoomBonus: _perRoomBonus,
          jumpInRate: _jumpInRate,
          eventFine: _eventFine,
          initialStartTime: existing?.startTime,
          initialEndTime: existing?.endTime,
          availableProfiles: _paymentProfiles,
          initialProfileId: existing?.profileId,
          defaultProfileId: _defaultProfileId,
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
      events: result.events,
      benefits: result.benefits,
      profileId: result.profileId,
    );
  }

  Future<void> _openSessionsSheet(BuildContext context, DateTime day) async {
    final key = dayKey(day);
    final existing = _entriesByDayKey[key];
    final initial = existing?.sessions ?? const <GameSession>[];

    void persistSessions(List<GameSession> sessions) async {
      final current = _entriesByDayKey[key];
      final prevRooms = current?.rooms ?? 0;
      final prevNormalSessionsCount = current?.sessions
          .where((s) => s.type == SessionType.normal)
          .length;
      final userCustomizedRooms =
          current != null && prevRooms != prevNormalSessionsCount;
      final normalSessionsCount = sessions
          .where((s) => s.type == SessionType.normal)
          .length;
      final nextRooms = userCustomizedRooms ? prevRooms : normalSessionsCount;
      final nextHours = current?.hours ?? 0;

      final nextEntry = DayEntry(
        hours: nextHours,
        rooms: nextRooms,
        sessions: sessions,
        events: current?.events ?? const [],
        benefits: current?.benefits ?? const [],
        startTime: current?.startTime,
        endTime: current?.endTime,
        profileId: current?.profileId,
      );

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
        events: nextEntry.events,
        benefits: nextEntry.benefits,
        profileId: nextEntry.profileId,
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

  Future<void> _openEventsSheet(BuildContext context, DateTime day) async {
    final key = dayKey(day);
    final existing = _entriesByDayKey[key];
    final initial = existing?.events ?? const <Event>[];

    void persistEvents(List<Event> events) async {
      final current = _entriesByDayKey[key];
      final nextEntry = DayEntry(
        hours: current?.hours ?? 0,
        rooms: current?.rooms ?? 0,
        sessions: current?.sessions ?? const [],
        events: events,
        benefits: current?.benefits ?? const [],
        startTime: current?.startTime,
        endTime: current?.endTime,
        profileId: current?.profileId,
      );

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
        events: nextEntry.events,
        benefits: nextEntry.benefits,
        profileId: nextEntry.profileId,
      );
    }

    await showModalBottomSheet<List<Event>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return EditEventsSheet(initialEvents: initial, eventFine: _eventFine);
      },
    ).then((value) {
      if (value == null) return;
      persistEvents(value);
    });
  }

  Future<void> _openBenefitsSheet(BuildContext context, DateTime day) async {
    final key = dayKey(day);
    final existing = _entriesByDayKey[key];
    final initial = existing?.benefits ?? const <Benefit>[];

    void persistBenefits(List<Benefit> benefits) async {
      final current = _entriesByDayKey[key];
      final nextEntry = DayEntry(
        hours: current?.hours ?? 0,
        rooms: current?.rooms ?? 0,
        sessions: current?.sessions ?? const [],
        events: current?.events ?? const [],
        benefits: benefits,
        startTime: current?.startTime,
        endTime: current?.endTime,
        profileId: current?.profileId,
      );

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
        events: nextEntry.events,
        benefits: nextEntry.benefits,
        profileId: nextEntry.profileId,
      );
    }

    await showModalBottomSheet<List<Benefit>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return EditBenefitsSheet(initialBenefits: initial);
      },
    ).then((value) {
      if (value == null) return;
      persistBenefits(value);
    });
  }

  Future<void> _openRatesSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
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
          initialJumpInRate: _jumpInRate,
          initialEventFine: _eventFine,
          initialWeekStartWeekday: _weekStartWeekday,
          initialLocaleCode: _localeCode,
          storage: dayEntriesStorage,
          paymentProfilesStorage: paymentProfilesStorage,
        );
      },
    );

    if (!context.mounted) return;

    // Check if we need to reload data (import might have happened)
    _entriesByDayKey.clear();
    _loadSavedDayEntries();

    if (result is! Rates) return;
    setState(() {
      _hourlyWage = result.hourlyWage;
      _perRoomBonus = result.perRoomBonus;
      _jumpInRate = result.jumpInRate;
      _eventFine = result.eventFine;
      _weekStartWeekday = result.weekStartWeekday;
      _localeCode = result.localeCode;
    });
    await settingsStorage.setHourlyWage(_hourlyWage);
    await settingsStorage.setPerRoomBonus(_perRoomBonus);
    await settingsStorage.setJumpInRate(_jumpInRate);
    await settingsStorage.setEventFine(_eventFine);
    await settingsStorage.setWeekStartWeekday(_weekStartWeekday);
    await appSettingsController.setLocaleCode(_localeCode);

    // Reschedule weekly reminder if week start changed (or always refresh to be safe)
    await NotificationService().scheduleWeeklyPaymentSummaryReminder(
      weekStartWeekday: _weekStartWeekday,
      title: l10n.weeklyPaymentSummaryTitle,
      body: l10n.weeklyPaymentSummaryBody,
    );
  }
}
