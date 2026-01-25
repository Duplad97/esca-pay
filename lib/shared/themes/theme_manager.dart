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
  bool _isChangingIcon = false; // Flag to prevent concurrent changes
  String?
  _currentIconName; // Track currently active icon (null = primary/girly)

  final List<ThemeDefinition> _themes = [
    //const ThemeDefinition(
    //  name: 'default',
    //  seedColor: Colors.grey,
    //  scaffoldBackgroundColor: Color(0xFFF5F5F5),
    //  gradientColors: [Color(0xFFF5F5F5), Color(0xFFEBEBEB)],
    //  logo: 'lib/assets/themes/default/logo.png',
    //  splashLogo: 'lib/assets/themes/default/splash_logo.png',
    //  appIcon: 'lib/assets/themes/default/app_icon.png',
    //  character: 'lib/assets/themes/default/character.png',
    //),
    const ThemeDefinition(
      name: 'girly',
      seedColor: Color(0xFFE91E63),
      scaffoldBackgroundColor: Color(0xFFFFF7FB),
      gradientColors: [Color(0xFFFFF7FB), Color(0xFFFFEEF8), Color(0xFFFCE4EC)],
      logo: 'lib/assets/themes/girly/logo.png',
      splashLogo: 'lib/assets/themes/girly/splash_logo.png',
      appIcon: 'lib/assets/themes/girly/app_icon.png',
      character: 'lib/assets/themes/girly/character.png',
    ),
    const ThemeDefinition(
      name: 'blue',
      seedColor: Colors.blue,
      scaffoldBackgroundColor: Color(0xFFF0F8FF),
      gradientColors: [Color(0xFFF0F8FF), Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
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
    // Restore the icon state (null for girly, 'blue' for blue)
    _currentIconName = themeName == 'girly' ? null : themeName;
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
    // Prevent concurrent icon changes
    if (_isChangingIcon) {
      print('[ThemeManager] Icon change already in progress, ignoring request');
      return;
    }

    // Calculate what the icon name should be (null for girly, 'blue' for blue)
    final targetIconName = themeName == 'girly' ? null : themeName;

    // Skip if icon is already set to this theme
    if (_currentIconName == targetIconName) {
      print('[ThemeManager] Icon already set to $themeName, skipping change');
      _currentTheme = _themes.firstWhere((theme) => theme.name == themeName);
      await _prefs.setString(_themePrefKey, themeName);
      notifyListeners();
      return;
    }

    _currentTheme = _themes.firstWhere((theme) => theme.name == themeName);
    await _prefs.setString(_themePrefKey, themeName);
    notifyListeners();

    try {
      print('[ThemeManager] Attempting to change app icon to: $themeName');

      _isChangingIcon = true;

      // Add a small delay to ensure app is in proper state
      await Future.delayed(const Duration(milliseconds: 500));

      if (themeName == 'girly') {
        // Reset to primary icon (null resets to AppIcon)
        await FlutterDynamicIcon.setAlternateIconName(null);
        print('[ThemeManager] Successfully changed app icon to girly');
      } else if (themeName == 'blue') {
        // Switch to blue alternate icon
        await FlutterDynamicIcon.setAlternateIconName('blue');
        print('[ThemeManager] Successfully changed app icon to blue');
      }

      _currentIconName = targetIconName;
    } catch (e) {
      print('[ThemeManager] Failed to change app icon: $e');
    } finally {
      _isChangingIcon = false;
    }
  }
}

final themeManager = ThemeManager();
