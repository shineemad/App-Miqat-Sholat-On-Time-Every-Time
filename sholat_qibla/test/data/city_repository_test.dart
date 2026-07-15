import 'package:flutter_test/flutter_test.dart';
import 'package:mu_qibla/data/cities/city_repository.dart';
import 'package:mu_qibla/engine/models/lat_lng.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CityRepository repo;

  setUp(() {
    repo = CityRepository();
  });

  group('CityRepository', () {
    test('memuat database kota dari asset', () async {
      final cities = await repo.getAllCities();
      expect(cities.length, greaterThanOrEqualTo(30));
      // Terurut alfabetis.
      final names = cities.map((c) => c.name).toList();
      final sorted = [...names]..sort();
      expect(names, sorted);
    });

    test('getById mengembalikan kota yang benar', () async {
      final jakarta = await repo.getById('jakarta');
      expect(jakarta, isNotNull);
      expect(jakarta!.name, 'Jakarta');
      expect(jakarta.utcOffset, 7);
      expect(jakarta.location.latitude, closeTo(-6.21, 0.05));
    });

    test('getById id tak dikenal => null', () async {
      expect(await repo.getById('atlantis'), isNull);
    });

    test('search case-insensitive pada nama & provinsi', () async {
      final byName = await repo.search('YOGYA');
      expect(byName.map((c) => c.id), contains('yogyakarta'));

      final byProvince = await repo.search('jawa barat');
      expect(byProvince.map((c) => c.id),
          containsAll(['bandung', 'depok', 'bekasi', 'bogor', 'cirebon']));
    });

    test('search string kosong mengembalikan semua kota', () async {
      final all = await repo.getAllCities();
      final result = await repo.search('   ');
      expect(result.length, all.length);
    });

    test('findNearest (reverse geocoding lokal)', () async {
      // Titik di dekat Monas, Jakarta.
      final nearJakarta = await repo.findNearest(const LatLng(-6.175, 106.827));
      expect(nearJakarta!.id, 'jakarta');

      // Titik di dekat Denpasar.
      final nearDenpasar = await repo.findNearest(const LatLng(-8.65, 115.22));
      expect(nearDenpasar!.id, 'denpasar');
    });

    test('findNearest menghormati maxDistanceKm', () async {
      // Tengah Samudra Hindia, jauh dari semua kota.
      final result = await repo.findNearest(
        const LatLng(-30.0, 90.0),
        maxDistanceKm: 100,
      );
      expect(result, isNull);
    });

    test('cache dipakai pada pemanggilan kedua', () async {
      final first = await repo.getAllCities();
      final second = await repo.getAllCities();
      expect(identical(first, second), isTrue);
      repo.clearCache();
      final third = await repo.getAllCities();
      expect(identical(first, third), isFalse);
    });
  });
}
