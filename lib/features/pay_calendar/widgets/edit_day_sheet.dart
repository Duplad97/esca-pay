import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/localized_date_labels.dart';
import '../../../shared/utils/money_format.dart';
import '../models/day_entry.dart';
import '../models/event.dart';
import '../models/game_session.dart';
import '../models/benefit.dart';
import '../models/deduction.dart';
import '../models/payment_profile.dart';
import 'stepper_row.dart';
import 'time_picker_row.dart';

class EditDaySheet extends StatefulWidget {
  const EditDaySheet({
    super.key,
    required this.day,
    required this.initialHours,
    required this.initialRooms,
    required this.initialSessions,
    required this.initialEvents,
    this.initialBenefits = const <Benefit>[],
    this.initialDeductions = const <Deduction>[],
    required this.hourlyWage,
    required this.perRoomBonus,
    required this.jumpInRate,
    required this.eventFine,
    this.initialStartTime,
    this.initialEndTime,
    this.availableProfiles = const <PaymentProfile>[],
    this.initialProfileId,
    this.defaultProfileId,
  });

  final DateTime day;
  final double initialHours;
  final int initialRooms;
  final List<GameSession> initialSessions;
  final List<Event> initialEvents;
  final List<Benefit> initialBenefits;
  final List<Deduction> initialDeductions;
  final double hourlyWage;
  final double perRoomBonus;
  final double jumpInRate;
  final double eventFine;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final List<PaymentProfile> availableProfiles;
  final String? initialProfileId;
  final String? defaultProfileId;

  @override
  State<EditDaySheet> createState() => _EditDaySheetState();
}

class _EditDaySheetState extends State<EditDaySheet> {
  late double _hours;
  late int _rooms;
  late List<GameSession> _sessions;
  late List<Event> _events;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late String? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours;
    _rooms = widget.initialRooms;
    _sessions = widget.initialSessions.toList(growable: true);
    _events = widget.initialEvents.toList(growable: true);
    _startTime =
        widget.initialStartTime ?? const TimeOfDay(hour: 8, minute: 30);
    _endTime = widget.initialEndTime ?? const TimeOfDay(hour: 16, minute: 0);
    // Use initialProfileId if set, otherwise use default profile ID
    _selectedProfileId = widget.initialProfileId ?? widget.defaultProfileId;
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

  Widget _buildProfileSelector() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    PaymentProfile? selectedProfile;
    if (_selectedProfileId != null) {
      for (final profile in widget.availableProfiles) {
        if (profile.id == _selectedProfileId) {
          selectedProfile = profile;
          break;
        }
      }
    }

    final displayName = selectedProfile?.name ?? l10n.selectProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.paymentProfile,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final menuWidth = constraints.maxWidth;
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String?>(
                position: PopupMenuPosition.under,
                constraints: BoxConstraints.tightFor(width: menuWidth),
                onOpened: () {
                  HapticFeedback.selectionClick();
                },
                onSelected: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedProfileId = value);
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String?>>[
                      for (final profile in widget.availableProfiles)
                        PopupMenuItem<String?>(
                          value: profile.id,
                          child: SizedBox(
                            width: menuWidth,
                            child: Text(profile.name),
                          ),
                        ),
                    ],
                child: SizedBox(
                  width: menuWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Icon(
                          Icons.expand_more,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionsCount = _sessions.length;
    final jumpInCount = _sessions
        .where((s) => s.type == SessionType.jumpIn)
        .length;
    double hourlyWage = widget.hourlyWage;
    double perRoomBonus = widget.perRoomBonus;
    double jumpInRate = widget.jumpInRate;
    double eventFine = widget.eventFine;

    if (_selectedProfileId != null) {
      for (final profile in widget.availableProfiles) {
        if (profile.id == _selectedProfileId) {
          hourlyWage = profile.hourlyWage;
          perRoomBonus = profile.perRoomBonus;
          jumpInRate = profile.jumpInRate;
          eventFine = profile.eventFine;
          break;
        }
      }
    }

    final earnings =
        (_hours * hourlyWage) +
        (_rooms * perRoomBonus) +
        (jumpInCount * jumpInRate) +
        (_events.length * eventFine);
    final roomsMismatch = sessionsCount > 0 && _rooms != sessionsCount;

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
            if (widget.availableProfiles.isNotEmpty) ...<Widget>[
              _buildProfileSelector(),
              const SizedBox(height: 14),
            ],
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
              title: l10n.events,
              subtitle: l10n.eventsToday(_events.length),
              valueText: '${_events.length}',
              onMinus: _events.isEmpty
                  ? () {}
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() => _events.removeAt(_events.length - 1));
                    },
              onPlus: () {
                HapticFeedback.selectionClick();
                setState(
                  () => _events.add(
                    Event(
                      start: const TimeOfDay(hour: 18, minute: 0),
                      end: const TimeOfDay(hour: 19, minute: 0),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            StepperRow(
              title: l10n.roomsHostedTitle,
              subtitle: sessionsCount > 0
                  ? l10n.roomsHostedSubtitleWithSessions(sessionsCount)
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
              _MismatchHint(rooms: _rooms, sessions: sessionsCount),
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
                        events: <Event>[],
                        benefits: <Benefit>[],
                        deductions: <Deduction>[],
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
                        events: _events,
                        benefits: widget.initialBenefits,
                        deductions: widget.initialDeductions,
                        startTime: _startTime,
                        endTime: _endTime,
                        profileId: _selectedProfileId,
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
