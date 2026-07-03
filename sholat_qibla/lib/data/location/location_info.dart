import 'lat_lng.dart';
import 'location_mode.dart';

/// Informasi lokasi lengkap yang digunakan oleh Prayer Engine dan UI.
class LocationInfo {
  /// Koordinat geografis.
  final LatLng latLng;

  /// Nama kota yang ditampilkan di UI (contoh: "Jakarta", "Surabaya").
  final String cityName;

  /// Nama provinsi (contoh: "DKI Jakarta", "Jawa Timur").
  final String province;

  /// Zona waktu IANA kota ini (contoh: "Asia/Jakarta").
  final String timezone;

  /// Mode sumber lokasi: GPS atau manual.
  final LocationMode mode;

  const LocationInfo({
    required this.latLng,
    required this.cityName,
    required this.province,
    required this.timezone,
    required this.mode,
  });

  /// Label singkat untuk ditampilkan di Today screen.
  /// Contoh: "Jakarta, DKI Jakarta"
  String get displayLabel => '$cityName, $province';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationInfo &&
          runtimeType == other.runtimeType &&
          latLng == other.latLng &&
          cityName == other.cityName &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(latLng, cityName, mode);

  @override
  String toString() => 'LocationInfo($displayLabel, $mode)';
}
