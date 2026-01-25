import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../models/event.dart';
import '../widgets/combined_time_picker_dialog.dart';

class EditEventsSheet extends StatefulWidget {
  const EditEventsSheet({
    super.key,
    required this.initialEvents,
    required this.eventFine,
  });

  final List<Event> initialEvents;
  final double eventFine;

  @override
  State<EditEventsSheet> createState() => _EditEventsSheetState();
}

class _EditEventsSheetState extends State<EditEventsSheet> {
  late List<Event> _events;

  @override
  void initState() {
    super.initState();
    _events = widget.initialEvents.toList(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.events,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.eventsToday(_events.length),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: _events.isEmpty
                ? Center(
                    child: Text(
                      l10n.eventsSheetEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final e = _events[index];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text('${_fmt(e.start)} → ${_fmt(e.end)}'),
                          trailing: IconButton(
                            tooltip: l10n.remove,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _events.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                          onTap: () async {
                            final pair = await _pickTimePair(
                              context,
                              startInitial: e.start,
                              endInitial: e.end,
                              l10n: l10n,
                            );
                            if (pair == null) return;
                            HapticFeedback.selectionClick();
                            setState(() {
                              _events[index] = Event(
                                start: pair.$1,
                                end: pair.$2,
                              );
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: () async {
                  final pair = await _pickTimePair(
                    context,
                    startInitial: const TimeOfDay(hour: 8, minute: 0),
                    endInitial: const TimeOfDay(hour: 9, minute: 0),
                    l10n: l10n,
                  );
                  if (pair == null) return;
                  HapticFeedback.selectionClick();
                  setState(() {
                    _events.add(Event(start: pair.$1, end: pair.$2));
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addEvent),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(_events);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<(TimeOfDay, TimeOfDay)?> _pickTimePair(
    BuildContext context, {
    required TimeOfDay startInitial,
    required TimeOfDay endInitial,
    required AppLocalizations l10n,
  }) async {
    final pair = await showDialog<(TimeOfDay, TimeOfDay)>(
      context: context,
      builder: (BuildContext context) => CombinedTimePickerDialog(
        initialStartTime: startInitial,
        initialEndTime: endInitial,
      ),
    );
    return pair;
  }
}
