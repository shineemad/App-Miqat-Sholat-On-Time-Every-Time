import '../../data/cities/city_repository.dart';
import '../../data/preferences/preferences_repository.dart';
import '../../engine/models/calculation_method.dart';
import '../../engine/models/city.dart';
import '../../engine/models/madhab.dart';
import '../../engine/models/prayer_times.dart';
import '../../notifications/background_refresh_coordinator.dart';
import '../../notifications/models/notification_settings.dart';

/// Snapshot seluruh pengaturan untuk ditampilkan di layar Settings.
class SettingsSnapshot {
  const SettingsSnapshot({
    required this.method,
    required this.madhab,
    required this.useGps,
    required this.selectedCity,
    required this.offsets,
    required this.notifications,
  });

  final CalculationMethod method;
  final Madhab madhab;
  final bool useGps;

  /// Kota terpilih (bisa null bila id tidak ditemukan di database).
  final City? selectedCity;
  final Map<Prayer, int> offsets;
  final NotificationSettings notifications;
}

/// Controller layar Pengaturan (§3.6): menyatukan preferensi sholat,
/// pengaturan notifikasi, dan lokasi. Setiap perubahan yang memengaruhi
/// jadwal akan menandai [BackgroundRefreshCoordinator] agar notifikasi
/// dijadwalkan ulang saat aplikasi berikutnya aktif.
class SettingsController {
  SettingsController({
    required PreferencesRepository preferences,
    required NotificationSettingsRepository notificationSettings,
    required CityRepository cityRepository,
    required BackgroundRefreshCoordinator refreshCoordinator,
  })  : _prefs = preferences,
        _notif = notificationSettings,
        _cities = cityRepository,
        _refresh = refreshCoordinator;

  final PreferencesRepository _prefs;
  final NotificationSettingsRepository _notif;
  final CityRepository _cities;
  final BackgroundRefreshCoordinator _refresh;

  /// Memuat snapshot pengaturan saat ini.
  Future<SettingsSnapshot> load() async {
    final city = await _cities.getById(_prefs.getSelectedCityId());
    return SettingsSnapshot(
      method: _prefs.getCalculationMethod(),
      madhab: _prefs.getMadhab(),
      useGps: _prefs.getUseGps(),
      selectedCity: city,
      offsets: _prefs.getAllOffsets(),
      notifications: _notif.load(),
    );
  }

  Future<List<City>> allCities() => _cities.getAllCities();

  Future<List<City>> searchCities(String query) => _cities.search(query);

  // --- Sholat ---

  Future<void> setMethod(CalculationMethod method) async {
    await _prefs.setCalculationMethod(method);
    await _invalidate();
  }

  Future<void> setMadhab(Madhab madhab) async {
    await _prefs.setMadhab(madhab);
    await _invalidate();
  }

  Future<void> setOffset(Prayer prayer, int minutes) async {
    await _prefs.setOffset(prayer, minutes);
    await _invalidate();
  }

  // --- Lokasi ---

  Future<void> setUseGps(bool value) async {
    await _prefs.setUseGps(value);
    await _invalidate();
  }

  Future<void> selectCity(String cityId) async {
    await _prefs.setSelectedCityId(cityId);
    await _prefs.setUseGps(false);
    await _invalidate();
  }

  // --- Notifikasi ---

  Future<void> setAdhanMode(AdhanMode mode) async {
    final current = _notif.load();
    await _notif.save(current.copyWith(mode: mode));
    await _invalidate();
  }

  Future<void> togglePrayerNotification(Prayer prayer, bool enabled) async {
    final current = _notif.load();
    final updated = {...current.enabledPrayers};
    if (enabled) {
      updated.add(prayer);
    } else {
      updated.remove(prayer);
    }
    await _notif.save(current.copyWith(enabledPrayers: updated));
    await _invalidate();
  }

  /// Aktif/nonaktifkan pengingat pra-adzan (alarm).
  Future<void> setPreAdhanEnabled(bool enabled) async {
    await _notif.save(_notif.load().copyWith(preAdhanEnabled: enabled));
    await _invalidate();
  }

  /// Mengatur jeda pengingat pra-adzan (menit sebelum adzan).
  Future<void> setPreAdhanMinutes(int minutes) async {
    await _notif.save(_notif.load().copyWith(preAdhanMinutes: minutes));
    await _invalidate();
  }

  /// Menandai jadwal notifikasi perlu disusun ulang.
  Future<void> _invalidate() => _refresh.invalidate();

  /// Mereset status onboarding agar alur perkenalan tampil lagi.
  Future<void> resetOnboarding() => _prefs.resetOnboarding();
}
