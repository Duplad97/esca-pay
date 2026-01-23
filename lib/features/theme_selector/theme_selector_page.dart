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
        centerTitle: true,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeManager.currentTheme.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              itemCount: themeManager.themes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
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
          ),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 3)
              : Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1.5,
                ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 16 : 8,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.gradientColors,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Image.asset(theme.logo, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.seedColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.check_circle,
                                color: theme.seedColor,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
