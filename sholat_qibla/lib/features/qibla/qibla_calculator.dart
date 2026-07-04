import 'dart:math' as math;

import '../../core/constants/calculation_constants.dart';
import '../../core/utils/compass_utils.dart';
import '../../engine/models/lat_lng.dart';

/// Mesin kalkulasi arah kiblat.
abstract final class QiblaCalculator {
  static const LatLng kaaba = LatLng(
    CalculationConstants.kaabaLatitude,
    CalculationConstants.kaabaLongitude,
  );

  /// Sudut kiblat (initial great-circle bearing) dari [from] ke Ka'bah,
  /// dalam derajat [0, 360) terhadap utara sejati (true north).
  ///
  /// Rumus: θ = atan2(sin Δλ, cos φ1 · tan φ2 − sin φ1 · cos Δλ)
  static double qiblaBearing(LatLng from) {
    final phi1 = CompassUtils.degToRad(from.latitude);
    final phi2 = CompassUtils.degToRad(kaaba.latitude);
    final deltaLng =
        CompassUtils.degToRad(kaaba.longitude - from.longitude);

    final y = math.sin(deltaLng);
    final x = math.cos(phi1) * math.tan(phi2) -
        math.sin(phi1) * math.cos(deltaLng);
    return CompassUtils.normalize(CompassUtils.radToDeg(math.atan2(y, x)));
  }

  /// Sudut kiblat relatif terhadap arah hadap perangkat, rentang [-180, 180).
  ///
  /// 0 berarti perangkat menghadap tepat ke kiblat; nilai positif berarti
  /// kiblat berada searah jarum jam (kanan) dari arah hadap.
  static double relativeAngle({
    required double deviceHeading,
    required double qiblaBearing,
  }) =>
      CompassUtils.signedDelta(deviceHeading, qiblaBearing);

  /// Apakah perangkat sudah menghadap kiblat dalam toleransi [toleranceDeg].
  static bool isFacingQibla({
    required double deviceHeading,
    required double qiblaBearing,
    double toleranceDeg = 5,
  }) =>
      relativeAngle(deviceHeading: deviceHeading, qiblaBearing: qiblaBearing)
          .abs() <=
      toleranceDeg;

  /// Jarak great-circle ke Ka'bah dalam kilometer.
  static double distanceToKaabaKm(LatLng from) => from.distanceTo(kaaba);
}
