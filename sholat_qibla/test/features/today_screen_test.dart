import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mu_qibla/core/theme/app_theme.dart';
import 'package:mu_qibla/core/widgets/neo_toggle.dart';
import 'package:mu_qibla/data/cities/city_repository.dart';
import 'package:mu_qibla/data/location/location_service.dart';
import 'package:mu_qibla/data/preferences/preferences_repository.dart';
import 'package:mu_qibla/engine/models/lat_lng.dart';
import 'package:mu_qibla/features/today/today_controller.dart';
import 'package:mu_qibla/features/today/today_screen.dart';

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

/// AssetBundle sinkron: mengembalikan konten yang sudah dimuat sebelumnya
/// sebagai [SynchronousFuture], sehingga `loadString` resolve dalam satu
/// microtask saat `pump()` (menghindari race dengan Timer countdown).
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

  Future<TodayController> makeController() async {
    SharedPreferences.setMockInitialValues({
      'use_gps': false,
      'city_id': 'jakarta',
    });
    final prefs = await SharedPreferences.getInstance();
    final bundle = _SyncBundle({'assets/data/cities_id.json': citiesJson});
    return TodayController(
      locationService: const _FakeLocationService(),
      cityRepository: CityRepository(bundle: bundle),
      preferences: await PreferencesRepository.create(prefs: prefs),
    );
  }

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.light, home: child);

  /// Pump hingga [finder] menemukan widget, maksimal [maxTries] frame.
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxTries = 20,
  }) async {
    for (var i = 0; i < maxTries; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  testWidgets('menampilkan kota, hero countdown, dan 5 waktu sholat',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController();
    await tester.pumpWidget(wrap(TodayScreen(
      controller: controller,
      clock: () => DateTime(2026, 7, 3, 10, 0),
    )));
    await pumpUntilFound(tester, find.text('Jakarta'));

    expect(find.text('MU-Qibla'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);

    // 5 label waktu sholat tampil.
    expect(find.text('Subuh'), findsOneWidget);
    expect(find.text('Dzuhur'), findsOneWidget);
    expect(find.text('Ashar'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Isya'), findsOneWidget);

    // Hero: jam 10 pagi -> berikutnya Dzuhur.
    expect(find.textContaining('Menuju Dzuhur'), findsOneWidget);
  });

  testWidgets('tombol "Sudah sholat" berubah setelah ditekan',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController();
    await tester.pumpWidget(wrap(TodayScreen(
      controller: controller,
      clock: () => DateTime(2026, 7, 3, 10, 0),
    )));
    await pumpUntilFound(tester, find.text('Sudah sholat'));

    expect(find.text('Sudah sholat'), findsOneWidget);
    await tester.tap(find.text('Sudah sholat'));
    await tester.pump();
    expect(find.text('Sudah ditandai'), findsOneWidget);
  });

  testWidgets('NeoToggle memicu callback', (tester) async {
    var value = false;
    await tester.pumpWidget(wrap(
      StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: Center(
            child: NeoToggle(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    ));

    expect(value, isFalse);
    await tester.tap(find.byType(NeoToggle));
    await tester.pump();
    expect(value, isTrue);
  });
}
