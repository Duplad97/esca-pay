import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../features/splash/splash_page.dart';
import 'app_settings_controller.dart';

class EscaPayApp extends StatelessWidget {
  const EscaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFE91E63);
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

    return ValueListenableBuilder<Locale?>(
      valueListenable: appSettingsController.localeListenable,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: const Color(0xFFFFF7FB),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.88),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
          ),
          home: const SplashPage(),
        );
      },
    );
  }
}
