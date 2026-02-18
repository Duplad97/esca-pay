import 'package:esca_pay/shared/themes/theme_manager.dart';
import 'package:esca_pay/shared/services/notification_service.dart';
import 'package:esca_pay/shared/services/profile_migration_service.dart';
import 'package:flutter/material.dart';

import 'app/esca_pay_app.dart';
import 'app/app_settings_controller.dart';
import 'shared/storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStorage();
  await migrateWagesToPaymentProfiles(
    settingsStorage,
    paymentProfilesStorage,
    dayEntriesStorage,
  );
  await themeManager.init();
  await NotificationService().init();
  appSettingsController.loadFromStorage();

  // Check for notification response when app launches (important for iOS)
  print('[main] Checking for notification responses on startup');

  runApp(const EscaPayApp());
}
