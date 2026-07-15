import 'package:flutter_test/flutter_test.dart';
import 'package:mu_qibla/engine/models/calculation_method.dart';
import 'package:mu_qibla/engine/models/lat_lng.dart';
import 'package:mu_qibla/engine/models/madhab.dart';
import 'package:mu_qibla/engine/models/prayer_times.dart';
import 'package:mu_qibla/engine/prayer_calculator.dart';

void main() {
  // Lokasi uji: Jakarta (WIB, UTC+7).
  const jakarta = LatLng(-6.2088, 106.8456);
  const utcOffsetJakarta = 7.0;
  final testDate = DateTime(2026, 7, 3);

  PrayerTimes calc({
    CalculationMethod method = CalculationMethod.kemenag,
    Madhab madhab = Madhab.shafi,
    LatLng location = jakarta,
    double utcOffset = utcOffsetJakarta,
    double elevation = 0,
    DateTime? date,
  }) =>
      PrayerCalculator(method: method, madhab: madhab).calculate(
        date: date ?? testDate,
        location: location,
        utcOffset: utcOffset,
        elevation: elevation,
      );

  group('PrayerCalculator - urutan & kewajaran waktu', () {
    test('urutan waktu selalu benar: fajr < sunrise < dhuhr < asr < maghrib < isha',
        () {
      for (final method in CalculationMethod.values) {
        final t = calc(method: method);
        expect(t.fajr.isBefore(t.sunrise), isTrue, reason: '${method.name}: fajr < sunrise');
        expect(t.sunrise.isBefore(t.dhuhr), isTrue, reason: '${method.name}: sunrise < dhuhr');
        expect(t.dhuhr.isBefore(t.asr), isTrue, reason: '${method.name}: dhuhr < asr');
        expect(t.asr.isBefore(t.maghrib), isTrue, reason: '${method.name}: asr < maghrib');
        expect(t.maghrib.isBefore(t.isha), isTrue, reason: '${method.name}: maghrib < isha');
      }
    });

    test('dhuhr Jakarta sekitar tengah hari lokal (11:30-12:15)', () {
      final t = calc();
      final minutes = t.dhuhr.hour * 60 + t.dhuhr.minute;
      expect(minutes, inInclusiveRange(11 * 60 + 30, 12 * 60 + 15));
    });

    test('waktu Jakarta bulan Juli dalam rentang wajar', () {
      final t = calc();
      // Subuh sekitar 04:30-05:00, Maghrib sekitar 17:45-18:15 (Kemenag).
      expect(t.fajr.hour * 60 + t.fajr.minute, inInclusiveRange(4 * 60 + 20, 5 * 60));
      expect(t.maghrib.hour * 60 + t.maghrib.minute,
          inInclusiveRange(17 * 60 + 40, 18 * 60 + 20));
      // Terbit sekitar 05:45-06:15.
      expect(t.sunrise.hour * 60 + t.sunrise.minute,
          inInclusiveRange(5 * 60 + 45, 6 * 60 + 15));
    });

    test('konsisten untuk tanggal lain dalam setahun', () {
      for (final month in [1, 4, 10, 12]) {
        final t = calc(date: DateTime(2026, month, 15));
        expect(t.fajr.isBefore(t.sunrise), isTrue);
        expect(t.maghrib.isBefore(t.isha), isTrue);
        final dhuhrMin = t.dhuhr.hour * 60 + t.dhuhr.minute;
        expect(dhuhrMin, inInclusiveRange(11 * 60 + 20, 12 * 60 + 30),
            reason: 'dhuhr bulan $month');
      }
    });
  });

  group('PrayerCalculator - metode kalkulasi', () {
    test('sudut fajr lebih besar => subuh lebih awal (Kemenag 20° vs ISNA 15°)',
        () {
      final kemenag = calc(method: CalculationMethod.kemenag);
      final isna = calc(method: CalculationMethod.isna);
      expect(kemenag.fajr.isBefore(isna.fajr), isTrue);
    });

    test('sudut isha lebih besar => isya lebih lambat (Kemenag 18° vs ISNA 15°)',
        () {
      final kemenag = calc(method: CalculationMethod.kemenag);
      final isna = calc(method: CalculationMethod.isna);
      expect(kemenag.isha.isAfter(isna.isha), isTrue);
    });

    test('metode Makkah: isha = maghrib + 90 menit', () {
      final t = calc(method: CalculationMethod.makkah);
      expect(t.isha.difference(t.maghrib).inMinutes, 90);
    });

    test('dhuhr tidak terpengaruh metode', () {
      final a = calc(method: CalculationMethod.kemenag);
      final b = calc(method: CalculationMethod.mwl);
      expect(a.dhuhr.difference(b.dhuhr).inSeconds.abs(), lessThanOrEqualTo(1));
    });
  });

  group('PrayerCalculator - madzhab (Ashar)', () {
    test('Hanafi selalu lebih lambat dari Syafi\'i', () {
      final shafi = calc(madhab: Madhab.shafi);
      final hanafi = calc(madhab: Madhab.hanafi);
      expect(hanafi.asr.isAfter(shafi.asr), isTrue);
      // Selisih wajar 30-90 menit di daerah tropis.
      final diff = hanafi.asr.difference(shafi.asr).inMinutes;
      expect(diff, inInclusiveRange(30, 90));
    });

    test('waktu selain asr tidak terpengaruh madzhab', () {
      final shafi = calc(madhab: Madhab.shafi);
      final hanafi = calc(madhab: Madhab.hanafi);
      expect(shafi.fajr, hanafi.fajr);
      expect(shafi.dhuhr, hanafi.dhuhr);
      expect(shafi.maghrib, hanafi.maghrib);
    });
  });

  group('PrayerCalculator - koreksi ketinggian', () {
    test('elevasi tinggi => terbit lebih awal & maghrib lebih lambat', () {
      final seaLevel = calc(elevation: 0);
      final highland = calc(elevation: 700); // mis. Bandung
      expect(highland.sunrise.isBefore(seaLevel.sunrise), isTrue);
      expect(highland.maghrib.isAfter(seaLevel.maghrib), isTrue);
    });
  });

  group('PrayerCalculator - lokasi lain', () {
    test('Makassar (WITA, UTC+8) menghasilkan dhuhr sekitar tengah hari', () {
      const makassar = LatLng(-5.1477, 119.4327);
      final t = calc(location: makassar, utcOffset: 8);
      final minutes = t.dhuhr.hour * 60 + t.dhuhr.minute;
      expect(minutes, inInclusiveRange(11 * 60 + 30, 12 * 60 + 30));
    });

    test('belahan bumi utara (Madinah) tetap berurutan', () {
      const madinah = LatLng(24.4672, 39.6111);
      final t = calc(location: madinah, utcOffset: 3);
      expect(t.fajr.isBefore(t.sunrise), isTrue);
      expect(t.sunrise.isBefore(t.dhuhr), isTrue);
      expect(t.dhuhr.isBefore(t.asr), isTrue);
      expect(t.asr.isBefore(t.maghrib), isTrue);
      expect(t.maghrib.isBefore(t.isha), isTrue);
    });
  });

  group('PrayerTimes - utilitas', () {
    test('nextPrayer & currentPrayer', () {
      final t = calc();
      final beforeFajr = t.fajr.subtract(const Duration(minutes: 10));
      expect(t.nextPrayer(beforeFajr), Prayer.fajr);
      expect(t.currentPrayer(beforeFajr), isNull);

      final afterDhuhr = t.dhuhr.add(const Duration(minutes: 5));
      expect(t.nextPrayer(afterDhuhr), Prayer.asr);
      expect(t.currentPrayer(afterDhuhr), Prayer.dhuhr);

      final afterIsha = t.isha.add(const Duration(minutes: 5));
      expect(t.nextPrayer(afterIsha), isNull);
      expect(t.currentPrayer(afterIsha), Prayer.isha);
    });

    test('withOffsets menggeser waktu sesuai menit', () {
      final t = calc();
      final adjusted = t.withOffsets({Prayer.fajr: 2, Prayer.isha: -3});
      expect(adjusted.fajr.difference(t.fajr).inMinutes, 2);
      expect(adjusted.isha.difference(t.isha).inMinutes, -3);
      expect(adjusted.dhuhr, t.dhuhr);
    });
  });

  group('LatLng', () {
    test('distanceTo Haversine: Jakarta-Surabaya sekitar 660-700 km', () {
      const surabaya = LatLng(-7.2575, 112.7521);
      final d = jakarta.distanceTo(surabaya);
      expect(d, inInclusiveRange(650, 710));
    });

    test('distanceTo dirinya sendiri = 0', () {
      expect(jakarta.distanceTo(jakarta), 0);
    });
  });
}
