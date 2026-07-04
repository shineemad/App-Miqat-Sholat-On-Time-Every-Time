import '../engine/models/calculation_method.dart';
import '../engine/models/lat_lng.dart';
import '../engine/models/madhab.dart';
import '../engine/models/prayer_times.dart';
import '../engine/prayer_calculator.dart';
import 'models/notification_settings.dart';

/// Jenis notifikasi: adzan (waktu sholat) atau pengingat pra-adzan (alarm).
enum NotificationKind { adhan, reminder }

/// Permintaan penjadwalan satu notifikasi adzan.
class ScheduledPrayerNotification {
  const ScheduledPrayerNotification({
    required this.id,
    required this.prayer,
    required this.localTime,
    required this.utcTime,
    required this.mode,
    required this.title,
    required this.body,
    this.kind = NotificationKind.adhan,
  });

  /// ID deterministik & unik (stabil antar reschedule agar tidak duplikat).
  final int id;
  final Prayer prayer;

  /// Waktu dinding (wall clock) lokal kota terpilih.
  final DateTime localTime;

  /// Instant UTC untuk dieksekusi alarm.
  final DateTime utcTime;
  final AdhanMode mode;
  final String title;
  final String body;

  /// Jenis notifikasi (menentukan suara: adzan vs alarm pengingat).
  final NotificationKind kind;
}

/// Gerbang eksekusi notifikasi — diimplementasikan plugin
/// (flutter_local_notifications) atau fake pada unit test.
abstract interface class NotificationGateway {
  Future<void> cancelAll();
  Future<void> schedule(ScheduledPrayerNotification notification);
}

/// Penjadwal notifikasi 5 waktu sholat.
///
/// Logika murni tanpa dependensi plugin sehingga dapat diuji penuh.
/// Auto-reschedule: panggil [rescheduleAll] setiap kali aplikasi dibuka,
/// setelah boot, atau dari background fetch — ID deterministik menjamin
/// tidak ada notifikasi ganda.
class PrayerNotificationScheduler {
  PrayerNotificationScheduler({
    required NotificationGateway gateway,
    DateTime Function()? clock,
  })  : _gateway = gateway,
        _clock = clock ?? DateTime.now;

  final NotificationGateway _gateway;
  final DateTime Function() _clock;

  static const Map<Prayer, String> _prayerLabels = {
    Prayer.fajr: 'Subuh',
    Prayer.dhuhr: 'Dzuhur',
    Prayer.asr: 'Ashar',
    Prayer.maghrib: 'Maghrib',
    Prayer.isha: 'Isya',
  };

  /// Menyusun daftar notifikasi untuk [days] hari ke depan.
  ///
  /// Hanya waktu yang masih di masa depan (relatif [_clock]) dan sholat
  /// yang diaktifkan pada [settings] yang dijadwalkan.
  List<ScheduledPrayerNotification> buildSchedule({
    required LatLng location,
    required double utcOffset,
    required CalculationMethod method,
    required Madhab madhab,
    required NotificationSettings settings,
    Map<Prayer, int> offsets = const {},
    double elevation = 0,
    int days = 3,
  }) {
    final calculator = PrayerCalculator(method: method, madhab: madhab);
    final nowUtc = _clock().toUtc();
    // "Hari ini" menurut jam dinding kota target.
    final localNow = nowUtc.add(
        Duration(milliseconds: (utcOffset * 3600000).round()));

    final result = <ScheduledPrayerNotification>[];
    for (var d = 0; d < days; d++) {
      final date = DateTime(localNow.year, localNow.month, localNow.day)
          .add(Duration(days: d));
      final times = calculator
          .calculate(
            date: date,
            location: location,
            utcOffset: utcOffset,
            elevation: elevation,
          )
          .withOffsets(offsets);

      for (final prayer in Prayer.values) {
        if (prayer == Prayer.sunrise) continue;
        if (!settings.isEnabled(prayer)) continue;

        final local = times.timeFor(prayer);
        // Konversi wall clock -> instant UTC: kurangi offset zona.
        final utc = DateTime.utc(local.year, local.month, local.day,
                local.hour, local.minute, local.second, local.millisecond)
            .subtract(
                Duration(milliseconds: (utcOffset * 3600000).round()));

        // Pengingat pra-adzan (alarm) beberapa menit sebelum adzan.
        if (settings.preAdhanEnabled && settings.preAdhanMinutes > 0) {
          final reminderLocal =
              local.subtract(Duration(minutes: settings.preAdhanMinutes));
          final reminderUtc =
              utc.subtract(Duration(minutes: settings.preAdhanMinutes));
          if (reminderUtc.isAfter(nowUtc)) {
            result.add(ScheduledPrayerNotification(
              id: reminderNotificationId(date, prayer),
              prayer: prayer,
              localTime: reminderLocal,
              utcTime: reminderUtc,
              mode: settings.mode,
              kind: NotificationKind.reminder,
              title:
                  '${settings.preAdhanMinutes} menit menuju ${_prayerLabels[prayer]}',
              body:
                  'Bersiaplah, waktu ${_prayerLabels[prayer]} sebentar lagi.',
            ));
          }
        }

        if (!utc.isAfter(nowUtc)) continue;

        result.add(ScheduledPrayerNotification(
          id: notificationId(date, prayer),
          prayer: prayer,
          localTime: local,
          utcTime: utc,
          mode: settings.mode,
          title: 'Waktu ${_prayerLabels[prayer]} telah tiba',
          body:
              'Saatnya menunaikan sholat ${_prayerLabels[prayer]}. Jangan ditunda ya.',
        ));
      }
    }
    return result;
  }

  /// Membatalkan semua notifikasi lama lalu menjadwalkan ulang.
  Future<List<ScheduledPrayerNotification>> rescheduleAll({
    required LatLng location,
    required double utcOffset,
    required CalculationMethod method,
    required Madhab madhab,
    required NotificationSettings settings,
    Map<Prayer, int> offsets = const {},
    double elevation = 0,
    int days = 3,
  }) async {
    final schedule = buildSchedule(
      location: location,
      utcOffset: utcOffset,
      method: method,
      madhab: madhab,
      settings: settings,
      offsets: offsets,
      elevation: elevation,
      days: days,
    );
    await _gateway.cancelAll();
    for (final notification in schedule) {
      await _gateway.schedule(notification);
    }
    return schedule;
  }

  /// ID deterministik: yyyymmdd * 10 + indeks sholat (muat dalam int32).
  ///
  /// Contoh: Subuh 3 Juli 2026 => 202607030.
  static int notificationId(DateTime date, Prayer prayer) =>
      (date.year * 10000 + date.month * 100 + date.day) * 10 + prayer.index;

  /// ID deterministik untuk pengingat pra-adzan (rentang terpisah dari
  /// notifikasi adzan agar tidak bertabrakan). Tetap muat dalam int32.
  static int reminderNotificationId(DateTime date, Prayer prayer) =>
      notificationId(date, prayer) + _reminderIdOffset;

  static const int _reminderIdOffset = 1000000000;
}
