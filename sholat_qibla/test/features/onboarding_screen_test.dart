import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mu_qibla/core/theme/app_theme.dart';
import 'package:mu_qibla/data/cities/city_repository.dart';
import 'package:mu_qibla/data/preferences/preferences_repository.dart';
import 'package:mu_qibla/engine/models/calculation_method.dart';
import 'package:mu_qibla/engine/models/madhab.dart';
import 'package:mu_qibla/engine/models/prayer_times.dart';
import 'package:mu_qibla/notifications/models/notification_settings.dart';
import 'package:mu_qibla/features/onboarding/onboarding_controller.dart';
import 'package:mu_qibla/features/onboarding/onboarding_screen.dart';

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

  Future<(OnboardingScreen, PreferencesRepository, NotificationSettingsRepository)>
      build({required VoidCallback onFinish}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final prefRepo = await PreferencesRepository.create(prefs: prefs);
    final notif = NotificationSettingsRepository(prefs);
    final screen = OnboardingScreen(
      controller: OnboardingController(prefRepo),
      cityRepository: CityRepository(
          bundle: _SyncBundle({'assets/data/cities_id.json': citiesJson})),
      notificationSettings: notif,
      onFinish: onFinish,
    );
    return (screen, prefRepo, notif);
  }

  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

  testWidgets('alur lengkap 4 langkah lalu selesai menyimpan preferensi',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var finished = false;
    final (screen, prefs, notif) = await build(onFinish: () => finished = true);
    await tester.pumpWidget(wrap(screen));
    await tester.pump();

    // Langkah 1: Welcome.
    expect(find.text('MU-Qibla'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Langkah 2: Lokasi.
    expect(find.text('Gunakan Lokasi (GPS)'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Langkah 3: Metode — pilih ISNA & Hanafi.
    expect(find.text('Metode Perhitungan'), findsOneWidget);
    await tester.tap(find.text('ISNA'));
    await tester.pump();
    await tester.tap(find.text('Hanafi'));
    await tester.pump();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Langkah 4: Notifikasi -> Selesai.
    expect(find.text('Notifikasi Adzan'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pump();
    await tester.pump();

    expect(finished, isTrue);
    expect(prefs.isOnboardingDone(), isTrue);
    expect(prefs.getCalculationMethod(), CalculationMethod.isna);
    expect(prefs.getMadhab(), Madhab.hanafi);
    expect(prefs.getUseGps(), isTrue);
    expect(notif.load().isEnabled(Prayer.fajr), isTrue);
  });

  testWidgets('matikan notifikasi menyimpan set kosong', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (screen, _, notif) = await build(onFinish: () {});
    await tester.pumpWidget(wrap(screen));
    await tester.pump();

    // Lompat ke langkah terakhir.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
    }

    // Matikan notifikasi lalu selesai.
    await tester.tap(find.bySemanticsLabel('Aktifkan notifikasi'));
    await tester.pump();
    await tester.tap(find.text('Selesai'));
    await tester.pump();
    await tester.pump();

    expect(notif.load().enabledPrayers, isEmpty);
  });

  testWidgets('tombol Kembali muncul setelah langkah pertama', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (screen, _, _) = await build(onFinish: () {});
    await tester.pumpWidget(wrap(screen));
    await tester.pump();

    expect(find.text('Kembali'), findsNothing);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Kembali'), findsOneWidget);
  });
}
