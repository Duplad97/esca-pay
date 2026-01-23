import 'package:flutter/material.dart';

class ThemeDefinition {
  final String name;
  final Color seedColor;
  final Color scaffoldBackgroundColor;
  final List<Color> gradientColors;
  final String logo;
  final String splashLogo;
  final String appIcon;
  final String character;

  const ThemeDefinition({
    required this.name,
    required this.seedColor,
    required this.scaffoldBackgroundColor,
    required this.gradientColors,
    required this.logo,
    required this.splashLogo,
    required this.appIcon,
    required this.character,
  });

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gradientColors,
  );
}
