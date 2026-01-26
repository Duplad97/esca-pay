import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../storage/storage.dart';
import 'debug_log_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _notificationChannelId = 'weekly_summary_reminder';
  static const String _notificationChannelName = 'Weekly Summary Reminder';
  static const int _baseNotificationId = 2000;
  static const int _hourlyRepeats = 6; // 6pm..11pm inclusive

  // Store scheduling parameters for rescheduling next week
  int? _lastWeekStartWeekday;
  String? _lastTitle;
  String? _lastBody;

  /// Helper method to log to both console and debug log
  void _log(String message) {
    print(message);
    debugLog.log(message);
  }

  Future<void> init() async {
    _log('[NotificationService.init] Starting initialization');
    tzdata.initializeTimeZones();

    // Set timezone to device's local timezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    _log('[NotificationService.init] Timezone set to: $timeZoneName');

    await _initializePlugin();
    _log('[NotificationService.init] Plugin initialized');

    // Request iOS permissions
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _log('[NotificationService.init] iOS permissions requested');
  }

  /// Schedule the weekly payment summary notification.
  /// Runs at 6 PM on the last day of the week, repeating hourly until confirmed.
  Future<void> scheduleWeeklyPaymentSummaryReminder({
    required int weekStartWeekday,
    required String title,
    required String body,
  }) async {
    // Store parameters for potential rescheduling
    _lastWeekStartWeekday = weekStartWeekday;
    _lastTitle = title;
    _lastBody = body;

    final now = tz.TZDateTime.now(tz.local);
    _log(
      '[NotificationService] scheduleWeeklyPaymentSummaryReminder called at $now',
    );
    _log(
      '[NotificationService] weekStartWeekday=$weekStartWeekday (${_weekdayName(weekStartWeekday)})',
    );

    // Reset weekly confirmation when a new week starts
    _resetIfNewWeek(weekStartWeekday);
    if (settingsStorage.isWeeklyPaymentSummarySent()) {
      _log(
        '[NotificationService] Weekly summary already confirmed; scheduling next week',
      );
      await _scheduleForNextWeek(
        weekStartWeekday: weekStartWeekday,
        title: title,
        body: body,
      );
      return;
    }

    // Calculate last day of week (1=Mon..7=Sun)
    final lastDayOfWeek = ((weekStartWeekday + 5) % 7) + 1;
    _log(
      '[NotificationService] Last day of week: $lastDayOfWeek (${_weekdayName(lastDayOfWeek)})',
    );
    _log(
      '[NotificationService] Current day: ${now.weekday} (${_weekdayName(now.weekday)})',
    );

    var scheduledDate = _nextOccurrenceOfWeekday(now, lastDayOfWeek);
    scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      18,
      0,
      0,
    );

    _log('[NotificationService] Initial scheduled date: $scheduledDate');

    // If we're on the last day but after 6pm, schedule for today
    // Otherwise if the date is in the past, schedule for next week
    if (scheduledDate.isBefore(now)) {
      // Check if we're on the same day but past 6pm
      if (now.weekday == lastDayOfWeek && now.hour >= 18) {
        _log(
          '[NotificationService] We are on the last day after 6pm, scheduling for remaining hours today',
        );
        // Schedule for remaining hours today
        scheduledDate = now;
      } else {
        _log(
          '[NotificationService] Scheduled date is in past, moving to next week',
        );
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }
    }

    _log('[NotificationService] Final scheduled date: $scheduledDate');

    // Check if notifications are already scheduled for future times
    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    _log(
      '[NotificationService] Pending notifications: ${pendingNotifications.length}',
    );

    final reminderIds = pendingNotifications
        .where(
          (n) =>
              n.id >= _baseNotificationId &&
              n.id < _baseNotificationId + _hourlyRepeats,
        )
        .toList();

    if (reminderIds.isNotEmpty) {
      _log(
        '[NotificationService] Found ${reminderIds.length} existing reminder notifications:',
      );

      // Calculate what the base scheduled time should be
      var baseScheduledDate = _nextOccurrenceOfWeekday(now, lastDayOfWeek);
      baseScheduledDate = tz.TZDateTime(
        tz.local,
        baseScheduledDate.year,
        baseScheduledDate.month,
        baseScheduledDate.day,
        18,
        0,
        0,
      );
      if (baseScheduledDate.isBefore(now) &&
          !(now.weekday == lastDayOfWeek && now.hour >= 18)) {
        baseScheduledDate = baseScheduledDate.add(const Duration(days: 7));
      }

      for (final notif in reminderIds) {
        final hourOffset = notif.id - _baseNotificationId;
        final scheduledTime = baseScheduledDate.add(
          Duration(hours: hourOffset),
        );
        final hourStr = scheduledTime.hour.toString().padLeft(2, '0');
        final minStr = scheduledTime.minute.toString().padLeft(2, '0');
        final timeStr = '$hourStr:$minStr';
        final isPast = scheduledTime.isBefore(now);
        _log(
          '[NotificationService]   - ID ${notif.id}: ${notif.title} - scheduled for ${scheduledTime.year}-${scheduledTime.month}-${scheduledTime.day} at $timeStr${isPast ? ' (PAST)' : ''}',
        );
      }
      _log(
        '[NotificationService] Skipping reschedule - notifications already exist',
      );
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'Reminder for weekly payment summary',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    int scheduledCount = 0;
    _log(
      '[NotificationService] Attempting to schedule ${_hourlyRepeats} notifications:',
    );
    for (int i = 0; i < _hourlyRepeats; i++) {
      final when = scheduledDate.add(Duration(hours: i));
      final hourStr = when.hour.toString().padLeft(2, '0');
      final minStr = when.minute.toString().padLeft(2, '0');
      final timeStr = '$hourStr:$minStr';

      // Only schedule if the time is in the future
      if (when.isAfter(now)) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          _baseNotificationId + i,
          title,
          body,
          when,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduledCount++;
        _log(
          '[NotificationService]   ✓ #${i + 1}: ${when.year}-${when.month}-${when.day} at $timeStr (ID: ${_baseNotificationId + i})',
        );
      } else {
        _log(
          '[NotificationService]   ✗ #${i + 1}: ${when.year}-${when.month}-${when.day} at $timeStr - SKIPPED (in past)',
        );
      }
    }

    _log(
      '[NotificationService] Successfully scheduled $scheduledCount/$_hourlyRepeats reminders',
    );
  }

  /// Cancel the weekly payment summary reminder.
  Future<void> cancelWeeklyPaymentSummaryReminder() async {
    await _cancelAllReminderIds();
    _log('[NotificationService] Cancelled weekly reminder');
  }

  Future<void> scheduleTestReminder({
    required String title,
    required String body,
    int delaySeconds = 5,
  }) async {
    await _cancelAllReminderIds();
    final now = tz.TZDateTime.now(tz.local);
    final when = now.add(Duration(seconds: delaySeconds));

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'Test reminder',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _baseNotificationId + 99,
      title,
      body,
      when,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    _log('[NotificationService] Scheduled test reminder for $when');
  }

  /// Mark the weekly payment summary as confirmed.
  Future<void> confirmWeeklySummary() async {
    final now = tz.TZDateTime.now(tz.local);
    final dateKey = _dateKey(now);
    await settingsStorage.setWeeklyPaymentSummarySent(true);
    await settingsStorage.setWeeklyPaymentSummaryConfirmationDate(dateKey);
    await cancelWeeklyPaymentSummaryReminder();
    _log(
      '[NotificationService] Weekly summary marked as confirmed on $dateKey',
    );

    // Schedule next week's reminders if we have the parameters
    if (_lastWeekStartWeekday != null &&
        _lastTitle != null &&
        _lastBody != null) {
      _log('[NotificationService] Scheduling next week\'s reminders...');
      await _scheduleForNextWeek(
        weekStartWeekday: _lastWeekStartWeekday!,
        title: _lastTitle!,
        body: _lastBody!,
      );
    }
  }

  /// Internal method to schedule reminders for next week (used after confirmation)
  Future<void> _scheduleForNextWeek({
    required int weekStartWeekday,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final lastDayOfWeek = ((weekStartWeekday + 5) % 7) + 1;

    // Calculate next week's last day at 6pm
    var scheduledDate = _nextOccurrenceOfWeekday(now, lastDayOfWeek);
    scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      18,
      0,
      0,
    );

    // Always add 7 days to get next week (since we just confirmed this week)
    scheduledDate = scheduledDate.add(const Duration(days: 7));

    _log(
      '[NotificationService] Scheduling for next week starting: $scheduledDate',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'Reminder for weekly payment summary',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    for (int i = 0; i < _hourlyRepeats; i++) {
      final when = scheduledDate.add(Duration(hours: i));
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _baseNotificationId + i,
        title,
        body,
        when,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      final hourStr = when.hour.toString().padLeft(2, '0');
      final minStr = when.minute.toString().padLeft(2, '0');
      _log(
        '[NotificationService]   ✓ Next week #${i + 1}: ${when.year}-${when.month}-${when.day} at $hourStr:$minStr (ID: ${_baseNotificationId + i})',
      );
    }

    _log(
      '[NotificationService] Scheduled $_hourlyRepeats reminders for next week',
    );
  }

  /// Check if this week's payment summary has been confirmed.
  bool isWeeklySummarySent() {
    return settingsStorage.isWeeklyPaymentSummarySent();
  }

  /// Check if we're currently in the notification window (last day of week, 6pm onwards).
  bool isInNotificationWindow(int weekStartWeekday) {
    final now = tz.TZDateTime.now(tz.local);
    final lastDayOfWeek = ((weekStartWeekday + 5) % 7) + 1;
    final isLastDayOfWeek = now.weekday == lastDayOfWeek;
    final isAfter6PM = now.hour >= 18;
    final isBeforeMidnight = now.hour < 24;
    return isLastDayOfWeek && isAfter6PM && isBeforeMidnight;
  }

  /// Reset the confirmation for the next week (typically called at week start).
  Future<void> resetWeeklyConfirmation() async {
    await settingsStorage.setWeeklyPaymentSummarySent(false);
    await settingsStorage.clearWeeklyPaymentSummaryConfirmationDate();
    _log('[NotificationService] Weekly confirmation reset for new week');
  }

  /// Returns true if a prior confirmation is from a previous day and should be cleared.
  bool isConfirmationExpired() {
    final confirmedDate = settingsStorage
        .getWeeklyPaymentSummaryConfirmationDate();
    if (confirmedDate == null) return false;
    final now = tz.TZDateTime.now(tz.local);
    final today = _dateKey(now);
    return confirmedDate != today;
  }

  /// Calculate the next occurrence of a given weekday (0 = Monday, 6 = Sunday).
  tz.TZDateTime _nextOccurrenceOfWeekday(tz.TZDateTime from, int weekday) {
    var result = from;
    final target = weekday; // 1..7
    while (result.weekday != target) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  static void _onNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // Note: Can't use _log() here as this is a static method
    print('[NotificationService._onNotificationResponse] Notification tapped');
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // Note: Can't use _log() here as this is a static method in background
    print(
      '[NotificationService._onBackgroundNotificationResponse] Background notification',
    );
  }

  Future<void> _cancelAllReminderIds() async {
    for (int i = 0; i < _hourlyRepeats; i++) {
      await _flutterLocalNotificationsPlugin.cancel(_baseNotificationId + i);
    }
  }

  void _resetIfNewWeek(int weekStartWeekday) {
    final now = tz.TZDateTime.now(tz.local);
    final currentWeekStart = _startOfWeek(now, weekStartWeekday);
    final stored = settingsStorage.getWeeklyReminderWeekStartDate();
    if (stored != _dateKey(currentWeekStart)) {
      settingsStorage.setWeeklyPaymentSummarySent(false);
      settingsStorage.setWeeklyReminderWeekStartDate(
        _dateKey(currentWeekStart),
      );
    }
  }

  tz.TZDateTime _startOfWeek(tz.TZDateTime day, int weekStartWeekday) {
    // Flutter weekday: Mon=1..Sun=7
    int diff = (day.weekday - weekStartWeekday) % 7;
    return tz.TZDateTime(
      tz.local,
      day.year,
      day.month,
      day.day,
    ).subtract(Duration(days: diff));
  }

  String _dateKey(tz.TZDateTime day) => '${day.year}-${day.month}-${day.day}';

  String _weekdayName(int weekday) {
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday];
  }

  Future<void> _initializePlugin() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
  }
}
