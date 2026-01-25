import 'package:hive/hive.dart';

class SettingsStorage {
  static const boxName = 'settings';
  static const _hourlyWageKey = 'hourlyWage';
  static const _perRoomBonusKey = 'perRoomBonus';
  static const _jumpInRateKey = 'jumpInRate';
  static const _eventFineKey = 'eventFine';
  static const _weekStartWeekdayKey = 'weekStartWeekday';
  static const _localeCodeKey = 'localeCode';
  static const _bestFlappyScoreKey = 'bestFlappyScore';
  static const _weeklyPaymentSummarySentKey = 'weeklyPaymentSummarySent';
  static const _weeklyReminderWeekStartDateKey = 'weeklyReminderWeekStartDate';
  static const _weeklyPaymentSummaryConfirmationDateKey =
      'weeklyPaymentSummaryConfirmationDate';
  static const _lastAppLaunchTimeKey = 'lastAppLaunchTime';

  Box<dynamic>? _box;

  bool get isReady => _box != null;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(boxName);
  }

  double? getHourlyWage() {
    final v = _box?.get(_hourlyWageKey);
    return (v is num) ? v.toDouble() : null;
  }

  double? getPerRoomBonus() {
    final v = _box?.get(_perRoomBonusKey);
    return (v is num) ? v.toDouble() : null;
  }

  double? getJumpInRate() {
    final v = _box?.get(_jumpInRateKey);
    return (v is num) ? v.toDouble() : null;
  }

  double? getEventFine() {
    final v = _box?.get(_eventFineKey);
    return (v is num) ? v.toDouble() : null;
  }

  int? getWeekStartWeekday() {
    final v = _box?.get(_weekStartWeekdayKey);
    if (v is! int) return null;
    if (v < DateTime.monday || v > DateTime.sunday) return null;
    return v;
  }

  String? getLocaleCode() {
    final v = _box?.get(_localeCodeKey);
    if (v is! String || v.trim().isEmpty) return null;
    return v;
  }

  int? getBestFlappyScore() {
    final v = _box?.get(_bestFlappyScoreKey);
    if (v is! int) return null;
    if (v < 0) return 0;
    return v;
  }

  Future<void> setHourlyWage(double value) async {
    await _box?.put(_hourlyWageKey, value);
  }

  Future<void> setPerRoomBonus(double value) async {
    await _box?.put(_perRoomBonusKey, value);
  }

  Future<void> setJumpInRate(double value) async {
    await _box?.put(_jumpInRateKey, value);
  }

  Future<void> setEventFine(double value) async {
    await _box?.put(_eventFineKey, value);
  }

  Future<void> setWeekStartWeekday(int weekday) async {
    final value = weekday.clamp(DateTime.monday, DateTime.sunday);
    await _box?.put(_weekStartWeekdayKey, value);
  }

  Future<void> setLocaleCode(String? localeCode) async {
    final code = localeCode?.trim();
    if (code == null || code.isEmpty) {
      await _box?.delete(_localeCodeKey);
      return;
    }
    await _box?.put(_localeCodeKey, code);
  }

  Future<void> setBestFlappyScore(int value) async {
    await _box?.put(_bestFlappyScoreKey, value.clamp(0, 999999));
  }

  bool isWeeklyPaymentSummarySent() {
    final v = _box?.get(_weeklyPaymentSummarySentKey);
    return v is bool ? v : false;
  }

  Future<void> setWeeklyPaymentSummarySent(bool value) async {
    await _box?.put(_weeklyPaymentSummarySentKey, value);
  }

  String? getWeeklyReminderWeekStartDate() {
    final v = _box?.get(_weeklyReminderWeekStartDateKey);
    return v is String && v.isNotEmpty ? v : null;
  }

  Future<void> setWeeklyReminderWeekStartDate(String dateKey) async {
    await _box?.put(_weeklyReminderWeekStartDateKey, dateKey);
  }

  String? getWeeklyPaymentSummaryConfirmationDate() {
    final v = _box?.get(_weeklyPaymentSummaryConfirmationDateKey);
    return v is String && v.isNotEmpty ? v : null;
  }

  Future<void> setWeeklyPaymentSummaryConfirmationDate(String dateKey) async {
    await _box?.put(_weeklyPaymentSummaryConfirmationDateKey, dateKey);
  }

  Future<void> clearWeeklyPaymentSummaryConfirmationDate() async {
    await _box?.delete(_weeklyPaymentSummaryConfirmationDateKey);
  }

  int? getLastAppLaunchTime() {
    final v = _box?.get(_lastAppLaunchTimeKey);
    return v is int ? v : null;
  }

  Future<void> setLastAppLaunchTime(int timestamp) async {
    await _box?.put(_lastAppLaunchTimeKey, timestamp);
  }

  /// Force flush all pending writes to disk
  Future<void> flush() async {
    await _box?.flush();
  }
}
