import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/core/theme/app_theme.dart';
import 'package:sholat_qibla/data/cities/city_repository.dart';
import 'package:sholat_qibla/data/location/location_resolver.dart';
import 'package:sholat_qibla/data/location/location_service.dart';
import 'package:sholat_qibla/data/preferences/preferences_repository.dart';
import 'package:sholat_qibla/engine/models/lat_lng.dart';
import 'package:sholat_qibla/features/hub/mosque_finder_controller.dart';
import 'package:sholat_qibla/features/hub/mosque_finder_screen.dart';
import 'package:sholat_qibla/features/hub/mosque_finder_service.dart';

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

class _GpsOk implements LocationService {
  const _GpsOk();
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationSuccess(LatLng(-6.20, 106.82));
  @override
  Future<LatLng?> getLastKnownLocation() async => const LatLng(-6.20, 106.82);
  @override
  Future<bool> isServiceEnabled() async => true;
}

class _GpsOff implements LocationService {
  const _GpsOff();
  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationFailure(LocationFailureReason.serviceDisabled);
  @override
  Future<LatLng?> getLastKnownLocation() async => null;
  @override
  Future<bool> isServiceEnabled() async => false;
}

/// Data source palsu: mengembalikan daftar tetap atau melempar error.
class _FakeMosqueSource implements MosqueDataSource {
  _FakeMosqueSource({this.mosques = const [], this.error});
  final List<Mosque> mosques;
  final Object? error;
  LatLng? lastCenter;

  @override
  Future<List<Mosque>> findNearby(LatLng center,
      {int radiusMeters = 5000}) async {
    lastCenter = center;
    if (error != null) throw error!;
    return mosques;
  }
}

const _sampleOverpassJson = '''
{
  "elements": [
    {"type": "node", "id": 1, "lat": -6.21, "lon": 106.83,
     "tags": {"amenity": "place_of_worship", "religion": "muslim",
              "name": "Masjid Istiqlal"}},
    {"type": "way", "id": 2,
     "center": {"lat": -6.201, "lon": 106.821},
     "tags": {"amenity": "place_of_worship", "religion": "muslim",
              "name": "Masjid Agung"}},
    {"type": "node", "id": 3, "lat": -6.25, "lon": 106.90,
     "tags": {"amenity": "place_of_worship", "religion": "muslim"}},
    {"type": "node", "id": 4, "lat": null, "lon": null, "tags": {}}
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String citiesJson;
  setUpAll(() {
    citiesJson = File('assets/data/cities_id.json').readAsStringSync();
  });

  group('OverpassMosqueDataSource.parseOverpass', () {
    test('parse node & way, urut berdasarkan jarak', () {
      const center = LatLng(-6.20, 106.82);
      final mosques =
          OverpassMosqueDataSource.parseOverpass(_sampleOverpassJson, center);

      expect(mosques.length, 3); // entri tanpa koordinat dibuang
      // Terdekat dulu: Masjid Agung (-6.201, 106.821).
      expect(mosques.first.name, 'Masjid Agung');
      expect(mosques.first.distanceKm, lessThan(mosques[1].distanceKm));
      expect(mosques[1].distanceKm, lessThan(mosques[2].distanceKm));
    });

    test('nama kosong diberi placeholder', () {
      const center = LatLng(-6.20, 106.82);
      final mosques =
          OverpassMosqueDataSource.parseOverpass(_sampleOverpassJson, center);
      expect(mosques.any((m) => m.name == 'Masjid (tanpa nama)'), isTrue);
    });

    test('respons kosong -> daftar kosong', () {
      final mosques = OverpassMosqueDataSource.parseOverpass(
          '{"elements": []}', const LatLng(0, 0));
      expect(mosques, isEmpty);
    });
  });

  group('MosqueFinderController', () {
    Future<MosqueFinderController> make({
      required MosqueDataSource source,
      required LocationService location,
      bool useGps = true,
    }) async {
      SharedPreferences.setMockInitialValues(
          {'use_gps': useGps, 'city_id': 'bandung'});
      final prefs = await SharedPreferences.getInstance();
      final prefRepo = await PreferencesRepository.create(prefs: prefs);
      final cities = CityRepository(
          bundle: _SyncBundle({'assets/data/cities_id.json': citiesJson}));
      return MosqueFinderController(
        dataSource: source,
        locationService: location,
        resolver: LocationResolver(
          locationService: location,
          cityRepository: cities,
          preferences: prefRepo,
        ),
        preferences: prefRepo,
      );
    }

    test('GPS aktif -> pakai koordinat GPS presisi', () async {
      final source = _FakeMosqueSource();
      final controller =
          await make(source: source, location: const _GpsOk());
      final result = await controller.search();

      expect(result.usedGps, isTrue);
      expect(result.locationLabel, 'Lokasi GPS');
      expect(source.lastCenter, const LatLng(-6.20, 106.82));
    });

    test('GPS mati -> fallback koordinat kota terpilih', () async {
      final source = _FakeMosqueSource();
      final controller =
          await make(source: source, location: const _GpsOff());
      final result = await controller.search();

      expect(result.usedGps, isFalse);
      expect(result.locationLabel, 'Bandung');
      expect(source.lastCenter!.latitude, closeTo(-6.9175, 0.001));
    });

    test('error jaringan diteruskan sebagai MosqueLookupException',
        () async {
      final controller = await make(
        source: _FakeMosqueSource(
            error: const MosqueLookupException('offline')),
        location: const _GpsOff(),
      );
      expect(controller.search(), throwsA(isA<MosqueLookupException>()));
    });
  });

  group('MosqueFinderScreen', () {
    Future<void> pump(WidgetTester tester, MosqueFinderController controller,
        {Future<void> Function(LatLng, String)? openMap}) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: MosqueFinderScreen(controller: controller, openMap: openMap),
      ));
      await tester.pumpAndSettle();
    }

    Future<MosqueFinderController> makeController(
        MosqueDataSource source) async {
      SharedPreferences.setMockInitialValues(
          {'use_gps': false, 'city_id': 'jakarta'});
      final prefs = await SharedPreferences.getInstance();
      final prefRepo = await PreferencesRepository.create(prefs: prefs);
      final cities = CityRepository(
          bundle: _SyncBundle({'assets/data/cities_id.json': citiesJson}));
      return MosqueFinderController(
        dataSource: source,
        locationService: const _GpsOff(),
        resolver: LocationResolver(
          locationService: const _GpsOff(),
          cityRepository: cities,
          preferences: prefRepo,
        ),
        preferences: prefRepo,
      );
    }

    testWidgets('menampilkan daftar masjid + jarak', (tester) async {
      final controller = await makeController(_FakeMosqueSource(mosques: [
        const Mosque(
            name: 'Masjid Istiqlal',
            location: LatLng(-6.17, 106.83),
            distanceKm: 0.4),
        const Mosque(
            name: 'Masjid Agung',
            location: LatLng(-6.21, 106.82),
            distanceKm: 1.6),
      ]));
      await pump(tester, controller);

      expect(find.text('Masjid Istiqlal'), findsOneWidget);
      expect(find.text('Masjid Agung'), findsOneWidget);
      expect(find.text('400 m'), findsOneWidget);
      expect(find.text('1.6 km'), findsOneWidget);
      expect(find.text('Sekitar Jakarta'), findsOneWidget);
    });

    testWidgets('ketuk masjid membuka peta', (tester) async {
      LatLng? opened;
      final controller = await makeController(_FakeMosqueSource(mosques: [
        const Mosque(
            name: 'Masjid Istiqlal',
            location: LatLng(-6.17, 106.83),
            distanceKm: 0.4),
      ]));
      await pump(tester, controller,
          openMap: (loc, name) async => opened = loc);

      await tester.tap(find.text('Masjid Istiqlal'));
      await tester.pumpAndSettle();
      expect(opened, const LatLng(-6.17, 106.83));
    });

    testWidgets('error jaringan -> pesan & tombol coba lagi',
        (tester) async {
      final controller = await makeController(_FakeMosqueSource(
          error: const MosqueLookupException('offline')));
      await pump(tester, controller);

      expect(find.text('Tidak dapat memuat data masjid'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('hasil kosong -> pesan tidak ditemukan', (tester) async {
      final controller = await makeController(_FakeMosqueSource());
      await pump(tester, controller);

      expect(find.text('Tidak ada masjid ditemukan'), findsOneWidget);
    });
  });
}
