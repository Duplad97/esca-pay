import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esca_pay/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/rates.dart';
import 'money_field.dart';

class RatesSheet extends StatefulWidget {
  const RatesSheet({
    super.key,
    required this.initialHourlyWage,
    required this.initialPerRoomBonus,
    required this.initialWeekStartWeekday,
    required this.initialLocaleCode,
  });

  final double initialHourlyWage;
  final double initialPerRoomBonus;
  final int initialWeekStartWeekday;
  final String? initialLocaleCode;

  @override
  State<RatesSheet> createState() => _RatesSheetState();
}

class _RatesSheetState extends State<RatesSheet> {
  late final TextEditingController _wageController;
  late final TextEditingController _bonusController;
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
    _weekStartWeekday = widget.initialWeekStartWeekday;
    _localeCode = widget.initialLocaleCode;
  }

  @override
  void dispose() {
    _wageController.dispose();
    _bonusController.dispose();
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
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
                  ];

                  if (!isWide) {
                    return Column(
                      children: <Widget>[
                        children[0],
                        SizedBox(height: gap),
                        children[1],
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(child: children[0]),
                      SizedBox(width: gap),
                      Expanded(child: children[1]),
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final hourly = double.tryParse(_wageController.text.trim());
                  final perRoom = double.tryParse(_bonusController.text.trim());
                  if (hourly == null || perRoom == null) return;
                  Navigator.of(context).pop(
                    Rates(
                      hourlyWage: hourly,
                      perRoomBonus: perRoom,
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
