import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/core/theme/app_theme.dart';
import 'package:sholat_qibla/core/widgets/neo_toggle.dart';
import 'package:sholat_qibla/l10n/app_localizations.dart';
import 'package:sholat_qibla/data/cities/city_repository.dart';
import 'package:sholat_qibla/data/preferences/preferences_repository.dart';
import 'package:sholat_qibla/engine/models/calculation_method.dart';
import 'package:sholat_qibla/engine/models/madhab.dart';
import 'package:sholat_qibla/engine/models/prayer_times.dart';
import 'package:sholat_qibla/notifications/background_refresh_coordinator.dart';
import 'package:sholat_qibla/notifications/models/notification_settings.dart';
import 'package:sholat_qibla/features/settings/settings_controller.dart';
import 'package:sholat_qibla/features/settings/settings_screen.dart';

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

  Future<(SettingsController, CityRepository, PreferencesRepository,
          NotificationSettingsRepository)>
      make([Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    final cityRepo =
        CityRepository(bundle: _SyncBundle({'assets/data/cities_id.json': citiesJson}));
    final prefRepo = await PreferencesRepository.create(prefs: prefs);
    final notif = NotificationSettingsRepository(prefs);
    final controller = SettingsController(
      preferences: prefRepo,
      notificationSettings: notif,
      cityRepository: cityRepo,
      refreshCoordinator: BackgroundRefreshCoordinator(prefs),
    );
    return (controller, cityRepo, prefRepo, notif);
  }

  Widget wrap(SettingsController c, CityRepository repo) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        home: SettingsScreen(controller: c, cityRepository: repo),
      );

  Future<void> pumpUntil(WidgetTester tester, Finder finder,
      {int maxTries = 25}) async {
    for (var i = 0; i < maxTries; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  testWidgets('menampilkan semua grup pengaturan', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (c, repo, _, _) = await make();
    await tester.pumpWidget(wrap(c, repo));
    await pumpUntil(tester, find.text('Sholat'));

    expect(find.text('Sholat'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.text('Privasi'), findsOneWidget);
    expect(find.text('Tentang'), findsOneWidget);
    expect(find.text('Kemenag RI'), findsOneWidget);
  });

  testWidgets('ubah madzhab tersimpan', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (c, repo, prefs, _) = await make();
    await tester.pumpWidget(wrap(c, repo));
    await pumpUntil(tester, find.text('Hanafi'));

    await tester.tap(find.text('Hanafi'));
    await tester.pump();
    await tester.pump();
    expect(prefs.getMadhab(), Madhab.hanafi);
  });

  testWidgets('ubah mode notifikasi ke Getar tersimpan', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (c, repo, _, notif) = await make();
    await tester.pumpWidget(wrap(c, repo));
    await pumpUntil(tester, find.text('Getar'));

    await tester.tap(find.text('Getar'));
    await tester.pump();
    await tester.pump();
    expect(notif.load().mode, AdhanMode.vibrate);
  });

  testWidgets('matikan notifikasi Subuh tersimpan', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (c, repo, _, notif) = await make();
    await tester.pumpWidget(wrap(c, repo));
    await pumpUntil(tester, find.byType(NeoToggle));

    // Toggle pertama = notifikasi Subuh (default aktif -> matikan).
    final subuhToggle = find.byWidgetPredicate(
      (w) => w is NeoToggle && w.semanticLabel == 'Notifikasi Subuh',
    );
    expect(subuhToggle, findsOneWidget);
    await tester.tap(subuhToggle);
    await tester.pump();
    await tester.pump();
    expect(notif.load().isEnabled(Prayer.fajr), isFalse);
  });

  testWidgets('pilih metode ISNA lewat bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (c, repo, prefs, _) = await make();
    await tester.pumpWidget(wrap(c, repo));
    await pumpUntil(tester, find.text('Metode perhitungan'));

    await tester.tap(find.text('Metode perhitungan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ISNA').last);
    await tester.pumpAndSettle();
    expect(prefs.getCalculationMethod(), CalculationMethod.isna);
  });
}
