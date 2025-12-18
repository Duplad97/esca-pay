import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/rates.dart';
import 'money_field.dart';

class RatesSheet extends StatefulWidget {
  const RatesSheet({
    super.key,
    required this.initialHourlyWage,
    required this.initialPerRoomBonus,
  });

  final double initialHourlyWage;
  final double initialPerRoomBonus;

  @override
  State<RatesSheet> createState() => _RatesSheetState();
}

class _RatesSheetState extends State<RatesSheet> {
  late final TextEditingController _wageController;
  late final TextEditingController _bonusController;

  @override
  void initState() {
    super.initState();
    _wageController = TextEditingController(
      text: widget.initialHourlyWage.toStringAsFixed(0),
    );
    _bonusController = TextEditingController(
      text: widget.initialPerRoomBonus.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _wageController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              Icon(Icons.tune, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Rates',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: MoneyField(
                  controller: _wageController,
                  label: 'Hourly wage',
                  helper: 'Ft / hour',
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MoneyField(
                  controller: _bonusController,
                  label: 'Per-room bonus',
                  helper: 'Ft / room',
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const Spacer(),
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final hourly = double.tryParse(_wageController.text.trim());
                  final perRoom = double.tryParse(_bonusController.text.trim());
                  if (hourly == null || perRoom == null) return;
                  Navigator.of(context).pop(
                    Rates(hourlyWage: hourly, perRoomBonus: perRoom),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
