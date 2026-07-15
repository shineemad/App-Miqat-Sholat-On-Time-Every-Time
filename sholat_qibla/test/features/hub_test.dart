import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mu_qibla/features/hub/hijri_calendar.dart';
import 'package:mu_qibla/features/hub/hub_feature_registry.dart';
import 'package:mu_qibla/features/hub/tasbih_counter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HijriCalendar - konversi', () {
    test('roundtrip Masehi -> Hijriah -> Masehi konsisten', () {
      for (final date in [
        DateTime(2000, 1, 1),
        DateTime(2024, 3, 11),
        DateTime(2026, 7, 3),
        DateTime(2030, 12, 25),
      ]) {
        final hijri = HijriCalendar.fromGregorian(date);
        final back = HijriCalendar.toGregorian(hijri);
        expect(back, date, reason: 'roundtrip $date');
      }
    });

    test('tanggal Hijriah dalam rentang valid', () {
      final hijri = HijriCalendar.fromGregorian(DateTime(2026, 7, 3));
      expect(hijri.month, inInclusiveRange(1, 12));
      expect(hijri.day, inInclusiveRange(1, 30));
      // 2026 M jatuh sekitar 1447-1448 H.
      expect(hijri.year, inInclusiveRange(1447, 1448));
    });

    test('nama bulan Indonesia & format', () {
      const ramadhan = HijriDate(year: 1447, month: 9, day: 10);
      expect(ramadhan.monthName, 'Ramadhan');
      expect(ramadhan.formatId(), '10 Ramadhan 1447 H');
    });

    test('tahun kabisat pada siklus 30 tahun', () {
      expect(HijriCalendar.isLeapYear(2), isTrue);
      expect(HijriCalendar.isLeapYear(29), isTrue);
      expect(HijriCalendar.isLeapYear(1), isFalse);
      expect(HijriCalendar.isLeapYear(3), isFalse);
    });

    test('hari berturut Masehi => Hijriah maju satu hari', () {
      final d1 = HijriCalendar.fromGregorian(DateTime(2026, 7, 3));
      final d2 = HijriCalendar.fromGregorian(DateTime(2026, 7, 4));
      final diff = HijriCalendar.toGregorian(d2)
          .difference(HijriCalendar.toGregorian(d1))
          .inDays;
      expect(diff, 1);
    });
  });

  group('TasbihCounter', () {
    Future<TasbihCounter> createCounter(
        [Map<String, Object> initial = const {}]) async {
      SharedPreferences.setMockInitialValues(initial);
      final prefs = await SharedPreferences.getInstance();
      return TasbihCounter(prefs);
    }

    test('default target 33, count 0', () async {
      final counter = await createCounter();
      final state = counter.load();
      expect(state.count, 0);
      expect(state.target, TasbihCounter.defaultTarget);
      expect(state.rounds, 0);
    });

    test('increment menaikkan count', () async {
      final counter = await createCounter();
      var state = await counter.increment();
      expect(state.count, 1);
      state = await counter.increment();
      expect(state.count, 2);
    });

    test('menyentuh target menaikkan rounds & progress reset', () async {
      final counter = await createCounter({'tasbih_target': 3});
      await counter.increment();
      await counter.increment();
      final state = await counter.increment(); // count = 3
      expect(state.rounds, 1);
      expect(state.isRoundComplete, isTrue);
      expect(state.progress, 0);
    });

    test('progress berjalan dalam putaran', () async {
      final counter = await createCounter({'tasbih_target': 4});
      final state = await counter.increment(); // 1/4
      expect(state.progress, 0.25);
    });

    test('decrement tidak di bawah nol', () async {
      final counter = await createCounter();
      final state = await counter.decrement();
      expect(state.count, 0);
    });

    test('setTarget minimal 1', () async {
      final counter = await createCounter();
      expect((await counter.setTarget(99)).target, 99);
      expect((await counter.setTarget(0)).target, 1);
    });

    test('reset mengosongkan count & rounds, target tetap', () async {
      final counter = await createCounter({'tasbih_target': 100});
      await counter.increment();
      final state = await counter.reset();
      expect(state.count, 0);
      expect(state.rounds, 0);
      expect(state.target, 100);
    });

    test('sesi tersimpan antar instance', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await TasbihCounter(prefs).increment();
      expect(TasbihCounter(prefs).load().count, 1);
    });
  });

  group('HubFeatureRegistry', () {
    test('fitur tersedia vs segera hadir', () {
      final available = HubFeatureRegistry.available.map((f) => f.id);
      expect(
          available,
          containsAll(
              ['tasbih', 'quran', 'hijri', 'mosque_finder', 'ramadhan_mode']));

      final comingSoon = HubFeatureRegistry.comingSoon.map((f) => f.id);
      expect(comingSoon, isEmpty);
    });

    test('semua fitur punya rute unik', () {
      final routes = HubFeatureRegistry.features.map((f) => f.route).toList();
      expect(routes.toSet().length, routes.length);
    });

    test('byId', () {
      expect(HubFeatureRegistry.byId('tasbih')!.available, isTrue);
      expect(HubFeatureRegistry.byId('mosque_finder')!.available, isTrue);
      expect(HubFeatureRegistry.byId('tidak_ada'), isNull);
    });
  });
}
