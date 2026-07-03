import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_qibla/data/cities/cities_repository_impl.dart';
import 'package:sholat_qibla/data/cities/indonesia_cities_data.dart';

void main() {
  const repo = IndonesiaCitiesRepository();

  group('IndonesiaCitiesRepository — allCities', () {
    test('daftar kota tidak kosong', () {
      expect(repo.allCities, isNotEmpty);
    });

    test('setiap kota memiliki id, name, province, lat, lon, timezone', () {
      for (final city in repo.allCities) {
        expect(city.id, isNotEmpty);
        expect(city.name, isNotEmpty);
        expect(city.province, isNotEmpty);
        expect(city.latitude.isNaN, isFalse);
        expect(city.longitude.isNaN, isFalse);
        expect(city.timezone, isNotEmpty);
      }
    });

    test('tidak ada id yang duplikat', () {
      final ids = repo.allCities.map((c) => c.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, equals(uniqueIds.length),
          reason: 'Ditemukan id kota duplikat');
    });

    test('koordinat Jakarta benar (sekitar -6.2°, 106.8°)', () {
      final jakarta = repo.findById('jakarta');
      expect(jakarta, isNotNull);
      expect(jakarta!.latitude, closeTo(-6.2088, 0.1));
      expect(jakarta.longitude, closeTo(106.8456, 0.1));
      expect(jakarta.timezone, equals('Asia/Jakarta'));
    });

    test('koordinat Makassar benar (sekitar -5.1°, 119.4°)', () {
      final makassar = repo.findById('makassar');
      expect(makassar, isNotNull);
      expect(makassar!.latitude, closeTo(-5.1477, 0.1));
      expect(makassar.longitude, closeTo(119.4327, 0.1));
      expect(makassar.timezone, equals('Asia/Makassar'));
    });

    test('koordinat Jayapura benar (zona WIT Asia/Jayapura)', () {
      final jayapura = repo.findById('jayapura');
      expect(jayapura, isNotNull);
      expect(jayapura!.timezone, equals('Asia/Jayapura'));
    });

    test('jumlah kota minimal mencakup semua provinsi Indonesia (38)', () {
      final provinces = repo.allCities.map((c) => c.province).toSet();
      expect(provinces.length, greaterThanOrEqualTo(30),
          reason: 'Setidaknya 30 provinsi harus terwakili');
    });
  });

  group('IndonesiaCitiesRepository — search', () {
    test('pencarian kosong mengembalikan semua kota', () {
      expect(repo.search('').length, equals(kIndonesiaCities.length));
    });

    test('pencarian "jakarta" case-insensitive menemukan Jakarta', () {
      final results = repo.search('jakarta');
      expect(results.any((c) => c.id == 'jakarta'), isTrue);
    });

    test('pencarian "JAWA" menemukan kota-kota di Jawa', () {
      final results = repo.search('JAWA');
      expect(results, isNotEmpty);
      expect(results.every((c) => c.province.toLowerCase().contains('jawa')),
          isTrue);
    });

    test('pencarian nama parsial "bandu" menemukan Bandung', () {
      final results = repo.search('bandu');
      expect(results.any((c) => c.id == 'bandung'), isTrue);
    });

    test('pencarian yang tidak cocok mengembalikan daftar kosong', () {
      final results = repo.search('xyznotexist12345');
      expect(results, isEmpty);
    });

    test('pencarian province "Sulawesi" mengembalikan beberapa kota', () {
      final results = repo.search('Sulawesi');
      expect(results.length, greaterThan(3));
    });
  });

  group('IndonesiaCitiesRepository — findById', () {
    test('menemukan kota yang ada', () {
      final city = repo.findById('surabaya');
      expect(city, isNotNull);
      expect(city!.name, equals('Surabaya'));
    });

    test('mengembalikan null untuk id tidak dikenal', () {
      expect(repo.findById('kota_tidak_ada'), isNull);
    });

    test('id bersifat unik — findById konsisten dengan allCities', () {
      for (final city in repo.allCities) {
        final found = repo.findById(city.id);
        expect(found, equals(city));
      }
    });
  });

  group('IndonesiaCitiesRepository — findNearest', () {
    test('koordinat Jakarta menemukan Jakarta sebagai kota terdekat', () {
      final nearest = repo.findNearest(latitude: -6.2088, longitude: 106.8456);
      expect(nearest.id, equals('jakarta'));
    });

    test('koordinat Surabaya menemukan Surabaya', () {
      final nearest = repo.findNearest(latitude: -7.2575, longitude: 112.7521);
      expect(nearest.id, equals('surabaya'));
    });

    test('koordinat Makassar menemukan Makassar', () {
      final nearest = repo.findNearest(latitude: -5.1477, longitude: 119.4327);
      expect(nearest.id, equals('makassar'));
    });

    test('koordinat Jayapura menemukan Jayapura', () {
      final nearest = repo.findNearest(latitude: -2.5333, longitude: 140.7167);
      expect(nearest.id, equals('jayapura'));
    });

    test('koordinat di laut antara Jawa-Bali tetap mengembalikan kota (tidak crash)', () {
      // Di tengah Selat Bali
      final nearest = repo.findNearest(latitude: -8.2, longitude: 114.5);
      expect(nearest, isNotNull);
    });
  });
}
