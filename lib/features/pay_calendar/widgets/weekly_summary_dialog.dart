import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';
import '../../../shared/services/notification_service.dart';

class WeeklySummaryConfirmationDialog extends StatelessWidget {
  const WeeklySummaryConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.weeklyPaymentSummaryDialogTitle),
      content: Text(l10n.weeklyPaymentSummaryDialogMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.weeklyPaymentSummaryDialogCancel),
        ),
        TextButton(
          onPressed: () async {
            await NotificationService().confirmWeeklySummary();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(l10n.weeklyPaymentSummaryDialogConfirm),
        ),
      ],
    );
  }
}
