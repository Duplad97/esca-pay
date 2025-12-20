import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/date_time_utils.dart';
import '../../../shared/utils/localized_date_labels.dart';
import '../../../shared/utils/money_format.dart';
import '../models/day_entry.dart';

class SelectedDaysSummarySheet extends StatelessWidget {
  const SelectedDaysSummarySheet({
    super.key,
    required this.selectedDays,
    required this.entryForDay,
    required this.hourlyWage,
    required this.perRoomBonus,
  });

  final List<DateTime> selectedDays;
  final DayEntry? Function(DateTime day) entryForDay;
  final double hourlyWage;
  final double perRoomBonus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = selectedDays.toList(growable: false)
      ..sort((a, b) => dateOnly(a).compareTo(dateOnly(b)));

    double totalWage = 0;
    for (final day in days) {
      final entry = entryForDay(dateOnly(day));
      final hours = entry?.hours ?? 0;
      final rooms = entry?.rooms ?? 0;
      totalWage += (hours * hourlyWage) + (rooms * perRoomBonus);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                l10n.selectedDaysTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OverallTotalCard(daysCount: days.length, totalWage: totalWage),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final day = dateOnly(days[index]);
                final entry = entryForDay(day);
                final hours = entry?.hours ?? 0;
                final rooms = entry?.rooms ?? 0;

                final hoursPay = hours * hourlyWage;
                final roomsPay = rooms * perRoomBonus;
                final total = hoursPay + roomsPay;

                return _DayBreakdownCard(
                  title: dayTitleShortL10n(context, day),
                  hours: hours,
                  hourlyWage: hourlyWage,
                  hoursPay: hoursPay,
                  rooms: rooms,
                  perRoomBonus: perRoomBonus,
                  roomsPay: roomsPay,
                  total: total,
                  hoursLabel: l10n.hours,
                  roomsLabel: l10n.rooms,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBreakdownCard extends StatelessWidget {
  const _DayBreakdownCard({
    required this.title,
    required this.hours,
    required this.hourlyWage,
    required this.hoursPay,
    required this.rooms,
    required this.perRoomBonus,
    required this.roomsPay,
    required this.total,
    required this.hoursLabel,
    required this.roomsLabel,
  });

  final String title;
  final double hours;
  final double hourlyWage;
  final double hoursPay;
  final int rooms;
  final double perRoomBonus;
  final double roomsPay;
  final double total;
  final String hoursLabel;
  final String roomsLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  money(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _Line(
              label: hoursLabel,
              expression:
                  '${_formatHours(hours)} × ${money(hourlyWage)} = ${money(hoursPay)}',
            ),
            const SizedBox(height: 4),
            _Line(
              label: roomsLabel,
              expression:
                  '$rooms × ${money(perRoomBonus)} = ${money(roomsPay)}',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatHours(double hours) {
    if (hours == hours.roundToDouble()) return hours.toStringAsFixed(0);
    return hours.toStringAsFixed(1);
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.expression});

  final String label;
  final String expression;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 54),
          child: Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            expression,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverallTotalCard extends StatelessWidget {
  const _OverallTotalCard({required this.daysCount, required this.totalWage});

  final int daysCount;
  final double totalWage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
        color: Colors.white.withValues(alpha: 0.92),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.totalWage,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.xDays(daysCount),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              money(totalWage),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
