import 'package:hive/hive.dart';

class SettingsStorage {
  static const boxName = 'settings';
  static const _hourlyWageKey = 'hourlyWage';
  static const _perRoomBonusKey = 'perRoomBonus';

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

  Future<void> setHourlyWage(double value) async {
    await _box?.put(_hourlyWageKey, value);
  }

  Future<void> setPerRoomBonus(double value) async {
    await _box?.put(_perRoomBonusKey, value);
  }
}

