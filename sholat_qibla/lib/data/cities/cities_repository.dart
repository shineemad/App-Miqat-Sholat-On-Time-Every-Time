import 'city_model.dart';

/// Interface untuk lookup kota.
///
/// Memisahkan sumber data dari logika pencarian sehingga mudah
/// diganti (contoh: dari data statis ke database SQLite di masa depan)
/// tanpa mengubah konsumen.
abstract class CitiesRepository {
  /// Seluruh kota yang tersedia.
  List<CityModel> get allCities;

  /// Cari kota berdasarkan nama atau provinsi (case-insensitive, partial match).
  /// Mengembalikan daftar kosong jika tidak ada yang cocok.
  List<CityModel> search(String query);

  /// Cari kota berdasarkan [id] unik.
  /// Mengembalikan null jika tidak ditemukan.
  CityModel? findById(String id);

  /// Temukan kota terdekat dari koordinat [latitude] / [longitude].
  ///
  /// Digunakan untuk reverse geocoding offline: setelah mendapat
  /// koordinat GPS, tampilkan nama kota terdekat tanpa perlu internet.
  CityModel findNearest({
    required double latitude,
    required double longitude,
  });
}
