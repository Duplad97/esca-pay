import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/localized_date_labels.dart';
import '../../../shared/utils/money_format.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../models/day_entry.dart';

class SelectedDayHeader extends StatelessWidget {
  const SelectedDayHeader({
    super.key,
    required this.selectedDay,
    required this.entry,
    required this.dayTotal,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onEditSessions,
    required this.onEditDay,
  });

  final DateTime selectedDay;
  final DayEntry? entry;
  final double dayTotal;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onEditSessions;
  final VoidCallback onEditDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final hours = entry?.hours ?? 0;
    final rooms = entry?.rooms ?? 0;
    final hasEntry = !(entry == null || entry!.isEmpty);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        color: Colors.white.withValues(alpha: 0.85),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  tooltip: l10n.previousDayTooltip,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onPrevDay();
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.selectedDay,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      MarqueeText(
                        selectedDayLabelL10n(context, selectedDay),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.nextDayTooltip,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onNextDay();
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      money(dayTotal),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              hasEntry
                  ? l10n.hoursRoomsLine(_formatHours(hours), rooms)
                  : l10n.noEntryYetHint,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ActionButton(
                    tonal: true,
                    icon: Icons.badge,
                    label: l10n.sessions,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onEditSessions();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    tonal: false,
                    icon: Icons.edit,
                    label: l10n.editDay,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onEditDay();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatHours(double hours) {
    if (hours == hours.roundToDouble()) return hours.toStringAsFixed(0);
    return hours.toStringAsFixed(1);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tonal,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool tonal;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size(0, 44),
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(label, maxLines: 1),
          ),
        ),
      ],
    );

    if (tonal) {
      return FilledButton.tonal(
        style: style,
        onPressed: onPressed,
        child: child,
      );
    }

    return FilledButton(style: style, onPressed: onPressed, child: child);
  }
}
