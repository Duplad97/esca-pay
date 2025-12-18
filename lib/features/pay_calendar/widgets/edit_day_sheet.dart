import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/date_time_utils.dart';
import '../../../shared/utils/money_format.dart';
import '../models/day_entry.dart';
import '../models/game_session.dart';
import 'stepper_row.dart';

class EditDaySheet extends StatefulWidget {
  const EditDaySheet({
    super.key,
    required this.day,
    required this.initialHours,
    required this.initialRooms,
    required this.initialSessions,
    required this.hourlyWage,
    required this.perRoomBonus,
  });

  final DateTime day;
  final double initialHours;
  final int initialRooms;
  final List<GameSession> initialSessions;
  final double hourlyWage;
  final double perRoomBonus;

  @override
  State<EditDaySheet> createState() => _EditDaySheetState();
}

class _EditDaySheetState extends State<EditDaySheet> {
  late double _hours;
  late int _rooms;
  late List<GameSession> _sessions;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours;
    _rooms = widget.initialRooms;
    _sessions = widget.initialSessions.toList(growable: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earnings = (_hours * widget.hourlyWage) + (_rooms * widget.perRoomBonus);
    final sessionsCount = _sessions.length;
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
                    '${monthTitle(widget.day)} ${widget.day.day}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Text(
                  money(earnings),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            StepperRow(
              title: 'Hours worked',
              subtitle: 'hours survived (respectfully)',
              valueText: _hours.toStringAsFixed(1),
              onMinus: () {
                HapticFeedback.selectionClick();
                setState(() => _hours = (_hours - 0.5).clamp(0, 24));
              },
              onPlus: () {
                HapticFeedback.selectionClick();
                setState(() => _hours = (_hours + 0.5).clamp(0, 24));
              },
            ),
            const SizedBox(height: 10),
            StepperRow(
              title: 'Rooms hosted',
              subtitle:
                  sessionsCount > 0 ? 'sessions saved: $sessionsCount' : 'rooms ran today',
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
                      const DayEntry(hours: 0, rooms: 0, sessions: <GameSession>[]),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(
                      DayEntry(hours: _hours, rooms: _rooms, sessions: _sessions),
                    );
                  },
                  child: const Text('Save'),
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
                'Heads up: sessions ($sessions) ≠ rooms hosted ($rooms).',
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
