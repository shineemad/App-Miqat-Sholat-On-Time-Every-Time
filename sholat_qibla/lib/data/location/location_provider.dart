import 'location_info.dart';
import 'location_mode.dart';

/// Interface abstrak untuk sumber lokasi.
///
/// Dua implementasi yang tersedia:
/// - [GpsLocationProvider]    — menggunakan GPS perangkat (requires izin)
/// - [ManualLocationProvider] — menggunakan kota yang dipilih pengguna
///
/// Prayer Engine dan Qibla Engine bergantung HANYA pada interface ini,
/// sehingga pengganti mode lokasi tidak menyentuh logika kalkulasi.
abstract class LocationProvider {
  /// Mode aktif provider ini.
  LocationMode get mode;

  /// Mendapatkan lokasi terkini sekali (one-shot).
  ///
  /// Throws [LocationPermissionException] jika izin tidak diberikan.
  /// Throws [LocationServiceDisabledException] jika GPS dimatikan di OS.
  Future<LocationInfo> getCurrentLocation();

  /// Stream update lokasi secara terus-menerus.
  ///
  /// Untuk [ManualLocationProvider], stream hanya emit satu nilai
  /// (lokasi tidak berubah kecuali pengguna mengganti kota).
  Stream<LocationInfo> get locationUpdates;

  /// Memeriksa status izin lokasi saat ini tanpa meminta ke pengguna.
  Future<LocationPermissionStatus> checkPermission();

  /// Meminta izin lokasi "While Using" ke pengguna.
  ///
  /// Mengembalikan status setelah permintaan. Jika sudah denied forever,
  /// pengguna harus diarahkan ke Settings OS.
  Future<LocationPermissionStatus> requestPermission();
}

/// Dilempar saat izin lokasi tidak diberikan atau ditolak permanen.
class LocationPermissionException implements Exception {
  final LocationPermissionStatus status;
  const LocationPermissionException(this.status);

  @override
  String toString() => 'LocationPermissionException(status: $status)';
}

/// Dilempar saat layanan lokasi OS dinonaktifkan.
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();

  @override
  String toString() => 'LocationServiceDisabledException: GPS dimatikan di perangkat';
}
