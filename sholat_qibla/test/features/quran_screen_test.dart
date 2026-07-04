import 'dart:io';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/core/theme/app_theme.dart';
import 'package:sholat_qibla/features/quran/quran_bookmark_repository.dart';
import 'package:sholat_qibla/features/quran/quran_controller.dart';
import 'package:sholat_qibla/features/quran/quran_repository.dart';
import 'package:sholat_qibla/features/quran/quran_screen.dart';
import 'package:sholat_qibla/features/quran/surah_screen.dart';
import 'package:sholat_qibla/features/quran/widgets/surah_tile.dart';

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

  late String quranJson;
  setUpAll(() {
    quranJson = File('assets/data/quran.json').readAsStringSync();
  });

  Future<QuranController> makeController() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return QuranController(
      repository: QuranRepository(
          bundle: _SyncBundle({'assets/data/quran.json': quranJson})),
      bookmarks: QuranBookmarkRepository(prefs),
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

  testWidgets('menampilkan daftar 114 surah', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController();
    await tester.pumpWidget(wrap(QuranScreen(controller: controller)));
    await pumpUntil(tester, find.text('Al-Fatihah'));

    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.byType(SurahTile), findsWidgets);
  });

  testWidgets('pencarian ayat menampilkan hasil', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController();
    await tester.pumpWidget(wrap(QuranScreen(controller: controller)));
    await pumpUntil(tester, find.text('Al-Fatihah'));

    await tester.enterText(find.byType(TextField), 'manusia');
    await pumpUntil(tester, find.textContaining('Ayat'));

    expect(find.textContaining('Ayat ('), findsOneWidget);
  });

  testWidgets('buka surah menampilkan ayat & bisa bookmark', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = await makeController();
    await tester.pumpWidget(wrap(SurahScreen(
      controller: controller,
      surahNumber: 1,
    )));
    await pumpUntil(tester, find.textContaining('Pembukaan'));

    // 7 ayat Al-Fatihah + terjemahan basmalah.
    expect(find.textContaining('Maha Pengasih'), findsWidgets);

    // Toggle bookmark ayat pertama.
    expect(find.byIcon(Icons.bookmark_border), findsWidgets);
    await tester.tap(find.byIcon(Icons.bookmark_border).first);
    await pumpUntil(tester, find.byIcon(Icons.bookmark));
    expect(find.byIcon(Icons.bookmark), findsWidgets);
  });

  testWidgets('progress terakhir dibaca tersimpan setelah buka surah',
      (tester) async {
    final controller = await makeController();
    await tester.pumpWidget(wrap(SurahScreen(
      controller: controller,
      surahNumber: 112,
      scrollToAyah: 2,
    )));
    await pumpUntil(tester, find.textContaining('Ikhlas'));

    final last = controller.lastRead();
    expect(last, isNotNull);
    expect(last!.surah, 112);
    expect(last.ayah, 2);
  });
}
