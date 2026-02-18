import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/pay_calendar/models/payment_profile.dart';

class PaymentProfilesStorage {
  static const boxName = 'payment_profiles';
  static const defaultProfileIdKey = 'default_profile_id';

  Box<PaymentProfile>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<PaymentProfile>(boxName);
  }

  /// Get all payment profiles
  List<PaymentProfile> loadAll() {
    final box = _box;
    if (box == null) return <PaymentProfile>[];
    return box.values.toList();
  }

  /// Get a profile by ID
  PaymentProfile? getProfile(String profileId) {
    final box = _box;
    if (box == null) return null;
    return box.get(profileId);
  }

  /// Create a new payment profile
  Future<PaymentProfile> createProfile({
    required String name,
    required double hourlyWage,
    required double perRoomBonus,
    required double jumpInRate,
    required double eventFine,
  }) async {
    const uuid = Uuid();
    final profile = PaymentProfile(
      id: uuid.v4(),
      name: name,
      hourlyWage: hourlyWage,
      perRoomBonus: perRoomBonus,
      jumpInRate: jumpInRate,
      eventFine: eventFine,
      createdAt: DateTime.now(),
    );
    await _box?.put(profile.id, profile);
    return profile;
  }

  /// Update an existing profile
  Future<void> updateProfile(PaymentProfile profile) async {
    await _box?.put(profile.id, profile);
  }

  /// Delete a profile by ID
  Future<void> deleteProfile(String profileId) async {
    await _box?.delete(profileId);
  }

  /// Get default profile ID from SharedPreferences
  Future<String?> getDefaultProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(defaultProfileIdKey);
  }

  /// Set default profile
  Future<void> setDefaultProfileId(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(defaultProfileIdKey, profileId);
  }
}
