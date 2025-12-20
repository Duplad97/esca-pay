import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../../../shared/utils/date_time_utils.dart';
import 'day_cell.dart';

class CalendarGrid extends StatefulWidget {
  const CalendarGrid({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.hasEntryForDay,
    required this.isDayMultiSelected,
    required this.onSelectDay,
    required this.onDragSelectDay,
    required this.onEditDay,
    required this.onToday,
    required this.multiSelectEnabled,
    required this.onToggleMultiSelect,
    required this.multiSelectedCount,
    required this.onClearMultiSelect,
    required this.onShowMultiSelectSummary,
  });

  final DateTime month;
  final DateTime selectedDay;
  final bool Function(DateTime day) hasEntryForDay;
  final bool Function(DateTime day) isDayMultiSelected;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onDragSelectDay;
  final ValueChanged<DateTime> onEditDay;
  final VoidCallback onToday;
  final bool multiSelectEnabled;
  final VoidCallback onToggleMultiSelect;
  final int multiSelectedCount;
  final VoidCallback onClearMultiSelect;
  final VoidCallback onShowMultiSelectSummary;

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  String? _lastDragDayKey;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const headerPadding = EdgeInsets.fromLTRB(10, 10, 10, 0);
    const weekdayPadding = EdgeInsets.symmetric(horizontal: 10);
    const gridPadding = EdgeInsets.fromLTRB(10, 0, 10, 10);
    const spacing = 6.0;
    const crossAxisCount = 7;
    const childAspectRatio = 0.95;

    final month = widget.month;
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
        child: Column(
          children: <Widget>[
            Padding(
              padding: headerPadding,
              child: Row(
                children: <Widget>[
                  if (!widget.multiSelectEnabled) ...<Widget>[
                    FilledButton.tonalIcon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onToday();
                      },
                      icon: const Icon(Icons.today),
                      label: Text(l10n.today),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onToggleMultiSelect();
                        setState(() => _lastDragDayKey = null);
                      },
                      icon: const Icon(Icons.select_all),
                      label: Text(l10n.select),
                    ),
                    const Spacer(),
                  ] else ...<Widget>[
                    Expanded(
                      child: Text(
                        l10n.selectedCount(widget.multiSelectedCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        widget.onClearMultiSelect();
                      },
                      child: Text(l10n.clear),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onShowMultiSelectSummary();
                      },
                      child: Text(l10n.summary),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.tonal(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onToggleMultiSelect();
                        setState(() => _lastDragDayKey = null);
                      },
                      child: Text(l10n.done),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: weekdayPadding,
              child: Row(children: _weekdayLabels(context)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final availableWidth =
                      constraints.maxWidth -
                      gridPadding.left -
                      gridPadding.right;
                  final cellWidth =
                      (availableWidth - (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;
                  final cellHeight = cellWidth / childAspectRatio;

                  DateTime? dayAt(Offset localPosition) {
                    final x = localPosition.dx - gridPadding.left;
                    final y =
                        (localPosition.dy + _scrollController.offset) -
                        gridPadding.top;
                    if (x < 0 || y < 0) return null;

                    final strideX = cellWidth + spacing;
                    final strideY = cellHeight + spacing;
                    final col = (x / strideX).floor();
                    final row = (y / strideY).floor();
                    if (col < 0 || col >= crossAxisCount || row < 0) {
                      return null;
                    }

                    final withinCellX = x - (col * strideX);
                    final withinCellY = y - (row * strideY);
                    if (withinCellX > cellWidth || withinCellY > cellHeight) {
                      return null;
                    }

                    final index = (row * crossAxisCount) + col;
                    final dayIndex = index - leadingEmpty;
                    if (dayIndex < 0 || dayIndex >= daysInMonthCount) {
                      return null;
                    }
                    return DateTime(first.year, first.month, dayIndex + 1);
                  }

                  void dragSelectAt(Offset localPosition) {
                    if (!widget.multiSelectEnabled) return;
                    final day = dayAt(localPosition);
                    if (day == null) return;
                    final key = dayKey(day);
                    if (_lastDragDayKey == key) return;
                    _lastDragDayKey = key;
                    widget.onDragSelectDay(dateOnly(day));
                  }

                  return Stack(
                    children: <Widget>[
                      GridView.builder(
                        controller: _scrollController,
                        padding: gridPadding,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: spacing,
                              crossAxisSpacing: spacing,
                              childAspectRatio: childAspectRatio,
                            ),
                        itemCount: itemCount,
                        itemBuilder: (BuildContext context, int index) {
                          final dayIndex = index - leadingEmpty;
                          if (dayIndex < 0 || dayIndex >= daysInMonthCount) {
                            return const SizedBox.shrink();
                          }
                          final day = DateTime(
                            first.year,
                            first.month,
                            dayIndex + 1,
                          );
                          final isSelected =
                              !widget.multiSelectEnabled &&
                              dateOnly(day) == dateOnly(widget.selectedDay);
                          final hasEntry = widget.hasEntryForDay(day);
                          final isMultiSelected = widget.isDayMultiSelected(
                            day,
                          );
                          return DayCell(
                            day: day,
                            isSelected: isSelected,
                            hasEntry: hasEntry,
                            isMultiSelected: isMultiSelected,
                            onTap: () => widget.onSelectDay(dateOnly(day)),
                            onLongPress: () => widget.onEditDay(dateOnly(day)),
                          );
                        },
                      ),
                      if (widget.multiSelectEnabled)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onLongPressStart: (details) {
                              setState(() => _lastDragDayKey = null);
                              HapticFeedback.selectionClick();
                              dragSelectAt(details.localPosition);
                            },
                            onLongPressMoveUpdate: (details) =>
                                dragSelectAt(details.localPosition),
                            onLongPressCancel: () =>
                                setState(() => _lastDragDayKey = null),
                            onLongPressEnd: (_) =>
                                setState(() => _lastDragDayKey = null),
                          ),
                        ),
                    ],
                  );
                },
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

    final labels = MaterialLocalizations.of(context).narrowWeekdays;
    final mondayFirst = <String>[
      labels[1],
      labels[2],
      labels[3],
      labels[4],
      labels[5],
      labels[6],
      labels[0],
    ];

    return mondayFirst
        .map(
          (String s) => Expanded(
            child: Center(child: Text(s, style: style)),
          ),
        )
        .toList(growable: false);
  }
}
