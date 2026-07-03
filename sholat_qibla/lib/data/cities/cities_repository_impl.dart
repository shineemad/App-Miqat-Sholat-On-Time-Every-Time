import 'dart:math' as math;

import 'cities_repository.dart';
import 'city_model.dart';
import 'indonesia_cities_data.dart';

/// Implementasi [CitiesRepository] menggunakan data statis Indonesia.
///
/// Semua operasi berjalan in-memory sehingga tidak membutuhkan I/O
/// dan dapat berjalan sepenuhnya offline.
class IndonesiaCitiesRepository implements CitiesRepository {
  /// Gunakan konstruktor const agar instance bisa di-cache dan di-share.
  const IndonesiaCitiesRepository();

  @override
  List<CityModel> get allCities => kIndonesiaCities;

  @override
  List<CityModel> search(String query) {
    if (query.trim().isEmpty) return allCities;

    final q = query.trim().toLowerCase();
    return allCities.where((city) {
      return city.name.toLowerCase().contains(q) ||
          city.province.toLowerCase().contains(q);
    }).toList();
  }

  @override
  CityModel? findById(String id) {
    try {
      return allCities.firstWhere((city) => city.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  CityModel findNearest({
    required double latitude,
    required double longitude,
  }) {
    assert(allCities.isNotEmpty, 'Daftar kota tidak boleh kosong');

    CityModel nearest = allCities.first;
    double minDistanceSq = _distanceSq(
      latitude,
      longitude,
      nearest.latitude,
      nearest.longitude,
    );

    for (final city in allCities.skip(1)) {
      final d = _distanceSq(latitude, longitude, city.latitude, city.longitude);
      if (d < minDistanceSq) {
        minDistanceSq = d;
        nearest = city;
      }
    }

    return nearest;
  }

  /// Menghitung kuadrat jarak Euclidean antara dua titik koordinat.
  ///
  /// Menggunakan kuadrat jarak (tanpa sqrt) karena hanya butuh
  /// perbandingan relatif — lebih efisien untuk pencarian kota terdekat
  /// dalam radius kecil (seluruh Indonesia).
  static double _distanceSq(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dlat = lat1 - lat2;
    final dlon = lon1 - lon2;
    // Koreksi meridian: 1° longitude ≈ cos(lat) × 1° latitude
    final cosLat = math.cos(lat1 * math.pi / 180.0);
    return dlat * dlat + (dlon * dlon * cosLat * cosLat);
  }
}
