import 'package:flutter/material.dart';

import 'app/esca_pay_app.dart';
import 'app/app_settings_controller.dart';
import 'shared/storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStorage();
  appSettingsController.loadFromStorage();
  runApp(const EscaPayApp());
}
