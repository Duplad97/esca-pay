import 'package:esca_pay/shared/themes/theme_manager.dart';
import 'package:flutter/material.dart';

import 'app/esca_pay_app.dart';
import 'app/app_settings_controller.dart';
import 'shared/storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStorage();
  await themeManager.init();
  appSettingsController.loadFromStorage();
  runApp(const EscaPayApp());
}
