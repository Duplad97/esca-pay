import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/date_time_utils.dart';

class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.hasEntry,
    required this.onTap,
    required this.onLongPress,
  });

  final DateTime day;
  final bool isSelected;
  final bool hasEntry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = dateOnly(day) == dateOnly(DateTime.now());

    final borderColor = isSelected
        ? colorScheme.primary
        : isToday
            ? colorScheme.secondary
            : colorScheme.outlineVariant;

    final background = isSelected
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.primaryContainer.withValues(alpha: 1),
              colorScheme.secondaryContainer.withValues(alpha: 0.95),
            ],
          )
        : null;

    final setupGradient = (!isSelected && hasEntry)
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.tertiaryContainer.withValues(alpha: 0.80),
              Colors.white.withValues(alpha: 0.96),
            ],
          )
        : null;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
      color: (background == null && setupGradient == null)
          ? Colors.white.withValues(alpha: 0.85)
          : null,
      gradient: background ?? setupGradient,
      boxShadow: isSelected
          ? <BoxShadow>[
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ]
          : const <BoxShadow>[],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress();
        },
        child: Container(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final canShowTodayIcon = isToday && constraints.maxWidth >= 32;
                final canShowEntryBadge = hasEntry && constraints.maxWidth >= 28;
                final canShowTinyEntryDot = hasEntry && constraints.maxWidth < 28;
                return Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Text(
                        '${day.day}',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    if (canShowTodayIcon)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Icon(
                          Icons.bolt,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                      ),
                    if (canShowEntryBadge)
                      Positioned(
                        bottom: -1,
                        right: -1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const SizedBox(
                            width: 14,
                            height: 14,
                            child: Center(
                              child: Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    if (canShowTinyEntryDot)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 7, height: 7),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
