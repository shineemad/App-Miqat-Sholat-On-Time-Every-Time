import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mu_qibla/core/theme/app_theme.dart';
import 'package:mu_qibla/data/cities/city_repository.dart';
import 'package:mu_qibla/data/location/location_service.dart';
import 'package:mu_qibla/data/preferences/preferences_repository.dart';
import 'package:mu_qibla/engine/models/lat_lng.dart';
import 'package:mu_qibla/features/qibla/qibla_compass_service.dart';
import 'package:mu_qibla/features/qibla/qibla_controller.dart';
import 'package:mu_qibla/features/qibla/qibla_screen.dart';
import 'package:mu_qibla/features/qibla/widgets/qibla_status.dart';

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

/// Sumber kompas palsu: memancarkan daftar pembacaan, lalu tetap terbuka.
class _FakeCompassSource implements CompassSource {
  _FakeCompassSource(this._readings, {this.compass = true});
  final List<CompassReading?> _readings;
  final bool compass;

  @override
  Stream<CompassReading?> get readings async* {
    for (final r in _readings) {
      yield r;
    }
  }

  @override
  Future<bool> hasCompass() async => compass;
}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String citiesJson;
  setUpAll(() {
    citiesJson = File('assets/data/cities_id.json').readAsStringSync();
  });

  Future<QiblaController> makeController({
    required List<CompassReading?> readings,
    bool compass = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'use_gps': false,
      'city_id': 'jakarta',
    });
    final prefs = await SharedPreferences.getInstance();
    return QiblaController(
      locationService: const _FakeLocationService(),
      cityRepository:
          CityRepository(bundle: _SyncBundle({'assets/data/cities_id.json': citiesJson})),
      preferences: await PreferencesRepository.create(prefs: prefs),
      compassSource: _FakeCompassSource(readings, compass: compass),
    );
  }

  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

  Future<void> pumpUntil(WidgetTester tester, Finder finder,
      {int maxTries = 25}) async {
    for (var i = 0; i < maxTries; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  testWidgets('menampilkan sudut kiblat & jarak untuk Jakarta',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController(
      readings: [const CompassReading(heading: 295, accuracyDegrees: 5)],
    );
    await tester.pumpWidget(wrap(QiblaScreen(controller: controller)));
    await pumpUntil(tester, find.textContaining('°'));

    // Bearing Jakarta ~295°.
    expect(find.textContaining('295'), findsWidgets);
    expect(find.textContaining('km'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
  });

  testWidgets('akurasi tinggi menampilkan kompas & badge akurasi',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController(
      readings: [const CompassReading(heading: 200, accuracyDegrees: 5)],
    );
    await tester.pumpWidget(wrap(QiblaScreen(controller: controller)));
    await pumpUntil(tester, find.byType(AccuracyBadge));

    expect(find.byType(AccuracyBadge), findsOneWidget);
    expect(find.text('Akurasi Tinggi'), findsOneWidget);
    // Tidak menghadap kiblat (heading 200 vs bearing 295) -> instruksi putar.
    expect(find.textContaining('Putar'), findsOneWidget);
  });

  testWidgets('akurasi rendah menampilkan gate kalibrasi',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController(
      readings: [const CompassReading(heading: 100, accuracyDegrees: 40)],
    );
    await tester.pumpWidget(wrap(QiblaScreen(controller: controller)));
    await pumpUntil(tester, find.byType(CalibrationGate));

    expect(find.byType(CalibrationGate), findsOneWidget);
    expect(find.textContaining('kalibrasi'), findsOneWidget);
  });

  testWidgets('tanpa sensor menampilkan fallback derajat', (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController(
      readings: [null],
      compass: false,
    );
    await tester.pumpWidget(wrap(QiblaScreen(controller: controller)));
    await pumpUntil(tester, find.textContaining('Kompas tidak tersedia'));

    expect(find.text('Kompas tidak tersedia'), findsOneWidget);
    expect(find.textContaining('Utara sejati'), findsOneWidget);
  });
}
