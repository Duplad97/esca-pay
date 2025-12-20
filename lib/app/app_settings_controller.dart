import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../shared/storage/storage.dart';

class AppSettingsController {
  final ValueNotifier<Locale?> _locale = ValueNotifier<Locale?>(null);

  ValueListenable<Locale?> get localeListenable => _locale;
  Locale? get locale => _locale.value;

  void loadFromStorage() {
    final code = settingsStorage.getLocaleCode();
    _locale.value = _localeFromCode(code);
  }

  Future<void> setLocaleCode(String? code) async {
    await settingsStorage.setLocaleCode(code);
    _locale.value = _localeFromCode(code);
  }

  static Locale? _localeFromCode(String? code) {
    final c = code?.trim().toLowerCase();
    if (c == null || c.isEmpty || c == 'system') return null;
    if (c == 'en') return const Locale('en');
    if (c == 'hu') return const Locale('hu');
    return null;
  }
}

final AppSettingsController appSettingsController = AppSettingsController();
