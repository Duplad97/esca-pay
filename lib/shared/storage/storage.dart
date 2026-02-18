import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'day_entries_storage.dart';
import 'settings_storage.dart';
import 'payment_profiles_storage.dart';
import '../../features/pay_calendar/models/payment_profile.dart';

final SettingsStorage settingsStorage = SettingsStorage();
final DayEntriesStorage dayEntriesStorage = DayEntriesStorage();
final PaymentProfilesStorage paymentProfilesStorage = PaymentProfilesStorage();

Future<void> initStorage() async {
  try {
    await Hive.initFlutter();
  } on MissingPluginException catch (e) {
    if (kDebugMode) {
      debugPrint(
        'Storage init failed ($e). If you just added a new plugin, do a full restart (stop the app and run again).',
      );
    }
    rethrow;
  }

  // Register adapters before initializing storages
  Hive.registerAdapter(PaymentProfileAdapter());

  await settingsStorage.init();
  await dayEntriesStorage.init();
  await paymentProfilesStorage.init();
}
