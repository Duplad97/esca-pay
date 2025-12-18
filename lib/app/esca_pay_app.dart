import 'package:flutter/material.dart';

import '../features/splash/splash_page.dart';

class EscaPayApp extends StatelessWidget {
  const EscaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFE91E63);
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

    return MaterialApp(
      title: 'EscaPay',
      debugShowCheckedModeBanner: false,
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
  }
}
