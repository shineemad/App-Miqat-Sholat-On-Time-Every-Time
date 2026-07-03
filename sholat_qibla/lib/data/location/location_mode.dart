/// Mode sumber lokasi yang dipilih pengguna.
enum LocationMode {
  /// Lokasi diperoleh dari GPS perangkat secara otomatis.
  gps,

  /// Lokasi dipilih secara manual oleh pengguna (tanpa izin GPS).
  /// Pendekatan ini menjamin privasi total karena tidak ada data
  /// koordinat yang keluar dari perangkat ke layanan eksternal.
  manual,
}

/// Status izin lokasi dari OS.
enum LocationPermissionStatus {
  /// Izin belum pernah diminta.
  notDetermined,

  /// Izin ditolak secara permanen (pengguna harus buka Settings OS).
  deniedForever,

  /// Izin ditolak sementara.
  denied,

  /// Izin diberikan hanya saat aplikasi digunakan (While Using).
  whileInUse,

  /// Layanan lokasi OS dinonaktifkan di level perangkat.
  serviceDisabled,
}
