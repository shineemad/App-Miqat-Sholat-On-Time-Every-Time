import 'package:shared_preferences/shared_preferences.dart';

import '../location/location_mode.dart';

// ── Key constants ──────────────────────────────────────────────────────────
// Semua key dikelompokkan di sini agar mudah diaudit dan tidak typo.

const _kCalculationMethod = 'pref_calculation_method';
const _kAshrMadhab = 'pref_ashr_madhab';
const _kHijriOffset = 'pref_hijri_offset';
const _kLocationMode = 'pref_location_mode';
const _kSelectedCityId = 'pref_selected_city_id';
const _kOnboardingDone = 'pref_onboarding_done';
const _kTheme = 'pref_theme';
const _kLanguage = 'pref_language';
const _kTextScale = 'pref_text_scale';
const _kHighContrast = 'pref_high_contrast';
const _kNumberFormat = 'pref_number_format';
const _kHideNotifContent = 'pref_hide_notif_content';
const _kPreAdhanMinutes = 'pref_pre_adhan_minutes';
const _kRespectDnd = 'pref_respect_dnd';

// Notifikasi: aktif per-sholat
const _kNotifSubuh = 'pref_notif_subuh';
const _kNotifDzuhur = 'pref_notif_dzuhur';
const _kNotifAshar = 'pref_notif_ashar';
const _kNotifMaghrib = 'pref_notif_maghrib';
const _kNotifIsya = 'pref_notif_isya';

// Notifikasi: suara per-sholat
const _kSoundSubuh = 'pref_sound_subuh';
const _kSoundDzuhur = 'pref_sound_dzuhur';
const _kSoundAshar = 'pref_sound_ashar';
const _kSoundMaghrib = 'pref_sound_maghrib';
const _kSoundIsya = 'pref_sound_isya';

// Koreksi menit per-sholat (int, bisa negatif)
const _kCorSubuh = 'pref_cor_subuh';
const _kCorDzuhur = 'pref_cor_dzuhur';
const _kCorAshar = 'pref_cor_ashar';
const _kCorMaghrib = 'pref_cor_maghrib';
const _kCorIsya = 'pref_cor_isya';

// Mark-as-prayed: daftar nama sholat yang sudah ditandai hari ini
// Disimpan sebagai "2026-07-03|Subuh,Dzuhur"
const _kMarkedPrayed = 'pref_marked_prayed';

/// Wrapper terpusat untuk semua preferensi aplikasi menggunakan SharedPreferences.
///
/// Semua nilai memiliki default yang sesuai dengan PRD:
/// - Metode perhitungan default: Kemenag
/// - Madzhab Ashar default: Syafi'i
/// - Semua notifikasi aktif secara default
/// - Suara default: adhan untuk Subuh/Maghrib/Isya, senyap untuk Dzuhur/Ashar
/// - Tema: mengikuti sistem
/// - Bahasa: Indonesia
///
/// Gunakan [AppPreferences.create] sebagai factory async agar SharedPreferences
/// dapat diinisialisasi sebelum digunakan.
class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences._(this._prefs);

  /// Factory async — panggil ini satu kali saat app startup.
  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences._(prefs);
  }

  // ── Metode perhitungan & madzhab ──────────────────────────────────────────

  /// Metode perhitungan waktu sholat. Default: "Kemenag" (akurat untuk Indonesia).
  String get calculationMethod =>
      _prefs.getString(_kCalculationMethod) ?? 'Kemenag';

  Future<void> setCalculationMethod(String method) =>
      _prefs.setString(_kCalculationMethod, method);

  /// Madzhab penentuan waktu Ashar. "Shafii" (shadow = 1×) atau "Hanafi" (2×).
  String get ashrMadhab => _prefs.getString(_kAshrMadhab) ?? 'Shafii';

  Future<void> setAshrMadhab(String madhab) =>
      _prefs.setString(_kAshrMadhab, madhab);

  // ── Hijriah ───────────────────────────────────────────────────────────────

  /// Offset tanggal Hijriah dalam hari (-2 .. +2). Default 0.
  int get hijriOffset => _prefs.getInt(_kHijriOffset) ?? 0;

  Future<void> setHijriOffset(int offset) =>
      _prefs.setInt(_kHijriOffset, offset.clamp(-2, 2));

  // ── Lokasi ────────────────────────────────────────────────────────────────

  /// Mode lokasi: GPS atau manual. Default: GPS.
  LocationMode get locationMode {
    final raw = _prefs.getString(_kLocationMode);
    if (raw == 'manual') return LocationMode.manual;
    return LocationMode.gps;
  }

  Future<void> setLocationMode(LocationMode mode) =>
      _prefs.setString(_kLocationMode, mode.name);

  /// ID kota yang dipilih secara manual. Null jika belum dipilih.
  String? get selectedCityId => _prefs.getString(_kSelectedCityId);

  Future<void> setSelectedCityId(String cityId) =>
      _prefs.setString(_kSelectedCityId, cityId);

  // ── Onboarding ────────────────────────────────────────────────────────────

  bool get onboardingCompleted => _prefs.getBool(_kOnboardingDone) ?? false;

  Future<void> setOnboardingCompleted() =>
      _prefs.setBool(_kOnboardingDone, true);

  // ── Tampilan ──────────────────────────────────────────────────────────────

  /// Tema aplikasi: "system", "light", atau "dark". Default: "system".
  String get theme => _prefs.getString(_kTheme) ?? 'system';

  Future<void> setTheme(String theme) => _prefs.setString(_kTheme, theme);

  /// Bahasa: "id", "en", atau "ar". Default: "id".
  String get language => _prefs.getString(_kLanguage) ?? 'id';

  Future<void> setLanguage(String lang) =>
      _prefs.setString(_kLanguage, lang);

  /// Skala teks (0.8 – 2.0). Default: 1.0.
  double get textScale => _prefs.getDouble(_kTextScale) ?? 1.0;

  Future<void> setTextScale(double scale) =>
      _prefs.setDouble(_kTextScale, scale.clamp(0.8, 2.0));

  /// Mode kontras tinggi untuk penggunaan di luar ruangan. Default: false.
  bool get highContrast => _prefs.getBool(_kHighContrast) ?? false;

  Future<void> setHighContrast(bool value) =>
      _prefs.setBool(_kHighContrast, value);

  /// Format angka: "western" (1234) atau "arabic" (١٢٣٤). Default: "western".
  String get numberFormat => _prefs.getString(_kNumberFormat) ?? 'western';

  Future<void> setNumberFormat(String format) =>
      _prefs.setString(_kNumberFormat, format);

  // ── Notifikasi — global ───────────────────────────────────────────────────

  /// Sembunyikan konten notifikasi di lock screen (privasi). Default: false.
  bool get hideNotificationContent =>
      _prefs.getBool(_kHideNotifContent) ?? false;

  Future<void> setHideNotificationContent(bool value) =>
      _prefs.setBool(_kHideNotifContent, value);

  /// Menit pengingat pra-adzan (0 = dinonaktifkan). Default: 0.
  int get preAdhanMinutes => _prefs.getInt(_kPreAdhanMinutes) ?? 0;

  Future<void> setPreAdhanMinutes(int minutes) =>
      _prefs.setInt(_kPreAdhanMinutes, minutes.clamp(0, 30));

  /// Apakah notifikasi menghormati mode DND/senyap perangkat. Default: true.
  bool get respectDnd => _prefs.getBool(_kRespectDnd) ?? true;

  Future<void> setRespectDnd(bool value) =>
      _prefs.setBool(_kRespectDnd, value);

  // ── Notifikasi — per-sholat aktif/nonaktif ────────────────────────────────

  bool get notifSubuh => _prefs.getBool(_kNotifSubuh) ?? true;
  bool get notifDzuhur => _prefs.getBool(_kNotifDzuhur) ?? true;
  bool get notifAshar => _prefs.getBool(_kNotifAshar) ?? true;
  bool get notifMaghrib => _prefs.getBool(_kNotifMaghrib) ?? true;
  bool get notifIsya => _prefs.getBool(_kNotifIsya) ?? true;

  Future<void> setNotifSubuh(bool v) => _prefs.setBool(_kNotifSubuh, v);
  Future<void> setNotifDzuhur(bool v) => _prefs.setBool(_kNotifDzuhur, v);
  Future<void> setNotifAshar(bool v) => _prefs.setBool(_kNotifAshar, v);
  Future<void> setNotifMaghrib(bool v) => _prefs.setBool(_kNotifMaghrib, v);
  Future<void> setNotifIsya(bool v) => _prefs.setBool(_kNotifIsya, v);

  /// Map ringkas semua toggle notifikasi per-sholat.
  Map<String, bool> get notificationToggles => {
        'Subuh': notifSubuh,
        'Dzuhur': notifDzuhur,
        'Ashar': notifAshar,
        'Maghrib': notifMaghrib,
        'Isya': notifIsya,
      };

  // ── Notifikasi — suara per-sholat ─────────────────────────────────────────
  // Nilai valid: "adhan", "vibration", "silent"

  String get soundSubuh => _prefs.getString(_kSoundSubuh) ?? 'adhan';
  String get soundDzuhur => _prefs.getString(_kSoundDzuhur) ?? 'silent';
  String get soundAshar => _prefs.getString(_kSoundAshar) ?? 'silent';
  String get soundMaghrib => _prefs.getString(_kSoundMaghrib) ?? 'adhan';
  String get soundIsya => _prefs.getString(_kSoundIsya) ?? 'adhan';

  Future<void> setSoundSubuh(String s) => _prefs.setString(_kSoundSubuh, s);
  Future<void> setSoundDzuhur(String s) => _prefs.setString(_kSoundDzuhur, s);
  Future<void> setSoundAshar(String s) => _prefs.setString(_kSoundAshar, s);
  Future<void> setSoundMaghrib(String s) =>
      _prefs.setString(_kSoundMaghrib, s);
  Future<void> setSoundIsya(String s) => _prefs.setString(_kSoundIsya, s);

  /// Map ringkas suara per-sholat.
  Map<String, String> get notificationSounds => {
        'Subuh': soundSubuh,
        'Dzuhur': soundDzuhur,
        'Ashar': soundAshar,
        'Maghrib': soundMaghrib,
        'Isya': soundIsya,
      };

  // ── Koreksi menit per-sholat ──────────────────────────────────────────────

  int get correctionSubuh => _prefs.getInt(_kCorSubuh) ?? 0;
  int get correctionDzuhur => _prefs.getInt(_kCorDzuhur) ?? 0;
  int get correctionAshar => _prefs.getInt(_kCorAshar) ?? 0;
  int get correctionMaghrib => _prefs.getInt(_kCorMaghrib) ?? 0;
  int get correctionIsya => _prefs.getInt(_kCorIsya) ?? 0;

  Future<void> setCorrectionSubuh(int m) =>
      _prefs.setInt(_kCorSubuh, m.clamp(-60, 60));
  Future<void> setCorrectionDzuhur(int m) =>
      _prefs.setInt(_kCorDzuhur, m.clamp(-60, 60));
  Future<void> setCorrectionAshar(int m) =>
      _prefs.setInt(_kCorAshar, m.clamp(-60, 60));
  Future<void> setCorrectionMaghrib(int m) =>
      _prefs.setInt(_kCorMaghrib, m.clamp(-60, 60));
  Future<void> setCorrectionIsya(int m) =>
      _prefs.setInt(_kCorIsya, m.clamp(-60, 60));

  /// Map lengkap koreksi menit per-sholat.
  Map<String, int> get minuteCorrections => {
        'Subuh': correctionSubuh,
        'Dzuhur': correctionDzuhur,
        'Ashar': correctionAshar,
        'Maghrib': correctionMaghrib,
        'Isya': correctionIsya,
      };

  // ── Mark as Prayed ────────────────────────────────────────────────────────

  /// Daftar sholat yang sudah ditandai "sudah sholat" hari ini.
  ///
  /// Data disimpan sebagai "tanggal|Subuh,Dzuhur" untuk auto-reset tiap hari.
  Set<String> getMarkedPrayedToday(DateTime today) {
    final raw = _prefs.getString(_kMarkedPrayed) ?? '';
    final dateKey = _dateKey(today);
    if (!raw.startsWith('$dateKey|')) return {};

    final data = raw.substring('$dateKey|'.length);
    if (data.isEmpty) return {};
    return data.split(',').toSet();
  }

  Future<void> markPrayed(String prayerName, DateTime today) async {
    final current = getMarkedPrayedToday(today);
    current.add(prayerName);
    await _prefs.setString(
      _kMarkedPrayed,
      '${_dateKey(today)}|${current.join(',')}',
    );
  }

  Future<void> unmarkPrayed(String prayerName, DateTime today) async {
    final current = getMarkedPrayedToday(today);
    current.remove(prayerName);
    await _prefs.setString(
      _kMarkedPrayed,
      '${_dateKey(today)}|${current.join(',')}',
    );
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  /// Menghapus semua data lokal aplikasi (dari Settings → Privasi).
  Future<void> clearAll() => _prefs.clear();

  // ── Private helpers ───────────────────────────────────────────────────────

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
