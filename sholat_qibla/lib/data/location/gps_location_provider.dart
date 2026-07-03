import 'package:geolocator/geolocator.dart' as geo;

import '../cities/cities_repository.dart';
import 'lat_lng.dart';
import 'location_info.dart';
import 'location_mode.dart';
import 'location_provider.dart';

/// Implementasi [LocationProvider] menggunakan GPS perangkat.
///
/// Menggunakan package [geolocator] untuk mendapatkan koordinat.
/// Setelah koordinat diperoleh, kota terdekat dicari secara offline
/// menggunakan [CitiesRepository.findNearest] — tanpa panggilan network.
///
/// Akurasi yang diminta: [LocationAccuracy.medium] agar hemat baterai.
class GpsLocationProvider implements LocationProvider {
  final CitiesRepository _citiesRepository;

  /// [distanceFilter]: jarak minimum (meter) perubahan posisi sebelum
  /// stream emit event baru. Default 500m untuk menghemat baterai.
  final int distanceFilterMeters;

  const GpsLocationProvider({
    required CitiesRepository citiesRepository,
    this.distanceFilterMeters = 500,
  }) : _citiesRepository = citiesRepository;

  @override
  LocationMode get mode => LocationMode.gps;

  @override
  Future<LocationInfo> getCurrentLocation() async {
    await _ensurePermissionAndService();

    final position = await geo.Geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return _buildLocationInfo(position.latitude, position.longitude);
  }

  @override
  Stream<LocationInfo> get locationUpdates {
    return geo.Geolocator.getPositionStream(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.medium,
        distanceFilter: distanceFilterMeters,
      ),
    ).map((pos) => _buildLocationInfo(pos.latitude, pos.longitude));
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await geo.Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await geo.Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  LocationInfo _buildLocationInfo(double lat, double lon) {
    final city = _citiesRepository.findNearest(latitude: lat, longitude: lon);
    return LocationInfo(
      latLng: LatLng(lat, lon),
      cityName: city.name,
      province: city.province,
      timezone: city.timezone,
      mode: LocationMode.gps,
    );
  }

  Future<void> _ensurePermissionAndService() async {
    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    final status = await checkPermission();
    if (status == LocationPermissionStatus.deniedForever) {
      throw LocationPermissionException(LocationPermissionStatus.deniedForever);
    }
    if (status == LocationPermissionStatus.denied) {
      throw LocationPermissionException(LocationPermissionStatus.denied);
    }
  }

  static LocationPermissionStatus _mapPermission(geo.LocationPermission p) {
    switch (p) {
      case geo.LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case geo.LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case geo.LocationPermission.whileInUse:
      case geo.LocationPermission.always:
        return LocationPermissionStatus.whileInUse;
      case geo.LocationPermission.unableToDetermine:
        return LocationPermissionStatus.notDetermined;
    }
  }
}
