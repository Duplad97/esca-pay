import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';
import 'custom_time_picker_dialog.dart';

class TimePickerRow extends StatelessWidget {
  const TimePickerRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTimeChanged,
    required this.isStartTime,
  });

  final String title;
  final String subtitle;
  final TimeOfDay? time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool isStartTime;

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: time != null
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: time != null ? 2 : 1,
        ),
        color: Colors.white.withValues(alpha: 0.9),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            final selectedTime = await showDialog<TimeOfDay>(
              context: context,
              builder: (BuildContext context) => CustomTimePickerDialog(
                initialTime: time ?? TimeOfDay.now(),
                title: isStartTime
                    ? AppLocalizations.of(context)!.selectStartTime
                    : AppLocalizations.of(context)!.selectEndTime,
              ),
            );
            if (selectedTime != null) {
              HapticFeedback.selectionClick();
              onTimeChanged(selectedTime);
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: time != null
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: time != null
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(time),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: time != null
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
