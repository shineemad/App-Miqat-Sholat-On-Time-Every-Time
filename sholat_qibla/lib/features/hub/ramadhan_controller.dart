import '../../data/location/location_resolver.dart';
import '../../engine/models/city.dart';
import '../../engine/models/prayer_times.dart';
import '../../engine/prayer_calculator.dart';
import '../../data/preferences/preferences_repository.dart';
import 'hijri_calendar.dart';

/// Peristiwa puasa berikutnya yang dihitung mundur.
enum RamadhanEvent { imsak, iftar }

/// Ringkasan Mode Ramadhan untuk satu hari & lokasi.
class RamadhanInfo {
  const RamadhanInfo({
    required this.city,
    required this.hijri,
    required this.isRamadhan,
    required this.imsak,
    required this.fajr,
    required this.maghrib,
    required this.nextEvent,
    required this.nextEventTime,
    this.daysUntilRamadhan,
  });

  final City city;
  final HijriDate hijri;

  /// true bila hari ini bulan Ramadhan (perkiraan tabular ±1 hari).
  final bool isRamadhan;

  /// Waktu imsak hari ini (konvensi Kemenag: Subuh − 10 menit).
  final DateTime imsak;
  final DateTime fajr;

  /// Waktu berbuka (maghrib) hari ini.
  final DateTime maghrib;

  /// Peristiwa berikutnya yang dihitung mundur (imsak/iftar).
  final RamadhanEvent nextEvent;

  /// Waktu peristiwa berikutnya (bisa jatuh esok hari untuk imsak).
  final DateTime nextEventTime;

  /// Hari ke-berapa Ramadhan (1..30); null di luar Ramadhan.
  int? get dayOfRamadhan => isRamadhan ? hijri.day : null;

  /// Jumlah hari menuju 1 Ramadhan; null saat sedang Ramadhan.
  final int? daysUntilRamadhan;
}

/// Controller Mode Ramadhan: jadwal imsak/buka + hitung mundur,
/// sepenuhnya offline (engine lokal + kalender Hijriah tabular).
class RamadhanController {
  RamadhanController({
    required LocationResolver resolver,
    required PreferencesRepository preferences,
  })  : _resolver = resolver,
        _preferences = preferences;

  final LocationResolver _resolver;
  final PreferencesRepository _preferences;

  /// Konvensi jeda imsak Kemenag RI (menit sebelum Subuh).
  static const int imsakOffsetMinutes = 10;

  PrayerTimes _timesFor(DateTime date, City city) {
    final calculator = PrayerCalculator(
      method: _preferences.getCalculationMethod(),
      madhab: _preferences.getMadhab(),
    );
    return calculator
        .calculate(
          date: DateTime(date.year, date.month, date.day),
          location: city.location,
          utcOffset: city.utcOffset,
          elevation: city.elevation,
        )
        .withOffsets(_preferences.getAllOffsets());
  }

  /// Memuat ringkasan Ramadhan untuk [now] (default waktu perangkat).
  Future<RamadhanInfo> loadInfo({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final resolved = await _resolver.resolve();
    final city = resolved.city;

    final times = _timesFor(today, city);
    final imsak =
        times.fajr.subtract(const Duration(minutes: imsakOffsetMinutes));

    final hijri = HijriCalendar.fromGregorian(today);
    final isRamadhan = hijri.month == 9;

    // Tentukan peristiwa berikutnya: imsak hari ini -> iftar -> imsak esok.
    final RamadhanEvent nextEvent;
    final DateTime nextEventTime;
    if (today.isBefore(imsak)) {
      nextEvent = RamadhanEvent.imsak;
      nextEventTime = imsak;
    } else if (today.isBefore(times.maghrib)) {
      nextEvent = RamadhanEvent.iftar;
      nextEventTime = times.maghrib;
    } else {
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowTimes = _timesFor(tomorrow, city);
      nextEvent = RamadhanEvent.imsak;
      nextEventTime = tomorrowTimes.fajr
          .subtract(const Duration(minutes: imsakOffsetMinutes));
    }

    return RamadhanInfo(
      city: city,
      hijri: hijri,
      isRamadhan: isRamadhan,
      imsak: imsak,
      fajr: times.fajr,
      maghrib: times.maghrib,
      nextEvent: nextEvent,
      nextEventTime: nextEventTime,
      daysUntilRamadhan: isRamadhan ? null : _daysUntilRamadhan(today, hijri),
    );
  }

  /// Hari menuju 1 Ramadhan berikutnya (tabular).
  int _daysUntilRamadhan(DateTime today, HijriDate hijri) {
    final targetYear = hijri.month < 9 ? hijri.year : hijri.year + 1;
    final firstRamadhan = HijriCalendar.toGregorian(
        HijriDate(year: targetYear, month: 9, day: 1));
    return firstRamadhan
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }
}
