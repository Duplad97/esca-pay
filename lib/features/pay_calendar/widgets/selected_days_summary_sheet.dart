import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/date_time_utils.dart';
import '../../../shared/utils/localized_date_labels.dart';
import '../../../shared/utils/money_format.dart';
import '../models/benefit.dart';
import '../models/day_entry.dart';
import '../models/game_session.dart';
import '../models/rates.dart';

class SelectedDaysSummarySheet extends StatelessWidget {
  const SelectedDaysSummarySheet({
    super.key,
    required this.selectedDays,
    required this.entryForDay,
    required this.ratesForEntry,
  });

  final List<DateTime> selectedDays;
  final DayEntry? Function(DateTime day) entryForDay;
  final Rates Function(DayEntry entry) ratesForEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = selectedDays.toList(growable: false)
      ..sort((a, b) => dateOnly(a).compareTo(dateOnly(b)));

    // Collect all benefits from all selected days
    final allBenefits = <Benefit>[];
    for (final day in days) {
      final entry = entryForDay(dateOnly(day));
      if (entry != null && entry.benefits.isNotEmpty) {
        allBenefits.addAll(entry.benefits);
      }
    }
    final totalBenefits = allBenefits.fold<double>(
      0,
      (sum, b) => sum + b.amount,
    );

    double totalWage = 0;
    for (final day in days) {
      final entry = entryForDay(dateOnly(day));
      if (entry != null) {
        final rates = ratesForEntry(entry);
        totalWage += entry.earnings(
          hourlyWage: rates.hourlyWage,
          perRoomBonus: rates.perRoomBonus,
          jumpInRate: rates.jumpInRate,
          eventFine: rates.eventFine,
        );
      }
    }
    totalWage += totalBenefits;

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
          if (allBenefits.isNotEmpty) ...[
            _BenefitsCard(benefits: allBenefits, label: l10n.benefits),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: ListView.separated(
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final day = dateOnly(days[index]);
                final entry = entryForDay(day);
                final hours = entry?.hours ?? 0;
                final rooms = entry?.rooms ?? 0;
                final rates = entry != null ? ratesForEntry(entry) : null;
                final hourlyWage = rates?.hourlyWage ?? 0;
                final perRoomBonus = rates?.perRoomBonus ?? 0;
                final jumpInRate = rates?.jumpInRate ?? 0;
                final eventFine = rates?.eventFine ?? 0;
                final jumpInCount =
                    entry?.sessions
                        .where((s) => s.type == SessionType.jumpIn)
                        .length ??
                    0;
                final eventCount = entry?.events.length ?? 0;

                final hoursPay = hours * hourlyWage;
                final roomsPay = rooms * perRoomBonus;
                final jumpInPay = jumpInCount * jumpInRate;
                final eventsBonus = eventCount * eventFine;
                final total = hoursPay + roomsPay + jumpInPay + eventsBonus;

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
                  sessions: entry?.sessions ?? [],
                  jumpInRate: jumpInRate,
                  jumpInPay: jumpInPay,
                  eventsLabel: l10n.events,
                  eventCount: eventCount,
                  eventsBonus: eventsBonus,
                  eventFine: eventFine,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ... (all other code remains the same)

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
    this.sessions = const [],
    required this.jumpInRate,
    required this.jumpInPay,
    required this.eventsLabel,
    required this.eventCount,
    required this.eventsBonus,
    required this.eventFine,
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
  final List<GameSession> sessions;
  final double jumpInRate;
  final double jumpInPay;
  final String eventsLabel;
  final int eventCount;
  final double eventsBonus;
  final double eventFine;

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
            if (hours > 0) const SizedBox(height: 8),
            if (hours > 0)
              _Line(
                label: hoursLabel,
                expression:
                    '${_formatHours(hours)} × ${money(hourlyWage)} = ${money(hoursPay)}',
              ),
            if (rooms > 0) const SizedBox(height: 4),
            if (rooms > 0)
              _Line(
                label: roomsLabel,
                expression:
                    '$rooms × ${money(perRoomBonus)} = ${money(roomsPay)}',
              ),
            // Insert jump-in game summary line
            Builder(
              builder: (BuildContext context) {
                final l10n = AppLocalizations.of(context)!;
                // Count jump-in games from sessions
                final jumpInCount = sessions
                    .where((s) => s.type == SessionType.jumpIn)
                    .length;
                return jumpInCount > 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _Line(
                          label: l10n.jumpIn,
                          expression:
                              '$jumpInCount × ${money(jumpInRate)} = ${money(jumpInPay)}',
                        ),
                      )
                    : SizedBox.shrink();
              },
            ),
            if (eventCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _Line(
                  label: eventsLabel,
                  expression:
                      '$eventCount × ${money(eventFine)} = ${money(eventsBonus)}',
                ),
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

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.benefits, required this.label});

  final List<Benefit> benefits;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalBenefits = benefits.fold<double>(0, (sum, b) => sum + b.amount);

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
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  money(totalBenefits),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _Line(
                  label: benefit.name,
                  expression: money(benefit.amount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
