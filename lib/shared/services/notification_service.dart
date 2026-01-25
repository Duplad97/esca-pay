import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../storage/storage.dart';

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

  Future<void> init() async {
    print('[NotificationService.init] Starting initialization');
    tzdata.initializeTimeZones();
    await _initializePlugin();
    print('[NotificationService.init] Plugin initialized');

    // Request iOS permissions
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    print('[NotificationService.init] iOS permissions requested');
  }

  /// Schedule the weekly payment summary notification.
  /// Runs at 6 PM on the last day of the week, repeating hourly until confirmed.
  Future<void> scheduleWeeklyPaymentSummaryReminder({
    required int weekStartWeekday,
    required String title,
    required String body,
  }) async {
    await _cancelAllReminderIds();

    // Reset weekly confirmation when a new week starts
    _resetIfNewWeek(weekStartWeekday);
    if (settingsStorage.isWeeklyPaymentSummarySent()) {
      print(
        '[NotificationService] Weekly summary already confirmed; skipping schedule',
      );
      return;
    }

    // Calculate last day of week (1=Mon..7=Sun)
    final lastDayOfWeek = ((weekStartWeekday + 5) % 7) + 1;

    final now = tz.TZDateTime.now(tz.local);
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
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
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
    }

    print(
      '[NotificationService] Scheduled weekly reminder starting $scheduledDate for $_hourlyRepeats hours',
    );
  }

  /// Cancel the weekly payment summary reminder.
  Future<void> cancelWeeklyPaymentSummaryReminder() async {
    await _cancelAllReminderIds();
    print('[NotificationService] Cancelled weekly reminder');
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
    print('[NotificationService] Scheduled test reminder for $when');
  }

  /// Mark the weekly payment summary as confirmed.
  Future<void> confirmWeeklySummary() async {
    final now = tz.TZDateTime.now(tz.local);
    final dateKey = _dateKey(now);
    await settingsStorage.setWeeklyPaymentSummarySent(true);
    await settingsStorage.setWeeklyPaymentSummaryConfirmationDate(dateKey);
    await cancelWeeklyPaymentSummaryReminder();
    print(
      '[NotificationService] Weekly summary marked as confirmed on $dateKey',
    );
    // Notify listeners that confirmation has occurred
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
    return isLastDayOfWeek && isAfter6PM;
  }

  /// Reset the confirmation for the next week (typically called at week start).
  Future<void> resetWeeklyConfirmation() async {
    await settingsStorage.setWeeklyPaymentSummarySent(false);
    await settingsStorage.clearWeeklyPaymentSummaryConfirmationDate();
    print('[NotificationService] Weekly confirmation reset for new week');
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
    print('[NotificationService._onNotificationResponse] Notification tapped');
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
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
