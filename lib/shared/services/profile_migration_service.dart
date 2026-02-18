import 'package:esca_pay/shared/storage/payment_profiles_storage.dart';
import 'package:esca_pay/shared/storage/settings_storage.dart';
import 'package:esca_pay/shared/storage/day_entries_storage.dart';

/// Migrates existing wage settings to payment profiles if needed
Future<void> migrateWagesToPaymentProfiles(
  SettingsStorage settingsStorage,
  PaymentProfilesStorage paymentProfilesStorage,
  DayEntriesStorage dayEntriesStorage,
) async {
  // Check if profiles already exist
  final existingProfiles = paymentProfilesStorage.loadAll();
  if (existingProfiles.isNotEmpty) {
    return; // Already migrated
  }

  // Get current rates from settings
  final hourlyWage = settingsStorage.getHourlyWage() ?? 1600.0;
  final perRoomBonus = settingsStorage.getPerRoomBonus() ?? 600.0;
  final jumpInRate = settingsStorage.getJumpInRate() ?? 2300.0;
  final eventFine = settingsStorage.getEventFine() ?? 5000.0;

  // Create a default profile from current settings
  final defaultProfile = await paymentProfilesStorage.createProfile(
    name: 'Default',
    hourlyWage: hourlyWage,
    perRoomBonus: perRoomBonus,
    jumpInRate: jumpInRate,
    eventFine: eventFine,
  );

  // Set this as the default profile
  await paymentProfilesStorage.setDefaultProfileId(defaultProfile.id);

  // Associate all existing days without a profile to this default profile
  await dayEntriesStorage.associateUnassignedDaysWithProfile(defaultProfile.id);
}
