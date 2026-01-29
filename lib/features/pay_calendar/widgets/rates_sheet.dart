import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../shared/services/backup_service.dart';
import '../../../shared/storage/day_entries_storage.dart';
import '../models/rates.dart';
import 'money_field.dart';

class RatesSheet extends StatefulWidget {
  const RatesSheet({
    super.key,
    required this.initialHourlyWage,
    required this.initialPerRoomBonus,
    required this.initialJumpInRate,
    required this.initialEventFine,
    required this.initialWeekStartWeekday,
    required this.initialLocaleCode,
    required this.storage,
  });

  final double initialHourlyWage;
  final double initialPerRoomBonus;
  final double initialJumpInRate;
  final double initialEventFine;
  final int initialWeekStartWeekday;
  final String? initialLocaleCode;
  final DayEntriesStorage storage;

  @override
  State<RatesSheet> createState() => _RatesSheetState();
}

class _RatesSheetState extends State<RatesSheet> {
  late final TextEditingController _wageController;
  late final TextEditingController _bonusController;
  late final TextEditingController _jumpInRateController;
  late final TextEditingController _eventFineController;
  late int _weekStartWeekday;
  late String? _localeCode;

  @override
  void initState() {
    super.initState();
    _wageController = TextEditingController(
      text: widget.initialHourlyWage.toStringAsFixed(0),
    );
    _bonusController = TextEditingController(
      text: widget.initialPerRoomBonus.toStringAsFixed(0),
    );
    _jumpInRateController = TextEditingController(
      text: widget.initialJumpInRate.toStringAsFixed(0),
    );
    _eventFineController = TextEditingController(
      text: widget.initialEventFine.toStringAsFixed(0),
    );
    _weekStartWeekday = widget.initialWeekStartWeekday;
    _localeCode = widget.initialLocaleCode;
  }

  @override
  void dispose() {
    _wageController.dispose();
    _bonusController.dispose();
    _jumpInRateController.dispose();
    _eventFineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final inputTheme = Theme.of(context).inputDecorationTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.tune, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.settingsTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.close,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 420;
                        final gap = isWide ? 12.0 : 10.0;
                        final children = <Widget>[
                          MoneyField(
                            controller: _wageController,
                            label: l10n.hourlyWage,
                            helper: l10n.ftPerHour,
                            onChanged: (_) {},
                          ),
                          MoneyField(
                            controller: _bonusController,
                            label: l10n.perRoomBonus,
                            helper: l10n.ftPerRoom,
                            onChanged: (_) {},
                          ),
                          MoneyField(
                            controller: _jumpInRateController,
                            label: l10n.jumpInRate,
                            helper: l10n.ftPerJumpIn,
                            onChanged: (_) {},
                          ),
                          MoneyField(
                            controller: _eventFineController,
                            label: l10n.eventFine,
                            helper: l10n.ftPerEvent,
                            onChanged: (_) {},
                          ),
                        ];

                        if (!isWide) {
                          return Column(
                            children: <Widget>[
                              children[0],
                              SizedBox(height: gap),
                              children[1],
                              SizedBox(height: gap),
                              children[2],
                              SizedBox(height: gap),
                              children[3],
                            ],
                          );
                        }

                        return Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(child: children[0]),
                                SizedBox(width: gap),
                                Expanded(child: children[1]),
                              ],
                            ),
                            SizedBox(height: gap),
                            Row(
                              children: <Widget>[
                                Expanded(child: children[2]),
                                SizedBox(width: gap),
                                Expanded(child: children[3]),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        DropdownMenu<int>(
                          initialSelection: _weekStartWeekday,
                          label: Text(l10n.weekStartsOn),
                          inputDecorationTheme: inputTheme,
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: _weekStartEntries(),
                          onSelected: (int? v) {
                            if (v == null) return;
                            HapticFeedback.selectionClick();
                            setState(() => _weekStartWeekday = v);
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.usedForWeeklyTotals,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        DropdownMenu<String>(
                          initialSelection: _localeCode ?? 'system',
                          label: Text(l10n.language),
                          inputDecorationTheme: inputTheme,
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: <DropdownMenuEntry<String>>[
                            DropdownMenuEntry<String>(
                              value: 'system',
                              label: l10n.languageSystem,
                            ),
                            DropdownMenuEntry<String>(
                              value: 'en',
                              label: l10n.languageEnglish,
                            ),
                            DropdownMenuEntry<String>(
                              value: 'hu',
                              label: l10n.languageHungarian,
                            ),
                          ],
                          onSelected: (String? v) {
                            if (v == null) return;
                            HapticFeedback.selectionClick();
                            setState(() {
                              _localeCode = v == 'system' ? null : v;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Backup',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (BuildContext buttonContext) {
                                  return FilledButton.tonal(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      try {
                                        final file = await BackupService(
                                          widget.storage,
                                        ).exportBackup();
                                        if (mounted && file != null) {
                                          // Get button position for iOS share sheet
                                          final renderBox =
                                              buttonContext.findRenderObject()
                                                  as RenderBox?;
                                          final shareRect = renderBox != null
                                              ? Rect.fromLTWH(
                                                  renderBox
                                                      .localToGlobal(
                                                        Offset.zero,
                                                      )
                                                      .dx,
                                                  renderBox
                                                      .localToGlobal(
                                                        Offset.zero,
                                                      )
                                                      .dy,
                                                  renderBox.size.width,
                                                  renderBox.size.height,
                                                )
                                              : null;

                                          await BackupService(
                                            widget.storage,
                                          ).shareBackup(
                                            file,
                                            sharePositionOrigin: shareRect,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Backup exported',
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Export failed: $e',
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download, size: 18),
                                        SizedBox(width: 8),
                                        Text('Export'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  final confirmed =
                                      await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Import Backup'),
                                          content: const Text(
                                            'This will replace all your current data with the data from the backup file. This cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Import'),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;

                                  if (!confirmed || !mounted) return;

                                  try {
                                    final success = await BackupService(
                                      widget.storage,
                                    ).importBackup();
                                    if (mounted) {
                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Backup imported successfully',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        // Notify parent to refresh data
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Import was cancelled',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Import failed: $e'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload, size: 18),
                                    SizedBox(width: 8),
                                    Text('Import'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                final hourly = double.tryParse(_wageController.text.trim());
                final perRoom = double.tryParse(_bonusController.text.trim());
                final jumpIn = double.tryParse(
                  _jumpInRateController.text.trim(),
                );
                final eventFine = double.tryParse(
                  _eventFineController.text.trim(),
                );
                if (hourly == null ||
                    perRoom == null ||
                    jumpIn == null ||
                    eventFine == null) {
                  return;
                }
                Navigator.of(context).pop(
                  Rates(
                    hourlyWage: hourly,
                    perRoomBonus: perRoom,
                    jumpInRate: jumpIn,
                    eventFine: eventFine,
                    weekStartWeekday: _weekStartWeekday,
                    localeCode: _localeCode,
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuEntry<int>> _weekStartEntries() {
    final weekdays = <int>[
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];

    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.EEEE(localeTag);
    final baseMonday = DateTime(2024, 1, 1); // Monday

    return weekdays
        .map(
          (int weekday) => DropdownMenuEntry<int>(
            value: weekday,
            label: _capitalizeWeekday(
              formatter.format(
                baseMonday.add(Duration(days: weekday - DateTime.monday)),
              ),
              localeTag,
            ),
          ),
        )
        .toList(growable: false);
  }

  static String _capitalizeWeekday(String label, String localeTag) {
    return toBeginningOfSentenceCase(label, localeTag);
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

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
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
