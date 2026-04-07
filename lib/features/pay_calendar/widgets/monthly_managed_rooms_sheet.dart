import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/localized_date_labels.dart';

class MonthlyManagedRoomsSheet extends StatefulWidget {
  const MonthlyManagedRoomsSheet({
    super.key,
    required this.initialMonth,
    required this.roomCountsForMonth,
  });

  final DateTime initialMonth;
  final List<MapEntry<String, int>> Function(DateTime month) roomCountsForMonth;

  @override
  State<MonthlyManagedRoomsSheet> createState() =>
      _MonthlyManagedRoomsSheetState();
}

class _MonthlyManagedRoomsSheetState extends State<MonthlyManagedRoomsSheet> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final monthLabel = monthTitleL10n(context, _visibleMonth);
    final roomCounts = widget.roomCountsForMonth(_visibleMonth);
    final totalCount = roomCounts.fold<int>(0, (sum, item) => sum + item.value);
    final activeCount = roomCounts.where((item) => item.value > 0).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '${l10n.monthly} ${l10n.rooms}',
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
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              IconButton(
                tooltip: l10n.previousMonthTooltip,
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month - 1,
                      1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                monthLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                '$activeCount/${roomCounts.length} • $totalCount',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurfaceVariant,
                ),
              ),
              IconButton(
                tooltip: l10n.nextMonthTooltip,
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month + 1,
                      1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant),
                color: Colors.white.withValues(alpha: 0.9),
              ),
              child: ListView.separated(
                itemCount: roomCounts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.7),
                ),
                itemBuilder: (BuildContext context, int index) {
                  final item = roomCounts[index];
                  final isZero = item.value == 0;
                  return ListTile(
                    leading: Icon(
                      isZero ? Icons.remove_circle_outline : Icons.check_circle,
                      color: isZero ? cs.error : cs.primary,
                    ),
                    title: Text(
                      item.key,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isZero ? cs.onSurfaceVariant : cs.onSurface,
                        fontWeight: isZero ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    trailing: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isZero
                            ? cs.errorContainer.withValues(alpha: 0.5)
                            : cs.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          '${item.value}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isZero
                                    ? cs.error
                                    : cs.onPrimaryContainer,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
