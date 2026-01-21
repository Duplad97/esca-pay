import 'package:esca_pay/l10n/app_localizations.dart';
import 'package:esca_pay/shared/themes/theme_definition.dart';
import 'package:esca_pay/shared/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeSelectorPage extends StatefulWidget {
  const ThemeSelectorPage({super.key});

  @override
  State<ThemeSelectorPage> createState() => _ThemeSelectorPageState();
}

class _ThemeSelectorPageState extends State<ThemeSelectorPage> {
  @override
  void initState() {
    super.initState();
    themeManager.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  String _localizedThemeName(BuildContext context, String themeName) {
    final l10n = AppLocalizations.of(context)!;
    switch (themeName) {
      case 'default':
        return l10n.theme_default;
      case 'girly':
        return l10n.theme_girly;
      case 'boy':
        return l10n.theme_boy;
      default:
        return themeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.themesTooltip),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: themeManager.themes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final theme = themeManager.themes[index];
          return ThemePreview(
            theme: theme,
            name: _localizedThemeName(context, theme.name),
            isSelected: theme.name == themeManager.currentTheme.name,
            onTap: () {
              HapticFeedback.lightImpact();
              themeManager.setTheme(theme.name);
            },
          );
        },
      ),
    );
  }
}

class ThemePreview extends StatelessWidget {
  final ThemeDefinition theme;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreview({
    super.key,
    required this.theme,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary,
                  width: 3,
                )
              : Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Image.asset(
                    theme.logo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.seedColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(21),
                  ),
                ),
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
