import 'dart:math' as math;

import '../core/constants/calculation_constants.dart';
import 'models/calculation_method.dart';
import 'models/lat_lng.dart';
import 'models/madhab.dart';
import 'models/prayer_times.dart';

/// Mesin perhitungan waktu sholat berbasis posisi matahari.
///
/// Algoritma mengikuti pendekatan standar (praytimes.org / astronomical
/// algorithms Jean Meeus, disederhanakan):
/// 1. Hitung Julian Date terkoreksi bujur.
/// 2. Hitung deklinasi matahari & equation of time.
/// 3. Tentukan tengah hari (Dhuhr), lalu waktu lain dari sudut matahari
///    (hour angle) di bawah/atas horizon.
/// 4. Koreksi ketinggian pengamat untuk terbit/terbenam.
class PrayerCalculator {
  const PrayerCalculator({
    this.method = CalculationMethod.kemenag,
    this.madhab = Madhab.shafi,
  });

  final CalculationMethod method;
  final Madhab madhab;

  /// Menghitung waktu sholat untuk [date] (tanggal lokal) di [location].
  ///
  /// [utcOffset] adalah offset zona waktu dalam jam (WIB = 7).
  /// [elevation] ketinggian lokasi dalam meter (koreksi terbit/terbenam).
  PrayerTimes calculate({
    required DateTime date,
    required LatLng location,
    required double utcOffset,
    double elevation = 0,
  }) {
    final lat = location.latitude;
    final lng = location.longitude;

    // Julian Date pada tengah malam lokal, dikoreksi bujur agar perhitungan
    // dilakukan dalam waktu matahari lokal.
    final jDate =
        _julianDate(date.year, date.month, date.day) - lng / (15.0 * 24.0);

    // Estimasi awal (jam lokal solar), lalu satu iterasi penyempurnaan.
    var times = <String, double>{
      'fajr': 5,
      'sunrise': 6,
      'dhuhr': 12,
      'asr': 13,
      'maghrib': 18,
      'isha': 18,
    };
    for (var i = 0; i < 2; i++) {
      times = _computeRaw(times, jDate, lat, elevation);
    }

    // Konversi solar time -> waktu sipil lokal.
    final tzAdjust = utcOffset - lng / 15.0;
    times.updateAll((_, v) => v + tzAdjust);

    if (method.ishaIntervalMinutes > 0) {
      times['isha'] = times['maghrib']! + method.ishaIntervalMinutes / 60.0;
    }

    // Terapkan offset ihtiyati (menit) jika metode memilikinya.
    if (method.offsetMinutes != 0) {
      final offsetHours = method.offsetMinutes / 60.0;
      times.updateAll((_, v) => v + offsetHours);
    }

    final midnight = DateTime(date.year, date.month, date.day);
    DateTime toTime(double hours) =>
        midnight.add(Duration(milliseconds: (hours * 3600000).round()));

    return PrayerTimes(
      date: midnight,
      fajr: toTime(times['fajr']!),
      sunrise: toTime(times['sunrise']!),
      dhuhr: toTime(times['dhuhr']!),
      asr: toTime(times['asr']!),
      maghrib: toTime(times['maghrib']!),
      isha: toTime(times['isha']!),
    );
  }

  Map<String, double> _computeRaw(
    Map<String, double> t,
    double jDate,
    double lat,
    double elevation,
  ) {
    final riseSetAngle = CalculationConstants.sunriseSunsetAngle +
        CalculationConstants.elevationCoefficient * math.sqrt(math.max(0, elevation));

    return {
      'fajr': _sunAngleTime(
          jDate, method.fajrAngle, t['fajr']! / 24, lat, ccw: true),
      'sunrise':
          _sunAngleTime(jDate, riseSetAngle, t['sunrise']! / 24, lat, ccw: true),
      'dhuhr': _midDay(jDate, t['dhuhr']! / 24),
      'asr': _asrTime(jDate, madhab.shadowFactor, t['asr']! / 24, lat),
      'maghrib': _sunAngleTime(jDate, riseSetAngle, t['maghrib']! / 24, lat),
      'isha': method.ishaIntervalMinutes > 0
          ? t['isha']! // dihitung dari maghrib setelahnya
          : _sunAngleTime(jDate, method.ishaAngle, t['isha']! / 24, lat),
    };
  }

  // ---------------------------------------------------------------------
  // Astronomi matahari
  // ---------------------------------------------------------------------

  /// Deklinasi matahari & equation of time pada Julian Date [jd].
  ({double declination, double equationOfTime}) _sunPosition(double jd) {
    final d = jd - 2451545.0;
    final g = _fixAngle(357.529 + 0.98560028 * d); // anomali rata-rata
    final q = _fixAngle(280.459 + 0.98564736 * d); // bujur rata-rata
    final l = _fixAngle(
        q + 1.915 * _sinDeg(g) + 0.020 * _sinDeg(2 * g)); // bujur ekliptika

    final e = 23.439 - 0.00000036 * d; // kemiringan sumbu bumi (zenith basis)

    final declination = _asinDeg(_sinDeg(e) * _sinDeg(l));
    var ra = _atan2Deg(_cosDeg(e) * _sinDeg(l), _cosDeg(l)) / 15.0;
    ra = _fixHour(ra);
    final equationOfTime = q / 15.0 - ra;

    return (declination: declination, equationOfTime: equationOfTime);
  }

  /// Waktu tengah hari (transit matahari) dalam jam solar.
  double _midDay(double jDate, double time) {
    final eqt = _sunPosition(jDate + time).equationOfTime;
    return _fixHour(12 - eqt);
  }

  /// Waktu saat matahari mencapai [angle] derajat di bawah horizon.
  /// [ccw] = true untuk waktu sebelum tengah hari (subuh/terbit).
  double _sunAngleTime(
    double jDate,
    double angle,
    double time,
    double lat, {
    bool ccw = false,
  }) {
    final decl = _sunPosition(jDate + time).declination;
    final noon = _midDay(jDate, time);
    final cosArg = (-_sinDeg(angle) - _sinDeg(decl) * _sinDeg(lat)) /
        (_cosDeg(decl) * _cosDeg(lat));
    // Clamp untuk lintang ekstrem (matahari tidak mencapai sudut tsb).
    final t = _acosDeg(cosArg.clamp(-1.0, 1.0)) / 15.0;
    return noon + (ccw ? -t : t);
  }

  /// Waktu Ashar: saat bayangan = [shadowFactor] x tinggi benda.
  double _asrTime(double jDate, int shadowFactor, double time, double lat) {
    final decl = _sunPosition(jDate + time).declination;
    final altitude =
        -_acotDeg(shadowFactor + _tanDeg((lat - decl).abs()));
    return _sunAngleTime(jDate, altitude, time, lat);
  }

  /// Julian Date pada 00:00 UT untuk tanggal Gregorian.
  double _julianDate(int year, int month, int day) {
    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  // ---------------------------------------------------------------------
  // Utilitas trigonometri derajat
  // ---------------------------------------------------------------------

  static double _degToRad(double d) => d * math.pi / 180.0;
  static double _radToDeg(double r) => r * 180.0 / math.pi;

  static double _sinDeg(double d) => math.sin(_degToRad(d));
  static double _cosDeg(double d) => math.cos(_degToRad(d));
  static double _tanDeg(double d) => math.tan(_degToRad(d));
  static double _asinDeg(double x) => _radToDeg(math.asin(x));
  static double _acosDeg(double x) => _radToDeg(math.acos(x));
  static double _acotDeg(double x) => _radToDeg(math.atan(1 / x));
  static double _atan2Deg(double y, double x) => _radToDeg(math.atan2(y, x));

  static double _fixAngle(double a) => a - 360.0 * (a / 360.0).floorToDouble();
  static double _fixHour(double h) => h - 24.0 * (h / 24.0).floorToDouble();
}
