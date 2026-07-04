import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/core/theme/app_theme.dart';
import 'package:sholat_qibla/features/hub/hijri_screen.dart';
import 'package:sholat_qibla/features/hub/hub_feature_registry.dart';
import 'package:sholat_qibla/features/hub/hub_screen.dart';
import 'package:sholat_qibla/features/hub/tasbih_counter.dart';
import 'package:sholat_qibla/features/hub/tasbih_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

  group('HubScreen', () {
    testWidgets('menampilkan fitur tersedia & segera hadir', (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(HubScreen(onOpenFeature: (_) {})));
      await tester.pump();

      expect(find.text('Tasbih Digital'), findsOneWidget);
      expect(find.text('Kalender Hijriah'), findsOneWidget);
      expect(find.text('Segera Hadir'), findsOneWidget);
      expect(find.text('Pencari Masjid'), findsOneWidget);
    });

    testWidgets('ketuk fitur tersedia memicu callback', (tester) async {
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      HubFeature? tapped;
      await tester.pumpWidget(
          wrap(HubScreen(onOpenFeature: (f) => tapped = f)));
      await tester.pump();

      await tester.tap(find.text('Tasbih Digital'));
      await tester.pump();
      expect(tapped?.id, 'tasbih');
    });
  });

  group('TasbihScreen', () {
    Future<TasbihCounter> makeCounter(
        [Map<String, Object> initial = const {}]) async {
      SharedPreferences.setMockInitialValues(initial);
      final prefs = await SharedPreferences.getInstance();
      return TasbihCounter(prefs);
    }

    testWidgets('increment menambah hitungan', (tester) async {
      final counter = await makeCounter();
      await tester.pumpWidget(wrap(TasbihScreen(counter: counter)));
      await tester.pump();

      expect(find.text('0'), findsWidgets);
      await tester.tap(find.text('Ketuk untuk berdzikir'));
      await tester.pump();
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('ganti target memperbarui tampilan', (tester) async {
      final counter = await makeCounter();
      await tester.pumpWidget(wrap(TasbihScreen(counter: counter)));
      await tester.pump();

      await tester.tap(find.text('99'));
      await tester.pump();
      expect(find.text('0/99'), findsOneWidget);
    });

    testWidgets('reset mengembalikan ke nol', (tester) async {
      final counter = await makeCounter({'tasbih_count': 5, 'tasbih_target': 33});
      await tester.pumpWidget(wrap(TasbihScreen(counter: counter)));
      await tester.pump();

      expect(find.text('5'), findsWidgets);
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('0'), findsWidgets);
    });
  });

  group('HijriScreen', () {
    testWidgets('menampilkan tanggal Hijriah untuk tanggal tertentu',
        (tester) async {
      await tester.pumpWidget(wrap(
        HijriScreen(clock: () => DateTime(2026, 7, 4)),
      ));
      await tester.pump();

      // 2026 M jatuh sekitar 1447-1448 H.
      expect(find.textContaining('H'), findsWidgets);
      expect(find.textContaining('Masehi'), findsOneWidget);
    });
  });
}
