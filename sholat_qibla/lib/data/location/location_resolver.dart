import '../cities/city_repository.dart';
import '../location/location_service.dart';
import '../preferences/preferences_repository.dart';
import '../../engine/models/city.dart';

/// Sumber lokasi yang berhasil di-resolve.
enum LocationSource { gps, manualCity, fallback }

/// Hasil resolusi lokasi: kota + dari mana asalnya.
class ResolvedLocation {
  const ResolvedLocation({required this.city, required this.source});

  final City city;
  final LocationSource source;
}

/// Menyelesaikan lokasi aktif secara berlapis (offline-first):
/// GPS (bila diizinkan) → kota terpilih manual → kota default pertama.
///
/// Dipakai bersama oleh layar Beranda (Today) dan Kiblat agar logika
/// pemilihan lokasi konsisten di seluruh aplikasi.
class LocationResolver {
  const LocationResolver({
    required LocationService locationService,
    required CityRepository cityRepository,
    required PreferencesRepository preferences,
  })  : _location = locationService,
        _cities = cityRepository,
        _preferences = preferences;

  final LocationService _location;
  final CityRepository _cities;
  final PreferencesRepository _preferences;

  Future<ResolvedLocation> resolve() async {
    // 1. GPS bila diizinkan pengguna & tersedia.
    if (_preferences.getUseGps()) {
      final result = await _location.getCurrentLocation();
      if (result is LocationSuccess) {
        final nearest = await _cities.findNearest(result.position);
        if (nearest != null) {
          return ResolvedLocation(city: nearest, source: LocationSource.gps);
        }
      }
    }

    // 2. Kota terpilih manual.
    final selected = await _cities.getById(_preferences.getSelectedCityId());
    if (selected != null) {
      return ResolvedLocation(
          city: selected, source: LocationSource.manualCity);
    }

    // 3. Fallback: kota pertama pada database.
    final all = await _cities.getAllCities();
    return ResolvedLocation(city: all.first, source: LocationSource.fallback);
  }
}
