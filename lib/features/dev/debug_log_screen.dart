import 'package:flutter/material.dart';
import 'package:esca_pay/shared/services/debug_log_service.dart';
import 'package:esca_pay/shared/services/notification_service.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

class DebugLogScreen extends StatefulWidget {
  const DebugLogScreen({super.key});

  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = debugLog.getLogs();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Test Reminder',
            onPressed: () {
              final l10n = AppLocalizations.of(context)!;
              NotificationService().scheduleTestReminder(
                title: l10n.weeklyPaymentSummaryTitle,
                body: l10n.weeklyPaymentSummaryBody,
                delaySeconds: 5,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test notification scheduled for 5 seconds'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              debugLog.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: logs.isEmpty
          ? Center(
              child: Text(
                'No logs yet',
                style: TextStyle(color: colorScheme.outline),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isNotification = log.contains('[NotificationService]');
                final isCheckbox = log.contains('[WeeklySummaryCheckbox]');

                Color logColor = colorScheme.onSurface;
                if (isNotification) {
                  logColor = colorScheme.primary;
                } else if (isCheckbox) {
                  logColor = colorScheme.secondary;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: logColor,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
