import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_definition.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static const String _themePrefKey = 'theme_preference';

  late SharedPreferences _prefs;

  final List<ThemeDefinition> _themes = [
    //const ThemeDefinition(
    //  name: 'default',
    //  seedColor: Colors.grey,
    //  scaffoldBackgroundColor: Color(0xFFF5F5F5),
    //  logo: 'lib/assets/themes/default/logo.png',
    //  splashLogo: 'lib/assets/themes/default/splash_logo.png',
    //  appIcon: 'lib/assets/themes/default/app_icon.png',
    //  character: 'lib/assets/themes/default/character.png',
    //),
    const ThemeDefinition(
      name: 'girly',
      seedColor: Color(0xFFE91E63),
      scaffoldBackgroundColor: Color(0xFFFFF7FB),
      logo: 'lib/assets/themes/girly/logo.png',
      splashLogo: 'lib/assets/themes/girly/splash_logo.png',
      appIcon: 'lib/assets/themes/girly/app_icon.png',
      character: 'lib/assets/themes/girly/character.png',
    ),
    const ThemeDefinition(
      name: 'boy',
      seedColor: Colors.blue,
      scaffoldBackgroundColor: Color(0xFFF0F8FF),
      logo: 'lib/assets/themes/boy/logo.png',
      splashLogo: 'lib/assets/themes/boy/splash_logo.png',
      appIcon: 'lib/assets/themes/boy/app_icon.png',
      character: 'lib/assets/themes/boy/character.png',
    ),
  ];

  late ThemeDefinition _currentTheme;

  ThemeDefinition get currentTheme => _currentTheme;
  List<ThemeDefinition> get themes => _themes;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final themeName = _prefs.getString(_themePrefKey) ?? 'girly';
    _currentTheme = _themes.firstWhere((theme) => theme.name == themeName);
  }

  ThemeData get themeData {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _currentTheme.seedColor,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _currentTheme.scaffoldBackgroundColor,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(224),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }

  Future<void> setTheme(String themeName) async {
    _currentTheme = _themes.firstWhere((theme) => theme.name == themeName);
    await _prefs.setString(_themePrefKey, themeName);
    notifyListeners();

    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName(themeName);
      }
    } catch (e) {
      // ignore
    }
  }
}

final themeManager = ThemeManager();
