import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

class CombinedTimePickerDialog extends StatefulWidget {
  const CombinedTimePickerDialog({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
  });

  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;

  @override
  State<CombinedTimePickerDialog> createState() =>
      _CombinedTimePickerDialogState();
}

class _CombinedTimePickerDialogState extends State<CombinedTimePickerDialog> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.initialStartTime.hour,
      widget.initialStartTime.minute,
    );
    _endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.initialEndTime.hour,
      widget.initialEndTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Center(
                child: Text(
                  l10n.selectEventTime,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: colorScheme.surface),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            l10n.startTimeTitle,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 280,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: _startDateTime,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  _startDateTime = newDateTime;
                                  if (_endDateTime.isBefore(_startDateTime)) {
                                    _endDateTime = _startDateTime.add(
                                      const Duration(hours: 1),
                                    );
                                  }
                                });
                              },
                              use24hFormat: true,
                              itemExtent: 45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            l10n.endTimeTitle,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 280,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: _endDateTime,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  _endDateTime = newDateTime;
                                });
                              },
                              use24hFormat: true,
                              itemExtent: 45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.close),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context, (
                        TimeOfDay(
                          hour: _startDateTime.hour,
                          minute: _startDateTime.minute,
                        ),
                        TimeOfDay(
                          hour: _endDateTime.hour,
                          minute: _endDateTime.minute,
                        ),
                      ));
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
