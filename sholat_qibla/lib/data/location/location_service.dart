import 'package:geolocator/geolocator.dart';

import '../../engine/models/lat_lng.dart';

/// Hasil permintaan lokasi.
sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  const LocationSuccess(this.position, {this.elevation = 0});
  final LatLng position;
  final double elevation;
}

class LocationFailure extends LocationResult {
  const LocationFailure(this.reason);
  final LocationFailureReason reason;
}

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

/// Abstraksi layanan lokasi agar mudah di-mock pada unit test dan
/// diganti implementasinya (Clean Architecture: domain tidak bergantung
/// langsung pada plugin).
abstract interface class LocationService {
  /// Apakah layanan lokasi perangkat aktif.
  Future<bool> isServiceEnabled();

  /// Meminta izin & mengambil posisi saat ini.
  Future<LocationResult> getCurrentLocation();

  /// Posisi terakhir yang diketahui (cepat, bisa null).
  Future<LatLng?> getLastKnownLocation();
}

/// Implementasi [LocationService] menggunakan plugin geolocator.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationResult> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationFailure(LocationFailureReason.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const LocationFailure(LocationFailureReason.permissionDenied);
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationFailure(
          LocationFailureReason.permissionDeniedForever);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationSuccess(
        LatLng(position.latitude, position.longitude),
        elevation: position.altitude,
      );
    } on Exception {
      return const LocationFailure(LocationFailureReason.timeout);
    }
  }

  @override
  Future<LatLng?> getLastKnownLocation() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }
}
