/// Model data untuk satu kota Indonesia.
///
/// Berisi koordinat lat/long yang digunakan oleh Prayer Engine dan
/// Qibla Engine untuk menghitung waktu sholat serta arah kiblat.
class CityModel {
  final String id;
  final String name;
  final String province;
  final double latitude;
  final double longitude;

  /// Nama zona waktu IANA, contoh: "Asia/Jakarta", "Asia/Makassar", "Asia/Jayapura".
  final String timezone;

  const CityModel({
    required this.id,
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name, $province';
}
