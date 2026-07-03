import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../data/cities/cities_repository.dart';
import '../data/cities/cities_repository_impl.dart';
import '../data/cities/indonesia_cities_data.dart';
import '../data/location/location_info.dart';
import '../data/location/location_mode.dart';
import '../data/location/location_provider.dart';
import '../data/location/gps_location_provider.dart';
import '../data/location/manual_location_provider.dart';
import '../data/preferences/app_preferences.dart';
import '../engine/hijri_calculator.dart';
import '../engine/models/hijri_date.dart';
import '../engine/models/prayer_time_result.dart';
import '../engine/models/qibla_result.dart';
import '../engine/prayer_calculator.dart';
import '../engine/qibla_calculator.dart';

// ── Preferences ───────────────────────────────────────────────────────────

/// Preferences aplikasi (SharedPreferences). Diload sekali saat startup.
final appPreferencesProvider = FutureProvider<AppPreferences>((ref) {
  return AppPreferences.create();
});

// ── Cities ────────────────────────────────────────────────────────────────

/// Repository kota Indonesia (in-memory, const — tidak perlu dispose).
final citiesRepositoryProvider = Provider<CitiesRepository>((ref) {
  return const IndonesiaCitiesRepository();
});

// ── Location ──────────────────────────────────────────────────────────────

/// LocationProvider aktif berdasarkan preferensi pengguna.
///
/// Otomatis berganti antara GPS dan manual sesuai [AppPreferences.locationMode].
final locationProviderProvider = Provider<LocationProvider>((ref) {
  final prefsAsync = ref.watch(appPreferencesProvider);
  final cities = ref.watch(citiesRepositoryProvider);

  final prefs = prefsAsync.valueOrNull;
  if (prefs != null &&
      prefs.locationMode == LocationMode.manual &&
      prefs.selectedCityId != null) {
    final city = cities.findById(prefs.selectedCityId!);
    if (city != null) {
      return ManualLocationProvider(city: city);
    }
  }

  return GpsLocationProvider(citiesRepository: cities);
});

/// Informasi lokasi saat ini (async — bisa loading/error).
final locationInfoProvider = FutureProvider<LocationInfo>((ref) {
  final provider = ref.watch(locationProviderProvider);
  return provider.getCurrentLocation();
});

// ── Prayer Times ──────────────────────────────────────────────────────────

/// Waktu sholat untuk hari ini berdasarkan lokasi + preferensi.
final prayerTimesProvider = FutureProvider<PrayerTimeResult>((ref) async {
  final locationInfo = await ref.watch(locationInfoProvider.future);
  final prefs = await ref.watch(appPreferencesProvider.future);

  final tzOffset = timezoneOffsetHours(locationInfo.timezone);
  final shadowFactor = prefs.ashrMadhab == 'Hanafi' ? 2 : 1;

  // Ambil sudut Fajr/Isha dari metode kalkulasi yang dipilih
  final methodRec = kCalculationMethods.firstWhere(
    (m) => m.name == prefs.calculationMethod,
    orElse: () => kCalculationMethods.first,
  );

  return PrayerCalculator.calculate(
    latitude: locationInfo.latLng.latitude,
    longitude: locationInfo.latLng.longitude,
    date: DateTime.now(),
    timezoneOffsetHours: tzOffset,
    fajrAngle: methodRec.fajr,
    ishaAngle: methodRec.isha,
    ashrShadowFactor: shadowFactor,
    minuteCorrections: prefs.minuteCorrections,
  );
});

/// Waktu sholat untuk hari berikutnya (untuk Subuh setelah Isya terakhir).
final tomorrowPrayerTimesProvider = FutureProvider<PrayerTimeResult>((ref) async {
  final locationInfo = await ref.watch(locationInfoProvider.future);
  final prefs = await ref.watch(appPreferencesProvider.future);

  final tzOffset = timezoneOffsetHours(locationInfo.timezone);
  final shadowFactor = prefs.ashrMadhab == 'Hanafi' ? 2 : 1;
  final methodRec = kCalculationMethods.firstWhere(
    (m) => m.name == prefs.calculationMethod,
    orElse: () => kCalculationMethods.first,
  );

  final tomorrow = DateTime.now().add(const Duration(days: 1));

  return PrayerCalculator.calculate(
    latitude: locationInfo.latLng.latitude,
    longitude: locationInfo.latLng.longitude,
    date: tomorrow,
    timezoneOffsetHours: tzOffset,
    fajrAngle: methodRec.fajr,
    ishaAngle: methodRec.isha,
    ashrShadowFactor: shadowFactor,
    minuteCorrections: prefs.minuteCorrections,
  );
});

// ── Qibla ─────────────────────────────────────────────────────────────────

/// Hasil kalkulasi arah dan jarak ke Ka'bah dari lokasi pengguna.
final qiblaResultProvider = FutureProvider<QiblaResult>((ref) async {
  final locationInfo = await ref.watch(locationInfoProvider.future);
  return QiblaCalculator.calculate(
    latitude: locationInfo.latLng.latitude,
    longitude: locationInfo.latLng.longitude,
  );
});

/// Stream heading kompas dari sensor perangkat.
/// Null jika perangkat tidak memiliki magnetometer.
final compassProvider = StreamProvider<CompassEvent?>((ref) {
  final stream = FlutterCompass.events;
  if (stream == null) return Stream.value(null);
  return stream.map((e) => e);
});

// ── Hijri Date ────────────────────────────────────────────────────────────

/// Tanggal Hijriah hari ini + offset preferensi.
final hijriDateProvider = FutureProvider<HijriDate>((ref) async {
  final prefs = await ref.watch(appPreferencesProvider.future);
  return HijriCalculator.fromGregorian(
    DateTime.now(),
    offset: prefs.hijriOffset,
  );
});

// ── Mark as Prayed ────────────────────────────────────────────────────────

/// Sholat yang sudah ditandai "sudah sholat" hari ini.
final markedPrayedProvider = FutureProvider<Set<String>>((ref) async {
  final prefs = await ref.watch(appPreferencesProvider.future);
  return prefs.getMarkedPrayedToday(DateTime.now());
});

// ── Online status (sederhana) ─────────────────────────────────────────────

/// App ini selalu offline-first. Provider ini ada sebagai placeholder
/// untuk badge offline yang ditampilkan di Today screen.
/// Dalam MVP, selalu mengembalikan true (offline-capable).
final isOfflineCapableProvider = Provider<bool>((ref) => true);

// ── Daftar kota untuk pencarian manual ───────────────────────────────────

final citySearchQueryProvider = StateProvider<String>((ref) => '');

final filteredCitiesProvider = Provider((ref) {
  final repo = ref.watch(citiesRepositoryProvider);
  final query = ref.watch(citySearchQueryProvider);
  return repo.search(query);
});

// ── Default city (Jakarta) sebagai fallback ───────────────────────────────

final defaultCityProvider = Provider((ref) {
  final repo = ref.watch(citiesRepositoryProvider);
  return repo.findById(kDefaultCityId) ?? kIndonesiaCities.first;
});
