import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import 'money_field.dart';

class RatesCard extends StatefulWidget {
  const RatesCard({
    super.key,
    required this.hourlyWage,
    required this.perRoomBonus,
    required this.onHourlyWageChanged,
    required this.onPerRoomBonusChanged,
  });

  final double hourlyWage;
  final double perRoomBonus;
  final ValueChanged<double> onHourlyWageChanged;
  final ValueChanged<double> onPerRoomBonusChanged;

  @override
  State<RatesCard> createState() => _RatesCardState();
}

class _RatesCardState extends State<RatesCard> {
  late final TextEditingController _wageController;
  late final TextEditingController _bonusController;

  @override
  void initState() {
    super.initState();
    _wageController = TextEditingController(
      text: widget.hourlyWage.toStringAsFixed(0),
    );
    _bonusController = TextEditingController(
      text: widget.perRoomBonus.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant RatesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hourlyWage != widget.hourlyWage) {
      _wageController.text = widget.hourlyWage.toStringAsFixed(0);
    }
    if (oldWidget.perRoomBonus != widget.perRoomBonus) {
      _bonusController.text = widget.perRoomBonus.toStringAsFixed(0);
    }
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.85),
            const Color(0xFFFFE6F1).withValues(alpha: 0.7),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.local_florist, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.appTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.tagline,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: MoneyField(
                    controller: _wageController,
                    label: l10n.hourlyWage,
                    helper: l10n.ftPerHour,
                    onChanged: widget.onHourlyWageChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MoneyField(
                    controller: _bonusController,
                    label: l10n.perRoomBonus,
                    helper: l10n.ftPerRoom,
                    onChanged: widget.onPerRoomBonusChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
