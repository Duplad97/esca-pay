import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/localized_date_labels.dart';
import '../../../shared/utils/money_format.dart';
import '../models/day_entry.dart';
import '../models/game_session.dart';
import 'stepper_row.dart';
import 'time_picker_row.dart';

class EditDaySheet extends StatefulWidget {
  const EditDaySheet({
    super.key,
    required this.day,
    required this.initialHours,
    required this.initialRooms,
    required this.initialSessions,
    required this.hourlyWage,
    required this.perRoomBonus,
    required this.jumpInRate,
  });

  final DateTime day;
  final double initialHours;
  final int initialRooms;
  final List<GameSession> initialSessions;
  final double hourlyWage;
  final double perRoomBonus;
  final double jumpInRate;

  @override
  State<EditDaySheet> createState() => _EditDaySheetState();
}

class _EditDaySheetState extends State<EditDaySheet> {
  late double _hours;
  late int _rooms;
  late List<GameSession> _sessions;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours;
    _rooms = widget.initialRooms;
    _sessions = widget.initialSessions.toList(growable: true);
    _startTime = const TimeOfDay(hour: 8, minute: 30);
    _endTime = const TimeOfDay(hour: 16, minute: 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateHoursFromTime() {
    if (_startTime != null && _endTime != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _hours = DayEntry.calculateHours(_startTime!, _endTime!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalSessionsCount = _sessions
        .where((s) => s.type == SessionType.normal)
        .length;
    final jumpInCount = _sessions
        .where((s) => s.type == SessionType.jumpIn)
        .length;
    final earnings =
        (_hours * widget.hourlyWage) +
        (_rooms * widget.perRoomBonus) +
        (jumpInCount * widget.jumpInRate);
    final roomsMismatch =
        normalSessionsCount > 0 && _rooms != normalSessionsCount;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    dayTitleShortL10n(context, widget.day),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  money(earnings),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TimePickerRow(
              title: l10n.startTimeTitle,
              subtitle: l10n.startTimeSubtitle,
              time: _startTime,
              isStartTime: true,
              onTimeChanged: (time) {
                setState(() => _startTime = time);
                _updateHoursFromTime();
              },
            ),
            const SizedBox(height: 10),
            TimePickerRow(
              title: l10n.endTimeTitle,
              subtitle: l10n.endTimeSubtitle,
              time: _endTime,
              isStartTime: false,
              onTimeChanged: (time) {
                setState(() => _endTime = time);
                _updateHoursFromTime();
              },
            ),
            if (_startTime != null && _endTime != null) ...<Widget>[
              const SizedBox(height: 10),
              _TimeCalculationHint(hours: _hours),
            ],
            const SizedBox(height: 18),
            StepperRow(
              title: l10n.roomsHostedTitle,
              subtitle: normalSessionsCount > 0
                  ? l10n.roomsHostedSubtitleWithSessions(normalSessionsCount)
                  : l10n.roomsHostedSubtitleNone,
              valueText: '$_rooms',
              onMinus: () {
                HapticFeedback.selectionClick();
                setState(() => _rooms = (_rooms - 1).clamp(0, 99));
              },
              onPlus: () {
                HapticFeedback.selectionClick();
                setState(() => _rooms = (_rooms + 1).clamp(0, 99));
              },
            ),
            if (roomsMismatch) ...<Widget>[
              const SizedBox(height: 8),
              _MismatchHint(rooms: _rooms, sessions: normalSessionsCount),
            ],
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(
                      const DayEntry(
                        hours: 0,
                        rooms: 0,
                        sessions: <GameSession>[],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.clear),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(
                      DayEntry(
                        hours: _hours,
                        rooms: _rooms,
                        sessions: _sessions,
                        startTime: _startTime,
                        endTime: _endTime,
                      ),
                    );
                  },
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MismatchHint extends StatelessWidget {
  const _MismatchHint({required this.rooms, required this.sessions});

  final int rooms;
  final int sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        color: cs.secondaryContainer.withValues(alpha: 0.55),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(Icons.info_outline, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.roomsSessionsMismatch(sessions, rooms),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCalculationHint extends StatelessWidget {
  const _TimeCalculationHint({required this.hours});

  final double hours;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        color: cs.tertiaryContainer.withValues(alpha: 0.55),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(Icons.check_circle_outline, color: cs.tertiary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.hoursCalculatedFromTime(hours.toStringAsFixed(1)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
