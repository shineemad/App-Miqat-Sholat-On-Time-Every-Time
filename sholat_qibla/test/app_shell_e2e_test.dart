import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/app/app_shell.dart';
import 'package:sholat_qibla/app/injection.dart';
import 'package:sholat_qibla/core/theme/app_colors.dart';
import 'package:sholat_qibla/core/theme/app_theme.dart';
import 'package:sholat_qibla/core/theme/theme_controller.dart';
import 'package:sholat_qibla/data/cities/city_repository.dart';
import 'package:sholat_qibla/data/location/location_service.dart';
import 'package:sholat_qibla/engine/models/lat_lng.dart';
import 'package:sholat_qibla/features/qibla/qibla_compass_service.dart';
import 'package:sholat_qibla/l10n/app_localizations.dart';

/// AssetBundle sinkron dari isi file (asset tidak reliabel di test harness).
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

/// LocationService palsu (GPS sukses di Jakarta) untuk UI test.
class _FakeLocationService implements LocationService {
  const _FakeLocationService();

  @override
  Future<LocationResult> getCurrentLocation() async =>
      const LocationSuccess(LatLng(-6.20, 106.82));

  @override
  Future<LatLng?> getLastKnownLocation() async => const LatLng(-6.20, 106.82);

  @override
  Future<bool> isServiceEnabled() async => true;
}

/// CompassSource palsu dengan heading tetap.
class _FakeCompassSource implements CompassSource {
  const _FakeCompassSource();

  @override
  Stream<CompassReading?> get readings =>
      Stream.value(const CompassReading(heading: 295, accuracyDegrees: 10));

  @override
  Future<bool> hasCompass() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String citiesJson;
  setUpAll(() {
    citiesJson = File('assets/data/cities_id.json').readAsStringSync();
  });

  tearDown(() async {
    if (sl.isRegistered<SharedPreferences>()) {
      await resetDependencies();
    }
  });

  // Countdown Beranda memakai Timer.periodic sehingga pumpAndSettle tak
  // pernah selesai; pakai pump berbatas.
  Future<void> settle(WidgetTester tester, [int frames = 20]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  Future<void> pumpShell(WidgetTester tester,
      {Map<String, Object> prefs = const {'use_gps': true}}) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(prefs);
    await configureDependencies(
      locationService: const _FakeLocationService(),
      compassSource: const _FakeCompassSource(),
      cityRepository: CityRepository(
        bundle: _SyncBundle({'assets/data/cities_id.json': citiesJson}),
      ),
    );

    await tester.pumpWidget(
      ListenableBuilder(
        listenable: sl<ThemeController>(),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: sl<ThemeController>().mode.materialMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('id'),
          home: const AppShell(),
        ),
      ),
    );
    await settle(tester);
  }

  group('End-to-end UI: navigasi shell', () {
    testWidgets('Beranda tampil & bisa pindah ke Pengaturan', (tester) async {
      await pumpShell(tester);

      expect(find.text('Beranda'), findsWidgets);
      expect(find.text('Kiblat'), findsWidgets);
      expect(find.text('Hub'), findsWidgets);
      expect(find.text('Atur'), findsWidgets);

      await tester.tap(find.text('Atur'));
      await settle(tester);
      expect(find.text('Sholat'), findsOneWidget);
      expect(find.text('Tampilan'), findsOneWidget);
    });

    testWidgets('Hub menampilkan fitur modular', (tester) async {
      await pumpShell(tester);
      await tester.tap(find.text('Hub'));
      await settle(tester);
      expect(find.textContaining('Tasbih'), findsWidgets);
    });
  });

  group('End-to-end UI: ganti tema', () {
    testWidgets('memilih tema Gelap mengaktifkan mode gelap', (tester) async {
      await pumpShell(tester);
      addTearDown(() => AppColors.isDark = false);

      await tester.tap(find.text('Atur'));
      await settle(tester);
      expect(AppColors.isDark, isFalse);

      await tester.tap(find.text('Tema'));
      await settle(tester);

      await tester.tap(find.text('Gelap').last);
      await settle(tester);

      expect(AppColors.isDark, isTrue);
      expect(sl<ThemeController>().mode, AppThemeMode.dark);

      final persisted =
          ThemeController(await SharedPreferences.getInstance());
      expect(persisted.mode, AppThemeMode.dark);
    });
  });
}
