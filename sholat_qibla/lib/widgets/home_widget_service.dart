import 'package:home_widget/home_widget.dart';

import '../engine/models/prayer_times.dart';
import '../features/today/prayer_display.dart';
import '../features/today/today_controller.dart';

/// Menyinkronkan data sholat ke widget home screen (Android).
///
/// Data disimpan lewat [HomeWidget] (SharedPreferences native) lalu widget
/// di-refresh. Offline-first: hanya membaca hasil perhitungan lokal.
class HomeWidgetService {
  HomeWidgetService();

  /// Nama provider widget di sisi Android (harus cocok dengan Kotlin).
  static const String _androidName = 'MuQiblaWidgetProvider';

  /// Grup App Group iOS (belum dipakai; widget iOS menyusul).
  static const String _appGroupId = 'group.com.muqibla.mu_qibla';

  static const _urutan = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await HomeWidget.setAppGroupId(_appGroupId);
    _initialized = true;
  }

  /// Menyimpan ringkasan hari ini ke storage widget dan me-refresh widget.
  Future<void> update(TodaySummary summary, {DateTime? now}) async {
    await _ensureInit();
    final today = now ?? DateTime.now();

    await HomeWidget.saveWidgetData<String>('city_name', summary.city.name);

    final next = summary.nextPrayer;
    if (next != null && summary.nextPrayerTime != null) {
      final remaining = summary.nextPrayerTime!.difference(today);
      await HomeWidget.saveWidgetData<String>(
          'next_name', PrayerDisplay.label(next));
      await HomeWidget.saveWidgetData<String>(
          'next_time', PrayerDisplay.time(summary.nextPrayerTime!));
      await HomeWidget.saveWidgetData<String>(
          'next_countdown', PrayerDisplay.countdown(remaining));
      // Epoch millis agar widget dapat menghitung ulang sisa waktu di sisi
      // native pada setiap refresh periodik (countdown tidak basi).
      await HomeWidget.saveWidgetData<int>('next_epoch',
          summary.nextPrayerTime!.millisecondsSinceEpoch);
    } else {
      await HomeWidget.saveWidgetData<String>('next_name', '\u2014');
      await HomeWidget.saveWidgetData<String>('next_time', '');
      await HomeWidget.saveWidgetData<String>(
          'next_countdown', 'Selesai hari ini');
      await HomeWidget.saveWidgetData<int>('next_epoch', 0);
    }

    // Ringkasan 5 waktu "Subuh 04:41 · Dzuhur 11:56 · ..."
    final times = summary.prayerTimes;
    final line = _urutan
        .map((p) =>
            '${PrayerDisplay.label(p)} ${PrayerDisplay.time(times.timeFor(p))}')
        .join('   ');
    await HomeWidget.saveWidgetData<String>('times_line', line);

    await HomeWidget.updateWidget(
      androidName: _androidName,
      iOSName: 'MuQiblaWidget',
    );
  }
}
