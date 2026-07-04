import 'dart:math' as math;

/// Utilitas sudut kompas (derajat, 0° = utara, searah jarum jam).
abstract final class CompassUtils {
  /// Normalisasi sudut ke rentang [0, 360).
  static double normalize(double degrees) {
    final d = degrees % 360.0;
    return d < 0 ? d + 360.0 : d;
  }

  /// Selisih bersudut terpendek dari [from] ke [to], rentang [-180, 180).
  ///
  /// Positif berarti [to] berada searah jarum jam dari [from].
  static double signedDelta(double from, double to) {
    var delta = (to - from) % 360.0;
    if (delta >= 180.0) delta -= 360.0;
    if (delta < -180.0) delta += 360.0;
    return delta;
  }

  /// Low-pass filter sirkular untuk menghaluskan pembacaan kompas.
  ///
  /// [alpha] 0..1 — semakin kecil semakin halus (respon lebih lambat).
  static double lowPass(double previous, double current, {double alpha = 0.2}) {
    assert(alpha > 0 && alpha <= 1);
    final delta = signedDelta(previous, current);
    return normalize(previous + alpha * delta);
  }

  /// Label arah mata angin (bahasa Indonesia) untuk sudut [degrees].
  static String cardinalLabel(double degrees) {
    const labels = [
      'Utara',
      'Timur Laut',
      'Timur',
      'Tenggara',
      'Selatan',
      'Barat Daya',
      'Barat',
      'Barat Laut',
    ];
    final index = ((normalize(degrees) + 22.5) ~/ 45) % 8;
    return labels[index];
  }

  static double degToRad(double deg) => deg * math.pi / 180.0;
  static double radToDeg(double rad) => rad * 180.0 / math.pi;
}
