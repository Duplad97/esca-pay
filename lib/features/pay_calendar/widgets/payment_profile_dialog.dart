import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../models/payment_profile.dart';
import 'money_field.dart';

class PaymentProfileDialog extends StatefulWidget {
  const PaymentProfileDialog({super.key, this.profile});

  final PaymentProfile? profile;

  @override
  State<PaymentProfileDialog> createState() => _PaymentProfileDialogState();
}

class _PaymentProfileDialogState extends State<PaymentProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _wageController;
  late final TextEditingController _bonusController;
  late final TextEditingController _jumpInRateController;
  late final TextEditingController _eventFineController;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _wageController = TextEditingController(
      text: profile?.hourlyWage.toStringAsFixed(0) ?? '',
    );
    _bonusController = TextEditingController(
      text: profile?.perRoomBonus.toStringAsFixed(0) ?? '',
    );
    _jumpInRateController = TextEditingController(
      text: profile?.jumpInRate.toStringAsFixed(0) ?? '',
    );
    _eventFineController = TextEditingController(
      text: profile?.eventFine.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wageController.dispose();
    _bonusController.dispose();
    _jumpInRateController.dispose();
    _eventFineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final inputTheme = Theme.of(context).inputDecorationTheme.copyWith(
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Text(
        widget.profile == null ? l10n.createProfile : l10n.editProfile,
      ),
      content: SingleChildScrollView(
        child: Theme(
          data: Theme.of(context).copyWith(inputDecorationTheme: inputTheme),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    label: Text(l10n.profileName),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        MoneyField(
                          controller: _wageController,
                          label: l10n.hourlyWageTitle,
                          helper: l10n.ftPerHour,
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 12),
                        MoneyField(
                          controller: _bonusController,
                          label: l10n.perRoomBonusTitle,
                          helper: l10n.ftPerRoom,
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 12),
                        MoneyField(
                          controller: _jumpInRateController,
                          label: l10n.jumpInRateTitle,
                          helper: l10n.ftPerJumpIn,
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 12),
                        MoneyField(
                          controller: _eventFineController,
                          label: l10n.eventFineTitle,
                          helper: l10n.ftPerEvent,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.profileNameRequired)));
              return;
            }

            final newProfile =
                (widget.profile ??
                        PaymentProfile(
                          id: '',
                          name: '',
                          hourlyWage: 0,
                          perRoomBonus: 0,
                          jumpInRate: 0,
                          eventFine: 0,
                        ))
                    .copyWith(
                      name: _nameController.text.trim(),
                      hourlyWage: double.tryParse(_wageController.text) ?? 0,
                      perRoomBonus: double.tryParse(_bonusController.text) ?? 0,
                      jumpInRate:
                          double.tryParse(_jumpInRateController.text) ?? 0,
                      eventFine:
                          double.tryParse(_eventFineController.text) ?? 0,
                    );

            Navigator.of(context).pop(newProfile);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
