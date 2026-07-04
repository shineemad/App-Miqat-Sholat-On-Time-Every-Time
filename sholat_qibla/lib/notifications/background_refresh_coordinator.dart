import 'package:shared_preferences/shared_preferences.dart';

/// Koordinator refresh jadwal di latar belakang.
///
/// Strategi hemat baterai (tanpa wake lock / polling):
/// 1. Notifikasi dijadwalkan beberapa hari ke depan via exact alarm
///    (AlarmManager) — tetap berbunyi walau aplikasi di-kill.
/// 2. `ScheduledNotificationBootReceiver` (flutter_local_notifications)
///    memulihkan alarm setelah device restart — dideklarasikan di
///    AndroidManifest.
/// 3. Saat aplikasi dibuka / background fetch berjalan, [shouldReschedule]
///    menentukan apakah jadwal perlu diperpanjang, sehingga reschedule
///    hanya terjadi maksimal sekali per hari.
class BackgroundRefreshCoordinator {
  BackgroundRefreshCoordinator(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  static const _kLastScheduledDay = 'notif_last_scheduled_day';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  static Future<BackgroundRefreshCoordinator> create(
      {SharedPreferences? prefs}) async {
    return BackgroundRefreshCoordinator(
        prefs ?? await SharedPreferences.getInstance());
  }

  /// Apakah jadwal notifikasi perlu disusun ulang hari ini.
  bool shouldReschedule() {
    final last = _prefs.getString(_kLastScheduledDay);
    return last != _dayKey(_clock());
  }

  /// Tandai bahwa reschedule sudah dilakukan hari ini.
  Future<void> markRescheduled() =>
      _prefs.setString(_kLastScheduledDay, _dayKey(_clock()));

  /// Paksa reschedule berikutnya (mis. setelah pengguna mengubah
  /// metode kalkulasi, kota, madzhab, atau pengaturan notifikasi).
  Future<void> invalidate() async {
    await _prefs.remove(_kLastScheduledDay);
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
