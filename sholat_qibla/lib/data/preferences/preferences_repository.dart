import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/calculation_constants.dart';
import '../../engine/models/calculation_method.dart';
import '../../engine/models/madhab.dart';
import '../../engine/models/prayer_times.dart';

/// Repository preferensi pengguna berbasis SharedPreferences.
///
/// Menyimpan: metode kalkulasi, kota terpilih, madzhab, offset menit
/// per waktu sholat, serta status onboarding. Dilengkapi migrasi schema
/// antar versi.
class PreferencesRepository {
  PreferencesRepository(this._prefs);

  /// Versi schema penyimpanan saat ini.
  static const int schemaVersion = 1;

  // Kunci penyimpanan (v1).
  static const _kSchemaVersion = 'schema_version';
  static const _kMethod = 'calc_method';
  static const _kMadhab = 'madhab';
  static const _kCityId = 'city_id';
  static const _kUseGps = 'use_gps';
  static const _kOffsetPrefix = 'offset_'; // offset_fajr, offset_dhuhr, ...
  static const _kOnboardingDone = 'onboarding_done';

  // Kunci lama (v0) — dipertahankan hanya untuk migrasi.
  static const _kLegacyMethodIndex = 'method_index';

  final SharedPreferences _prefs;

  /// Membuat repository dan menjalankan migrasi schema bila diperlukan.
  static Future<PreferencesRepository> create(
      {SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final repo = PreferencesRepository(p);
    await repo._migrate();
    return repo;
  }

  Future<void> _migrate() async {
    final stored = _prefs.getInt(_kSchemaVersion) ?? 0;
    if (stored >= schemaVersion) return;

    if (stored < 1) {
      // v0 -> v1: metode disimpan sebagai index int, ubah ke nama enum.
      final legacyIndex = _prefs.getInt(_kLegacyMethodIndex);
      if (legacyIndex != null) {
        final method = (legacyIndex >= 0 &&
                legacyIndex < CalculationMethod.values.length)
            ? CalculationMethod.values[legacyIndex]
            : CalculationMethod.kemenag;
        await _prefs.setString(_kMethod, method.name);
        await _prefs.remove(_kLegacyMethodIndex);
      }
    }

    await _prefs.setInt(_kSchemaVersion, schemaVersion);
  }

  // -------------------------------------------------------------------
  // Metode kalkulasi
  // -------------------------------------------------------------------

  CalculationMethod getCalculationMethod() => CalculationMethod.fromName(
      _prefs.getString(_kMethod) ?? CalculationConstants.defaultMethodName);

  Future<void> setCalculationMethod(CalculationMethod method) =>
      _prefs.setString(_kMethod, method.name);

  // -------------------------------------------------------------------
  // Madzhab
  // -------------------------------------------------------------------

  Madhab getMadhab() => Madhab.fromName(
      _prefs.getString(_kMadhab) ?? CalculationConstants.defaultMadhabName);

  Future<void> setMadhab(Madhab madhab) =>
      _prefs.setString(_kMadhab, madhab.name);

  // -------------------------------------------------------------------
  // Kota terpilih & mode GPS
  // -------------------------------------------------------------------

  String getSelectedCityId() =>
      _prefs.getString(_kCityId) ?? CalculationConstants.defaultCityId;

  Future<void> setSelectedCityId(String cityId) =>
      _prefs.setString(_kCityId, cityId);

  bool getUseGps() => _prefs.getBool(_kUseGps) ?? true;

  Future<void> setUseGps(bool value) => _prefs.setBool(_kUseGps, value);

  // -------------------------------------------------------------------
  // Offset menit per waktu sholat
  // -------------------------------------------------------------------

  int getOffset(Prayer prayer) =>
      _prefs.getInt('$_kOffsetPrefix${prayer.name}') ?? 0;

  Future<void> setOffset(Prayer prayer, int minutes) =>
      _prefs.setInt('$_kOffsetPrefix${prayer.name}', minutes);

  /// Semua offset dalam bentuk map, siap dipakai [PrayerTimes.withOffsets].
  Map<Prayer, int> getAllOffsets() =>
      {for (final p in Prayer.values) p: getOffset(p)};

  // -------------------------------------------------------------------
  // Onboarding
  // -------------------------------------------------------------------

  bool isOnboardingDone() => _prefs.getBool(_kOnboardingDone) ?? false;

  Future<void> setOnboardingDone() => _prefs.setBool(_kOnboardingDone, true);

  /// Menandai onboarding belum selesai (untuk menampilkannya ulang).
  Future<void> resetOnboarding() => _prefs.setBool(_kOnboardingDone, false);
}
