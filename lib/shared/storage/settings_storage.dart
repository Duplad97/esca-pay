import 'package:hive/hive.dart';

class SettingsStorage {
  static const boxName = 'settings';
  static const _hourlyWageKey = 'hourlyWage';
  static const _perRoomBonusKey = 'perRoomBonus';
  static const _weekStartWeekdayKey = 'weekStartWeekday';
  static const _localeCodeKey = 'localeCode';
  static const _bestFlappyScoreKey = 'bestFlappyScore';

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
}
