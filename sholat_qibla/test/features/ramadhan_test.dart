import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/data/cities/city_repository.dart';
import 'package:sholat_qibla/data/location/location_resolver.dart';
import 'package:sholat_qibla/data/location/location_service.dart';
import 'package:sholat_qibla/data/preferences/preferences_repository.dart';
import 'package:sholat_qibla/engine/models/lat_lng.dart';
import 'package:sholat_qibla/features/hub/ramadhan_controller.dart';

class _SyncBundle extends CachingAssetBundle {
  _SyncBundle(this._contents);
  final Map<String, String> _contents;
  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      SynchronousFuture(_contents[key] ?? '');
  @override
  Future<ByteData> load(String key) async => ByteData.view(
      Uint8List.fromList((_contents[key] ?? '').codeUnits).buffer);
}

class _FakeLocationService implements LocationService {
  const _FakeLocationService();
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationFailure(LocationFailureReason.serviceDisabled);
  @override
  Future<LatLng?> getLastKnownLocation() async => null;
  @override
  Future<bool> isServiceEnabled() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String citiesJson;
  setUpAll(() {
    citiesJson = File('assets/data/cities_id.json').readAsStringSync();
  });

  Future<RamadhanController> make(
      [Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(
        {'use_gps': false, 'city_id': 'jakarta', ...initial});
    final prefs = await SharedPreferences.getInstance();
    final prefRepo = await PreferencesRepository.create(prefs: prefs);
    final cities = CityRepository(
        bundle: _SyncBundle({'assets/data/cities_id.json': citiesJson}));
    return RamadhanController(
      resolver: LocationResolver(
        locationService: const _FakeLocationService(),
        cityRepository: cities,
        preferences: prefRepo,
      ),
      preferences: prefRepo,
    );
  }

  group('RamadhanController', () {
    // 1 Ramadhan 1447 H (tabular) jatuh sekitar 18-19 Feb 2026.
    test('mendeteksi hari dalam Ramadhan & jadwal imsak/buka valid',
        () async {
      final controller = await make();
      final info =
          await controller.loadInfo(now: DateTime(2026, 3, 1, 10));

      expect(info.isRamadhan, isTrue);
      expect(info.hijri.month, 9);
      expect(info.dayOfRamadhan, isNotNull);
      expect(info.daysUntilRamadhan, isNull);
      // Imsak = Subuh - 10 menit.
      expect(info.fajr.difference(info.imsak).inMinutes, 10);
      // Urutan imsak < subuh < maghrib.
      expect(info.imsak.isBefore(info.fajr), isTrue);
      expect(info.fajr.isBefore(info.maghrib), isTrue);
      expect(info.city.id, 'jakarta');
    });

    test('siang hari Ramadhan -> countdown ke buka puasa', () async {
      final controller = await make();
      final info =
          await controller.loadInfo(now: DateTime(2026, 3, 1, 10));

      expect(info.nextEvent, RamadhanEvent.iftar);
      expect(info.nextEventTime, info.maghrib);
    });

    test('dini hari sebelum imsak -> countdown ke imsak hari ini',
        () async {
      final controller = await make();
      final info =
          await controller.loadInfo(now: DateTime(2026, 3, 1, 2));

      expect(info.nextEvent, RamadhanEvent.imsak);
      expect(info.nextEventTime, info.imsak);
    });

    test('malam setelah maghrib -> countdown ke imsak esok', () async {
      final controller = await make();
      final now = DateTime(2026, 3, 1, 21);
      final info = await controller.loadInfo(now: now);

      expect(info.nextEvent, RamadhanEvent.imsak);
      expect(info.nextEventTime.isAfter(now), isTrue);
      expect(info.nextEventTime.day, 2); // esok hari
    });

    test('di luar Ramadhan -> hitung hari menuju 1 Ramadhan', () async {
      final controller = await make();
      final info =
          await controller.loadInfo(now: DateTime(2026, 7, 7, 10));

      expect(info.isRamadhan, isFalse);
      expect(info.dayOfRamadhan, isNull);
      expect(info.daysUntilRamadhan, isNotNull);
      expect(info.daysUntilRamadhan!, greaterThan(0));
      // Ramadhan 1448 H berikutnya < 1 tahun lagi.
      expect(info.daysUntilRamadhan!, lessThan(366));
    });
  });
}
