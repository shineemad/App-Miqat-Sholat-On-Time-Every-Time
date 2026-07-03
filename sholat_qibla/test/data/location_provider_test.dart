import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_qibla/data/cities/cities_repository_impl.dart';
import 'package:sholat_qibla/data/cities/city_model.dart';
import 'package:sholat_qibla/data/location/lat_lng.dart';
import 'package:sholat_qibla/data/location/location_info.dart';
import 'package:sholat_qibla/data/location/location_mode.dart';
import 'package:sholat_qibla/data/location/manual_location_provider.dart';

void main() {
  // ── LatLng ─────────────────────────────────────────────────────────────────
  group('LatLng', () {
    test('equality berdasarkan nilai koordinat', () {
      const a = LatLng(-6.2088, 106.8456);
      const b = LatLng(-6.2088, 106.8456);
      expect(a, equals(b));
    });

    test('hashCode sama jika koordinat sama', () {
      const a = LatLng(0.0, 0.0);
      const b = LatLng(0.0, 0.0);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString menampilkan koordinat', () {
      const ll = LatLng(1.23, 4.56);
      expect(ll.toString(), contains('1.23'));
      expect(ll.toString(), contains('4.56'));
    });
  });

  // ── LocationInfo ───────────────────────────────────────────────────────────
  group('LocationInfo', () {
    const info = LocationInfo(
      latLng: LatLng(-6.2088, 106.8456),
      cityName: 'Jakarta',
      province: 'DKI Jakarta',
      timezone: 'Asia/Jakarta',
      mode: LocationMode.manual,
    );

    test('displayLabel menggabungkan nama kota dan provinsi', () {
      expect(info.displayLabel, equals('Jakarta, DKI Jakarta'));
    });

    test('equality berdasarkan latLng, cityName, dan mode', () {
      const same = LocationInfo(
        latLng: LatLng(-6.2088, 106.8456),
        cityName: 'Jakarta',
        province: 'DKI Jakarta',
        timezone: 'Asia/Jakarta',
        mode: LocationMode.manual,
      );
      expect(info, equals(same));
    });
  });

  // ── ManualLocationProvider ─────────────────────────────────────────────────
  group('ManualLocationProvider', () {
    const jakartaCity = CityModel(
      id: 'jakarta',
      name: 'Jakarta',
      province: 'DKI Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      timezone: 'Asia/Jakarta',
    );

    final provider = ManualLocationProvider(city: jakartaCity);

    test('mode adalah LocationMode.manual', () {
      expect(provider.mode, equals(LocationMode.manual));
    });

    test('selectedCity mengembalikan kota yang diset', () {
      expect(provider.selectedCity, equals(jakartaCity));
    });

    test('getCurrentLocation mengembalikan koordinat kota yang dipilih', () async {
      final info = await provider.getCurrentLocation();
      expect(info.latLng.latitude, closeTo(-6.2088, 0.0001));
      expect(info.latLng.longitude, closeTo(106.8456, 0.0001));
      expect(info.cityName, equals('Jakarta'));
      expect(info.province, equals('DKI Jakarta'));
      expect(info.timezone, equals('Asia/Jakarta'));
      expect(info.mode, equals(LocationMode.manual));
    });

    test('checkPermission selalu whileInUse (tidak butuh GPS)', () async {
      final status = await provider.checkPermission();
      expect(status, equals(LocationPermissionStatus.whileInUse));
    });

    test('requestPermission selalu whileInUse (tidak butuh GPS)', () async {
      final status = await provider.requestPermission();
      expect(status, equals(LocationPermissionStatus.whileInUse));
    });

    test('locationUpdates stream emit tepat satu nilai', () async {
      final values = await provider.locationUpdates.toList();
      expect(values.length, equals(1));
      expect(values.first.cityName, equals('Jakarta'));
    });

    test('dua provider dengan kota berbeda tidak sama', () {
      const surabayaCity = CityModel(
        id: 'surabaya',
        name: 'Surabaya',
        province: 'Jawa Timur',
        latitude: -7.2575,
        longitude: 112.7521,
        timezone: 'Asia/Jakarta',
      );
      final providerSby = ManualLocationProvider(city: surabayaCity);

      expect(provider.selectedCity, isNot(equals(providerSby.selectedCity)));
    });
  });

  // ── findNearest — integrasi dengan ManualLocationProvider ─────────────────
  group('findNearest + ManualLocationProvider — integrasi', () {
    const repo = IndonesiaCitiesRepository();

    test('koordinat GPS → kota terdekat → manual provider memberikan info yang sama', () async {
      // Simulasi: GPS memberi koordinat Jakarta
      const gpsLat = -6.21;
      const gpsLon = 106.85;

      final nearestCity = repo.findNearest(latitude: gpsLat, longitude: gpsLon);
      final manualProvider = ManualLocationProvider(city: nearestCity);
      final locationInfo = await manualProvider.getCurrentLocation();

      expect(locationInfo.cityName, equals('Jakarta'));
      expect(locationInfo.mode, equals(LocationMode.manual));
    });
  });
}
