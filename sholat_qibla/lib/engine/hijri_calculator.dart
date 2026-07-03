import 'models/hijri_date.dart';

/// Konverter tanggal Gregorian ke Hijriah (murni matematis, tanpa I/O).
///
/// Algoritma: Youssef Rashed, "Civil Calendar Conversion"
/// (akurasi ±1 hari — sesuai untuk kebanyakan kegunaan, termasuk offset Kemenag).
class HijriCalculator {
  HijriCalculator._();

  /// Konversi tanggal Gregorian ke Hijriah.
  ///
  /// [offset] : koreksi hari Hijriah (-2 .. +2) untuk penyesuaian rukyat lokal.
  static HijriDate fromGregorian(DateTime date, {int offset = 0}) {
    // Langkah 1: Gregorian ke Julian Day Number
    int jdn = _gregorianToJdn(date.year, date.month, date.day);

    // Langkah 2: Terapkan offset hari Hijriah
    jdn += offset;

    // Langkah 3: Julian Day Number ke Hijriah
    return _jdnToHijri(jdn);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  /// Gregorian ke Julian Day Number (JDN, bilangan bulat).
  static int _gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  /// Julian Day Number ke tanggal Hijriah.
  /// Algoritma: "Civil Calendar Conversion" (akurasi ±1 hari).
  static HijriDate _jdnToHijri(int jdn) {
    // Epoch Hijriah: JDN 1948440 = 1 Muharram 1 H
    const epoch = 1948440;
    final n = jdn - epoch + 1;

    // Siklus 30 tahun Hijriah: 10631 hari
    final cycle = (n - 1) ~/ 10631;
    final r = n - cycle * 10631;

    // Tahun dalam siklus
    final jY = (r - 1) ~/ 354;
    final remYear = r - jY * 354 - (jY * 11 + 3) ~/ 30;

    // Bulan dalam tahun
    int month = 1;
    int daysInMonth = 30;
    int accumulated = 0;
    final monthDays = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];

    for (int m = 0; m < 12; m++) {
      accumulated += monthDays[m];
      if (remYear <= accumulated) {
        month = m + 1;
        daysInMonth = monthDays[m];
        break;
      }
    }

    final day = (remYear - (accumulated - daysInMonth)).clamp(1, daysInMonth);
    final year = cycle * 30 + jY + 1;

    return HijriDate(year: year, month: month, day: day);
  }
}
