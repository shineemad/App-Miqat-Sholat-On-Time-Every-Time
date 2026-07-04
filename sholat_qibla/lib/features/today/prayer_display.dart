import '../../engine/models/prayer_times.dart';

/// Utilitas tampilan untuk waktu sholat (label Indonesia & format jam).
abstract final class PrayerDisplay {
  static const Map<Prayer, String> _labels = {
    Prayer.fajr: 'Subuh',
    Prayer.sunrise: 'Terbit',
    Prayer.dhuhr: 'Dzuhur',
    Prayer.asr: 'Ashar',
    Prayer.maghrib: 'Maghrib',
    Prayer.isha: 'Isya',
  };

  /// Label sholat dalam bahasa Indonesia.
  static String label(Prayer prayer) => _labels[prayer] ?? prayer.name;

  /// Format jam 24 jam "HH:mm".
  static String time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  /// Format durasi hitung mundur, mis. "1j 23m" atau "12m 05d".
  static String countdown(Duration d) {
    if (d.isNegative) return '0m';
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (hours > 0) {
      return '${hours}j ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}d';
  }
}
