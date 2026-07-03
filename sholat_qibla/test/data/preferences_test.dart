import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/data/location/location_mode.dart';
import 'package:sholat_qibla/data/preferences/app_preferences.dart';

void main() {
  setUp(() {
    // Reset SharedPreferences ke state kosong sebelum setiap test.
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppPreferences> buildPrefs() => AppPreferences.create();

  // ── Default values ─────────────────────────────────────────────────────────
  group('AppPreferences — nilai default', () {
    test('calculationMethod default adalah Kemenag', () async {
      final prefs = await buildPrefs();
      expect(prefs.calculationMethod, equals('Kemenag'));
    });

    test('ashrMadhab default adalah Shafii', () async {
      final prefs = await buildPrefs();
      expect(prefs.ashrMadhab, equals('Shafii'));
    });

    test('hijriOffset default adalah 0', () async {
      final prefs = await buildPrefs();
      expect(prefs.hijriOffset, equals(0));
    });

    test('locationMode default adalah GPS', () async {
      final prefs = await buildPrefs();
      expect(prefs.locationMode, equals(LocationMode.gps));
    });

    test('selectedCityId default adalah null', () async {
      final prefs = await buildPrefs();
      expect(prefs.selectedCityId, isNull);
    });

    test('onboardingCompleted default false', () async {
      final prefs = await buildPrefs();
      expect(prefs.onboardingCompleted, isFalse);
    });

    test('theme default adalah system', () async {
      final prefs = await buildPrefs();
      expect(prefs.theme, equals('system'));
    });

    test('language default adalah id (Indonesia)', () async {
      final prefs = await buildPrefs();
      expect(prefs.language, equals('id'));
    });

    test('textScale default adalah 1.0', () async {
      final prefs = await buildPrefs();
      expect(prefs.textScale, closeTo(1.0, 0.001));
    });

    test('highContrast default false', () async {
      final prefs = await buildPrefs();
      expect(prefs.highContrast, isFalse);
    });

    test('numberFormat default adalah western', () async {
      final prefs = await buildPrefs();
      expect(prefs.numberFormat, equals('western'));
    });

    test('hideNotificationContent default false', () async {
      final prefs = await buildPrefs();
      expect(prefs.hideNotificationContent, isFalse);
    });

    test('preAdhanMinutes default adalah 0', () async {
      final prefs = await buildPrefs();
      expect(prefs.preAdhanMinutes, equals(0));
    });

    test('respectDnd default true', () async {
      final prefs = await buildPrefs();
      expect(prefs.respectDnd, isTrue);
    });
  });

  // ── Notifikasi per-sholat ──────────────────────────────────────────────────
  group('AppPreferences — notifikasi per-sholat', () {
    test('semua toggle notifikasi default true', () async {
      final prefs = await buildPrefs();
      final toggles = prefs.notificationToggles;
      expect(toggles['Subuh'], isTrue);
      expect(toggles['Dzuhur'], isTrue);
      expect(toggles['Ashar'], isTrue);
      expect(toggles['Maghrib'], isTrue);
      expect(toggles['Isya'], isTrue);
    });

    test('toggle Dzuhur bisa dinonaktifkan dan disimpan', () async {
      final prefs = await buildPrefs();
      await prefs.setNotifDzuhur(false);
      expect(prefs.notifDzuhur, isFalse);
    });

    test('suara Subuh default adzan, Dzuhur default silent', () async {
      final prefs = await buildPrefs();
      expect(prefs.soundSubuh, equals('adhan'));
      expect(prefs.soundDzuhur, equals('silent'));
    });

    test('suara per-sholat bisa diubah', () async {
      final prefs = await buildPrefs();
      await prefs.setSoundAshar('vibration');
      expect(prefs.soundAshar, equals('vibration'));
    });

    test('notificationSounds map berisi semua 5 sholat', () async {
      final prefs = await buildPrefs();
      final sounds = prefs.notificationSounds;
      expect(sounds.keys, containsAll(['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']));
    });
  });

  // ── Koreksi menit ──────────────────────────────────────────────────────────
  group('AppPreferences — koreksi menit', () {
    test('semua koreksi default 0', () async {
      final prefs = await buildPrefs();
      final cor = prefs.minuteCorrections;
      for (final v in cor.values) {
        expect(v, equals(0));
      }
    });

    test('koreksi Subuh bisa diset +3', () async {
      final prefs = await buildPrefs();
      await prefs.setCorrectionSubuh(3);
      expect(prefs.correctionSubuh, equals(3));
    });

    test('koreksi Maghrib bisa diset -2', () async {
      final prefs = await buildPrefs();
      await prefs.setCorrectionMaghrib(-2);
      expect(prefs.correctionMaghrib, equals(-2));
    });

    test('koreksi di-clamp antara -60 dan 60', () async {
      final prefs = await buildPrefs();
      await prefs.setCorrectionIsya(999);
      expect(prefs.correctionIsya, equals(60));
      await prefs.setCorrectionIsya(-999);
      expect(prefs.correctionIsya, equals(-60));
    });
  });

  // ── Lokasi ────────────────────────────────────────────────────────────────
  group('AppPreferences — lokasi', () {
    test('locationMode bisa diubah ke manual', () async {
      final prefs = await buildPrefs();
      await prefs.setLocationMode(LocationMode.manual);
      expect(prefs.locationMode, equals(LocationMode.manual));
    });

    test('selectedCityId bisa disimpan', () async {
      final prefs = await buildPrefs();
      await prefs.setSelectedCityId('jakarta');
      expect(prefs.selectedCityId, equals('jakarta'));
    });
  });

  // ── Hijri offset ──────────────────────────────────────────────────────────
  group('AppPreferences — hijriOffset', () {
    test('offset bisa diset ke +1', () async {
      final prefs = await buildPrefs();
      await prefs.setHijriOffset(1);
      expect(prefs.hijriOffset, equals(1));
    });

    test('offset di-clamp antara -2 dan 2', () async {
      final prefs = await buildPrefs();
      await prefs.setHijriOffset(10);
      expect(prefs.hijriOffset, equals(2));
      await prefs.setHijriOffset(-10);
      expect(prefs.hijriOffset, equals(-2));
    });
  });

  // ── textScale ─────────────────────────────────────────────────────────────
  group('AppPreferences — textScale', () {
    test('textScale di-clamp antara 0.8 dan 2.0', () async {
      final prefs = await buildPrefs();
      await prefs.setTextScale(5.0);
      expect(prefs.textScale, closeTo(2.0, 0.001));
      await prefs.setTextScale(0.1);
      expect(prefs.textScale, closeTo(0.8, 0.001));
    });
  });

  // ── Mark as prayed ────────────────────────────────────────────────────────
  group('AppPreferences — markAsPrayed', () {
    final today = DateTime(2026, 7, 3);

    test('awalnya tidak ada sholat yang ditandai', () async {
      final prefs = await buildPrefs();
      expect(prefs.getMarkedPrayedToday(today), isEmpty);
    });

    test('bisa menandai satu sholat', () async {
      final prefs = await buildPrefs();
      await prefs.markPrayed('Subuh', today);
      expect(prefs.getMarkedPrayedToday(today), contains('Subuh'));
    });

    test('bisa menandai beberapa sholat sekaligus', () async {
      final prefs = await buildPrefs();
      await prefs.markPrayed('Subuh', today);
      await prefs.markPrayed('Dzuhur', today);
      final marked = prefs.getMarkedPrayedToday(today);
      expect(marked, containsAll(['Subuh', 'Dzuhur']));
    });

    test('unmark menghapus dari daftar', () async {
      final prefs = await buildPrefs();
      await prefs.markPrayed('Subuh', today);
      await prefs.markPrayed('Dzuhur', today);
      await prefs.unmarkPrayed('Subuh', today);
      final marked = prefs.getMarkedPrayedToday(today);
      expect(marked, isNot(contains('Subuh')));
      expect(marked, contains('Dzuhur'));
    });

    test('data hari ini tidak terlihat dari hari lain (auto-reset)', () async {
      final prefs = await buildPrefs();
      await prefs.markPrayed('Subuh', today);
      final tomorrow = today.add(const Duration(days: 1));
      expect(prefs.getMarkedPrayedToday(tomorrow), isEmpty);
    });
  });

  // ── Onboarding & clearAll ─────────────────────────────────────────────────
  group('AppPreferences — onboarding & clearAll', () {
    test('setOnboardingCompleted mengubah flag menjadi true', () async {
      final prefs = await buildPrefs();
      expect(prefs.onboardingCompleted, isFalse);
      await prefs.setOnboardingCompleted();
      expect(prefs.onboardingCompleted, isTrue);
    });

    test('clearAll mereset semua preferensi ke default', () async {
      final prefs = await buildPrefs();
      await prefs.setCalculationMethod('MWL');
      await prefs.setLanguage('ar');
      await prefs.clearAll();
      expect(prefs.calculationMethod, equals('Kemenag'));
      expect(prefs.language, equals('id'));
    });
  });
}
