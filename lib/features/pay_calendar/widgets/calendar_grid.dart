import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/date_time_utils.dart';
import 'day_cell.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.hasEntryForDay,
    required this.onSelectDay,
    required this.onEditDay,
    required this.onToday,
  });

  final DateTime month;
  final DateTime selectedDay;
  final bool Function(DateTime day) hasEntryForDay;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onEditDay;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonthCount = daysInMonth(first);
    final leadingEmpty = (first.weekday + 6) % 7;
    final totalCells = leadingEmpty + daysInMonthCount;
    final trailingEmpty = (7 - (totalCells % 7)) % 7;
    final itemCount = totalCells + trailingEmpty;

    final radius = BorderRadius.circular(28);
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.white.withValues(alpha: 0.65),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  children: <Widget>[
                  FilledButton.tonalIcon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onToday();
                    },
                    icon: const Icon(Icons.today),
                    label: const Text('Today'),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: _weekdayLabels(context)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final dayIndex = index - leadingEmpty;
                    if (dayIndex < 0 || dayIndex >= daysInMonthCount) {
                      return const SizedBox.shrink();
                    }
                    final day = DateTime(first.year, first.month, dayIndex + 1);
                    final isSelected = dateOnly(day) == dateOnly(selectedDay);
                    final hasEntry = hasEntryForDay(day);
                    return DayCell(
                      day: day,
                      isSelected: isSelected,
                      hasEntry: hasEntry,
                      onTap: () => onSelectDay(dateOnly(day)),
                      onLongPress: () => onEditDay(dateOnly(day)),
                    );
                  },
                  childCount: itemCount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _weekdayLabels(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    const labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels
        .map(
          (String s) => Expanded(
            child: Center(child: Text(s, style: style)),
          ),
        )
        .toList(growable: false);
  }
}
