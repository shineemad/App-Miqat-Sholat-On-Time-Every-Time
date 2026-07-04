import 'package:shared_preferences/shared_preferences.dart';

import '../../engine/models/prayer_times.dart';

/// Mode penyampaian notifikasi adzan.
enum AdhanMode {
  /// Notifikasi dengan suara adzan penuh.
  adhan,

  /// Notifikasi tanpa suara.
  silent,

  /// Notifikasi getar saja.
  vibrate;

  static AdhanMode fromName(String name) => AdhanMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => AdhanMode.adhan,
      );
}

/// Pengaturan notifikasi per pengguna.
class NotificationSettings {
  const NotificationSettings({
    this.mode = AdhanMode.adhan,
    this.enabledPrayers = defaultEnabled,
    this.preAdhanEnabled = true,
    this.preAdhanMinutes = defaultPreAdhanMinutes,
  });

  /// Default: 5 waktu sholat aktif, sunrise (syuruq) nonaktif.
  static const Set<Prayer> defaultEnabled = {
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  };

  /// Default jeda pengingat pra-adzan (menit sebelum adzan).
  static const int defaultPreAdhanMinutes = 10;

  /// Pilihan jeda yang tersedia di UI (menit).
  static const List<int> preAdhanOptions = [5, 10, 15, 20, 30];

  final AdhanMode mode;
  final Set<Prayer> enabledPrayers;

  /// Aktifkan pengingat alarm sebelum adzan.
  final bool preAdhanEnabled;

  /// Jeda pengingat pra-adzan dalam menit sebelum waktu adzan.
  final int preAdhanMinutes;

  bool isEnabled(Prayer prayer) => enabledPrayers.contains(prayer);

  NotificationSettings copyWith({
    AdhanMode? mode,
    Set<Prayer>? enabledPrayers,
    bool? preAdhanEnabled,
    int? preAdhanMinutes,
  }) =>
      NotificationSettings(
        mode: mode ?? this.mode,
        enabledPrayers: enabledPrayers ?? this.enabledPrayers,
        preAdhanEnabled: preAdhanEnabled ?? this.preAdhanEnabled,
        preAdhanMinutes: preAdhanMinutes ?? this.preAdhanMinutes,
      );
}

/// Penyimpanan [NotificationSettings] berbasis SharedPreferences.
class NotificationSettingsRepository {
  NotificationSettingsRepository(this._prefs);

  static const _kMode = 'notif_mode';
  static const _kEnabledPrayers = 'notif_enabled_prayers';
  static const _kPreAdhanEnabled = 'notif_pre_adhan_enabled';
  static const _kPreAdhanMinutes = 'notif_pre_adhan_minutes';

  final SharedPreferences _prefs;

  static Future<NotificationSettingsRepository> create(
      {SharedPreferences? prefs}) async {
    return NotificationSettingsRepository(
        prefs ?? await SharedPreferences.getInstance());
  }

  NotificationSettings load() {
    final modeName = _prefs.getString(_kMode);
    final enabledNames = _prefs.getStringList(_kEnabledPrayers);
    return NotificationSettings(
      mode: modeName == null ? AdhanMode.adhan : AdhanMode.fromName(modeName),
      enabledPrayers: enabledNames == null
          ? NotificationSettings.defaultEnabled
          : enabledNames
              .map((n) => Prayer.values.asNameMap()[n])
              .whereType<Prayer>()
              .toSet(),
      preAdhanEnabled: _prefs.getBool(_kPreAdhanEnabled) ?? true,
      preAdhanMinutes: _prefs.getInt(_kPreAdhanMinutes) ??
          NotificationSettings.defaultPreAdhanMinutes,
    );
  }

  Future<void> save(NotificationSettings settings) async {
    await _prefs.setString(_kMode, settings.mode.name);
    await _prefs.setStringList(
      _kEnabledPrayers,
      settings.enabledPrayers.map((p) => p.name).toList(),
    );
    await _prefs.setBool(_kPreAdhanEnabled, settings.preAdhanEnabled);
    await _prefs.setInt(_kPreAdhanMinutes, settings.preAdhanMinutes);
  }
}
