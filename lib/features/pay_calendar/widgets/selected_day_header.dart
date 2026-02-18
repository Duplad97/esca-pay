import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/localized_date_labels.dart';
import '../../../shared/utils/money_format.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../models/day_entry.dart';

class SelectedDayHeader extends StatefulWidget {
  const SelectedDayHeader({
    super.key,
    required this.selectedDay,
    required this.entry,
    required this.dayTotal,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onEditSessions,
    required this.onEditEvents,
    required this.onEditBenefits,
    required this.onEditDeductions,
    required this.onEditDay,
  });

  final DateTime selectedDay;
  final DayEntry? entry;
  final double dayTotal;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onEditSessions;
  final VoidCallback onEditEvents;
  final VoidCallback onEditBenefits;
  final VoidCallback onEditDeductions;
  final VoidCallback onEditDay;

  @override
  State<SelectedDayHeader> createState() => _SelectedDayHeaderState();
}

class _SelectedDayHeaderState extends State<SelectedDayHeader> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final hours = widget.entry?.hours ?? 0;
    final rooms = widget.entry?.rooms ?? 0;
    final events = widget.entry?.events.length ?? 0;
    final hasEntry = !(widget.entry == null || widget.entry!.isEmpty);

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
                    widget.onPrevDay();
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
                        selectedDayLabelL10n(context, widget.selectedDay),
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
                    widget.onNextDay();
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
                      money(widget.dayTotal),
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
                  ? l10n.hoursRoomsEventsLine(
                      _formatHours(hours),
                      rooms,
                      events,
                    )
                  : l10n.noEntryYetHint,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            // Default buttons row: Sessions and Edit Day
            Row(
              children: <Widget>[
                Expanded(
                  child: _ActionButton(
                    tonal: true,
                    icon: Icons.badge,
                    label: l10n.sessions,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onEditSessions();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    tonal: false,
                    icon: Icons.edit,
                    label: l10n.dayShort,
                    compact: true,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onEditDay();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _expanded = !_expanded);
                    },
                    tooltip: _expanded ? l10n.close : 'More',
                  ),
                ),
              ],
            ),
            // Expanded buttons row: Events, Benefits, and Deductions
            if (_expanded) ...[
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ActionButton(
                      tonal: true,
                      icon: Icons.event,
                      label: l10n.events,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onEditEvents();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      tonal: true,
                      icon: Icons.card_giftcard,
                      label: l10n.benefits,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onEditBenefits();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 48,
                  ), // Match expand button width + spacing
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  IntrinsicWidth(
                    child: _ActionButton(
                      tonal: true,
                      icon: Icons.remove_circle_outline,
                      label: l10n.deductions,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onEditDeductions();
                      },
                    ),
                  ),
                ],
              ),
            ],
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
    this.compact = false,
  });

  final bool tonal;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 10, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size(0, 40),
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: tonal ? cs.onSurface : cs.onPrimary,
              ),
            ),
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
