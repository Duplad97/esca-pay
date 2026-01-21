import 'package:esca_pay/shared/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:esca_pay/l10n/app_localizations.dart';

import '../features/splash/splash_page.dart';
import 'app_settings_controller.dart';

class EscaPayApp extends StatelessWidget {
  const EscaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appSettingsController.localeListenable,
      builder: (context, locale, _) {
        return ListenableBuilder(
          listenable: themeManager,
          builder: (context, _) {
            return MaterialApp(
              locale: locale,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: themeManager.themeData,
              home: const SplashPage(),
            );
          },
        );
      },
    );
  }
}
