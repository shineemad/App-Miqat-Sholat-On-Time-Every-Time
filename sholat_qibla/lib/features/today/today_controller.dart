import '../../data/cities/city_repository.dart';
import '../../data/location/location_resolver.dart';
import '../../data/location/location_service.dart';
import '../../data/preferences/preferences_repository.dart';
import '../../engine/models/city.dart';
import '../../engine/models/prayer_times.dart';
import '../../engine/prayer_calculator.dart';

export '../../data/location/location_resolver.dart' show LocationSource;

/// Ringkasan yang ditampilkan di layar Beranda (Today).
class TodaySummary {
  const TodaySummary({
    required this.city,
    required this.prayerTimes,
    required this.locationSource,
    required this.nextPrayer,
    required this.currentPrayer,
  });

  final City city;
  final PrayerTimes prayerTimes;
  final LocationSource locationSource;
  final Prayer? nextPrayer;
  final Prayer? currentPrayer;

  DateTime? get nextPrayerTime =>
      nextPrayer == null ? null : prayerTimes.timeFor(nextPrayer!);
}

/// Controller layar Beranda: mengintegrasikan lokasi, database kota,
/// preferensi, dan mesin waktu sholat menjadi satu [TodaySummary].
///
/// Menerapkan strategi lokasi berlapis (offline-first):
/// GPS -> kota terpilih -> kota default. Semua kegagalan ditangani agar
/// UI selalu mendapat data yang valid.
class TodayController {
  TodayController({
    required LocationService locationService,
    required CityRepository cityRepository,
    required PreferencesRepository preferences,
  })  : _resolver = LocationResolver(
          locationService: locationService,
          cityRepository: cityRepository,
          preferences: preferences,
        ),
        _preferences = preferences;

  final LocationResolver _resolver;
  final PreferencesRepository _preferences;

  /// Menghitung ringkasan hari ini untuk [now] (default waktu perangkat).
  Future<TodaySummary> loadToday({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final resolved = await _resolver.resolve();

    final calculator = PrayerCalculator(
      method: _preferences.getCalculationMethod(),
      madhab: _preferences.getMadhab(),
    );
    final times = calculator
        .calculate(
          date: DateTime(today.year, today.month, today.day),
          location: resolved.city.location,
          utcOffset: resolved.city.utcOffset,
          elevation: resolved.city.elevation,
        )
        .withOffsets(_preferences.getAllOffsets());

    return TodaySummary(
      city: resolved.city,
      prayerTimes: times,
      locationSource: resolved.source,
      nextPrayer: times.nextPrayer(today),
      currentPrayer: times.currentPrayer(today),
    );
  }
}
