import 'dart:math' as math;

import 'models/prayer_time_result.dart';

/// Engine kalkulasi waktu sholat berbasis astronomi murni (tanpa I/O).
///
/// Implementasi algoritma standard Sun position + hour angle.
/// Metode default: **Kemenag Indonesia** (Fajr 20°, Isha 18°).
///
/// Seluruh method bersifat static dan pure function —
/// input yang sama selalu menghasilkan output yang sama.
/// Hal ini memudahkan pengujian dan reuse di widget, wearable, dsb.
///
/// Referensi:
/// - Jean Meeus, "Astronomical Algorithms" (2nd ed.)
/// - Islamic Society of North America (ISNA)
/// - Kementerian Agama Republik Indonesia
class PrayerCalculator {
  PrayerCalculator._();

  // ── Konstanta Kemenag Indonesia ───────────────────────────────────────────

  /// Sudut Fajr (Subuh) di bawah horison dalam derajat.
  static const _kFajrAngle = 20.0;

  /// Sudut Isha (Isya) di bawah horison dalam derajat.
  static const _kIshaAngle = 18.0;

  /// Sudut terbit/terbenam matahari (refraksi atmosfer + jari-jari matahari).
  static const _kStdAltitude = -0.833;

  // ── API publik ────────────────────────────────────────────────────────────

  /// Hitung waktu sholat untuk satu hari.
  ///
  /// Parameter:
  /// - [latitude]            : lintang lokasi (derajat, positif = Utara)
  /// - [longitude]           : bujur lokasi (derajat, positif = Timur)
  /// - [date]                : tanggal kalkulasi
  /// - [timezoneOffsetHours] : offset UTC dalam jam (WIB=+7, WITA=+8, WIT=+9)
  /// - [fajrAngle]           : sudut Fajr dalam derajat (default 20° Kemenag)
  /// - [ishaAngle]           : sudut Isha dalam derajat (default 18° Kemenag)
  /// - [ashrShadowFactor]    : 1 = Syafi'i, 2 = Hanafi
  /// - [minuteCorrections]   : koreksi menit per-sholat (key = nama sholat)
  static PrayerTimeResult calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required int timezoneOffsetHours,
    double fajrAngle = _kFajrAngle,
    double ishaAngle = _kIshaAngle,
    int ashrShadowFactor = 1,
    Map<String, int>? minuteCorrections,
  }) {
    final jd = _julianDate(date.year, date.month, date.day);
    final sun = _sunPosition(jd);

    // Waktu zuhur (tengah hari surya) dalam jam lokal
    final noon = 12.0 + timezoneOffsetHours - longitude / 15.0 - sun.eqT;

    // Hour angle untuk setiap sholat (jam offset dari noon)
    final haStd = _hourAngle(_kStdAltitude, latitude, sun.dec);
    final haFajr = _hourAngle(-fajrAngle, latitude, sun.dec);
    final haIsha = _hourAngle(-ishaAngle, latitude, sun.dec);
    final haAsr = _ashrHourAngle(latitude, sun.dec, ashrShadowFactor);

    final cor = minuteCorrections ?? {};

    return PrayerTimeResult(
      date: date,
      subuh: _localTime(date, noon - (haFajr ?? 8.0), cor['Subuh'] ?? 0),
      syuruk: _localTime(date, noon - (haStd ?? 6.0), 0),
      dzuhur: _localTime(date, noon, cor['Dzuhur'] ?? 0),
      ashar: _localTime(date, noon + haAsr, cor['Ashar'] ?? 0),
      maghrib: _localTime(date, noon + (haStd ?? 6.0), cor['Maghrib'] ?? 0),
      isya: _localTime(date, noon + (haIsha ?? 7.5), cor['Isya'] ?? 0),
    );
  }

  // ── Implementasi internal ─────────────────────────────────────────────────

  /// Julian Date dari tanggal Gregorian.
  /// Algoritma: Meeus, "Astronomical Algorithms", Ch. 7.
  static double _julianDate(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = year ~/ 100;
    final b = 2 - a + a ~/ 4; // Koreksi Gregorian
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  /// Posisi matahari: deklinasi (derajat) dan equation of time (jam).
  static ({double dec, double eqT}) _sunPosition(double jd) {
    final d = jd - 2451545.0; // Hari sejak J2000.0

    // Mean anomaly (derajat)
    final g = _fixAngle(357.529 + 0.98560028 * d);

    // Mean longitude ekliptika (derajat)
    final q = _fixAngle(280.459 + 0.98564736 * d);

    // Longitude ekliptika yang dikoreksi (derajat)
    final l = _fixAngle(q + 1.915 * _dsin(g) + 0.020 * _dsin(2 * g));

    // Kemiringan sumbu Bumi (derajat)
    final e = 23.439 - 0.00000036 * d;

    // Right ascension (derajat → jam)
    final ra = _datan2(_dcos(e) * _dsin(l), _dcos(l)) / 15.0;

    // Deklinasi matahari (derajat)
    final dec = _dasin(_dsin(e) * _dsin(l));

    // Equation of time (jam)
    final eqT = q / 15.0 - _fixHour(ra);

    return (dec: dec, eqT: eqT);
  }

  /// Hour angle (jam offset dari noon) untuk ketinggian matahari [angle] derajat.
  ///
  /// Mengembalikan null jika matahari tidak mencapai ketinggian tersebut
  /// (terjadi di lintang ekstrem — tidak relevan untuk wilayah Indonesia).
  static double? _hourAngle(double angle, double lat, double dec) {
    final cosT = (_dsin(angle) - _dsin(lat) * _dsin(dec)) /
        (_dcos(lat) * _dcos(dec));
    if (cosT < -1.0 || cosT > 1.0) return null;
    return _dacos(cosT) / 15.0;
  }

  /// Hour angle untuk waktu Ashar berdasarkan faktor bayangan.
  ///
  /// [shadowFactor] = 1 (Syafi'i) atau 2 (Hanafi).
  static double _ashrHourAngle(double lat, double dec, int shadowFactor) {
    final angle = -_datan(1.0 / (shadowFactor + _dtan((lat - dec).abs())));
    return _hourAngle(angle, lat, dec) ?? 3.0;
  }

  /// Konversi jam desimal ke [DateTime] lokal dengan koreksi menit.
  static DateTime _localTime(DateTime date, double hours, int correctionMin) {
    final totalMin = (hours * 60).round() + correctionMin;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return DateTime(date.year, date.month, date.day, h.clamp(0, 23), m.clamp(0, 59));
  }

  // ── Trigonometri derajat ──────────────────────────────────────────────────

  static double _dsin(double deg) => math.sin(deg * math.pi / 180.0);
  static double _dcos(double deg) => math.cos(deg * math.pi / 180.0);
  static double _dtan(double deg) => math.tan(deg * math.pi / 180.0);
  static double _dasin(double x) => math.asin(x) * 180.0 / math.pi;
  static double _dacos(double x) => math.acos(x) * 180.0 / math.pi;
  static double _datan(double x) => math.atan(x) * 180.0 / math.pi;
  static double _datan2(double y, double x) =>
      math.atan2(y, x) * 180.0 / math.pi;

  /// Normalisasi sudut ke rentang [0, 360).
  static double _fixAngle(double a) => a - 360.0 * (a / 360.0).floor();

  /// Normalisasi jam ke rentang [0, 24).
  static double _fixHour(double h) => h - 24.0 * (h / 24.0).floor();
}
