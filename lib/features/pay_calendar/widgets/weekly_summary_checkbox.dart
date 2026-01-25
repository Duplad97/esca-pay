import 'dart:async';
import 'package:flutter/material.dart';
import 'package:esca_pay/l10n/app_localizations.dart';
import '../../../shared/services/notification_service.dart';

class WeeklySummaryCheckbox extends StatefulWidget {
  final int weekStartWeekday;
  final bool forceShow;

  const WeeklySummaryCheckbox({
    super.key,
    required this.weekStartWeekday,
    this.forceShow = false,
  });

  @override
  State<WeeklySummaryCheckbox> createState() => _WeeklySummaryCheckboxState();
}

class _WeeklySummaryCheckboxState extends State<WeeklySummaryCheckbox>
    with WidgetsBindingObserver {
  bool _isSubmitting = false;
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Listen to app lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Poll frequently to catch state changes
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes back to foreground, rebuild to check if confirmation changed
    if (state == AppLifecycleState.resumed) {
      print('[WeeklySummaryCheckbox] App resumed, rebuilding');
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didUpdateWidget(WeeklySummaryCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_isSubmitting || NotificationService().isWeeklySummarySent()) return;
    setState(() {
      _isSubmitting = true;
    });
    await NotificationService().confirmWeeklySummary();
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final inNotificationWindow = NotificationService().isInNotificationWindow(
      widget.weekStartWeekday,
    );
    final isConfirmed = NotificationService().isWeeklySummarySent();

    print(
      '[WeeklySummaryCheckbox.build] isConfirmed=$isConfirmed, inWindow=$inNotificationWindow, forceShow=${widget.forceShow}',
    );

    final baseColor = isConfirmed ? colorScheme.primary : colorScheme.secondary;
    final bgColor = baseColor.withValues(alpha: 0.08);
    final borderColor = baseColor.withValues(alpha: 0.24);

    // Don't show the checkbox if not in the notification window unless forced
    if (!inNotificationWindow && !widget.forceShow) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                isConfirmed ? Icons.check_circle : Icons.help_outline,
                color: baseColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isConfirmed
                      ? l10n.weeklyPaymentSummaryCheckboxLabel
                      : l10n.weeklyPaymentSummaryDialogMessage,
                  style: TextStyle(
                    color: baseColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isConfirmed)
                TextButton(
                  onPressed: _isSubmitting ? null : _confirm,
                  style: TextButton.styleFrom(foregroundColor: baseColor),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.weeklyPaymentSummaryDialogConfirm),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
