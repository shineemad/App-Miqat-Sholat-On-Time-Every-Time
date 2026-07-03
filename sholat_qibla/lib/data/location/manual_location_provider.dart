import '../cities/city_model.dart';
import 'lat_lng.dart';
import 'location_info.dart';
import 'location_mode.dart';
import 'location_provider.dart';

/// Implementasi [LocationProvider] menggunakan kota yang dipilih pengguna.
///
/// Tidak memerlukan izin GPS. Lokasi bersifat tetap (statis) sesuai
/// kota yang disimpan pengguna di Settings. Memberikan privasi penuh
/// karena tidak ada data koordinat yang keluar dari perangkat.
///
/// Stream [locationUpdates] hanya akan emit satu nilai karena koordinat
/// manual tidak berubah secara otomatis.
class ManualLocationProvider implements LocationProvider {
  final CityModel _city;

  const ManualLocationProvider({required CityModel city}) : _city = city;

  @override
  LocationMode get mode => LocationMode.manual;

  @override
  Future<LocationInfo> getCurrentLocation() async => _toLocationInfo();

  @override
  Stream<LocationInfo> get locationUpdates =>
      Stream.value(_toLocationInfo());

  /// Selalu mengembalikan [LocationPermissionStatus.whileInUse] karena
  /// mode manual tidak membutuhkan izin GPS.
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.whileInUse;

  /// Tidak melakukan apa-apa — mode manual tidak memerlukan izin GPS.
  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.whileInUse;

  /// Kota yang saat ini dipilih.
  CityModel get selectedCity => _city;

  // ── Helpers ───────────────────────────────────────────────────────────────

  LocationInfo _toLocationInfo() => LocationInfo(
        latLng: LatLng(_city.latitude, _city.longitude),
        cityName: _city.name,
        province: _city.province,
        timezone: _city.timezone,
        mode: LocationMode.manual,
      );
}
