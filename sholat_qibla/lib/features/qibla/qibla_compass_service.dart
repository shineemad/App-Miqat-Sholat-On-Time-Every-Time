import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';

import '../../core/utils/compass_utils.dart';
import '../../engine/models/lat_lng.dart';
import 'qibla_calculator.dart';

/// Tingkat akurasi pembacaan kompas.
enum CompassAccuracy { high, medium, low, unknown }

/// Satu pembacaan sensor kompas.
class CompassReading {
  const CompassReading({required this.heading, this.accuracyDegrees});

  /// Arah hadap perangkat terhadap utara, derajat [0, 360).
  final double heading;

  /// Estimasi galat sensor dalam derajat (null jika tidak tersedia).
  final double? accuracyDegrees;

  CompassAccuracy get accuracy {
    final acc = accuracyDegrees;
    if (acc == null || acc < 0) return CompassAccuracy.unknown;
    if (acc <= 15) return CompassAccuracy.high;
    if (acc <= 30) return CompassAccuracy.medium;
    return CompassAccuracy.low;
  }

  /// Perlu kalibrasi (gerakan angka 8) bila akurasi rendah/tidak diketahui.
  bool get needsCalibration =>
      accuracy == CompassAccuracy.low || accuracy == CompassAccuracy.unknown;
}

/// Sumber data kompas — abstraksi di atas sensor agar mudah di-mock.
abstract interface class CompassSource {
  /// Stream pembacaan; `null` berarti perangkat tak punya magnetometer.
  Stream<CompassReading?> get readings;

  /// Apakah perangkat memiliki sensor kompas.
  Future<bool> hasCompass();
}

/// Implementasi [CompassSource] dengan plugin flutter_compass.
class FlutterCompassSource implements CompassSource {
  const FlutterCompassSource();

  @override
  Stream<CompassReading?> get readings =>
      FlutterCompass.events?.map((event) {
        final heading = event.heading;
        if (heading == null) return null;
        return CompassReading(
          heading: CompassUtils.normalize(heading),
          accuracyDegrees: event.accuracy,
        );
      }) ??
      Stream.value(null);

  @override
  Future<bool> hasCompass() async => FlutterCompass.events != null;
}

/// Status arah kiblat yang siap ditampilkan UI.
class QiblaState {
  const QiblaState({
    required this.deviceHeading,
    required this.qiblaBearing,
    required this.relativeAngle,
    required this.accuracy,
    required this.needsCalibration,
  });

  final double deviceHeading;
  final double qiblaBearing;

  /// Sudut kiblat relatif arah hadap, [-180, 180). 0 = tepat menghadap kiblat.
  final double relativeAngle;
  final CompassAccuracy accuracy;
  final bool needsCalibration;

  bool get isFacingQibla => relativeAngle.abs() <= 5;
}

/// Menggabungkan sensor kompas + lokasi menjadi stream [QiblaState].
///
/// Heading dihaluskan dengan low-pass filter sirkular agar jarum
/// tidak bergetar.
class QiblaCompassService {
  QiblaCompassService({
    required CompassSource source,
    this.smoothingAlpha = 0.25,
  }) : _source = source;

  final CompassSource _source;

  /// 0..1 — semakin kecil semakin halus.
  final double smoothingAlpha;

  double? _smoothedHeading;

  /// Stream status kiblat untuk lokasi [location].
  ///
  /// Memancarkan `null` bila perangkat tidak memiliki sensor kompas.
  Stream<QiblaState?> watch(LatLng location) {
    final bearing = QiblaCalculator.qiblaBearing(location);
    return _source.readings.map((reading) {
      if (reading == null) return null;

      final previous = _smoothedHeading;
      final heading = previous == null
          ? reading.heading
          : CompassUtils.lowPass(previous, reading.heading,
              alpha: smoothingAlpha);
      _smoothedHeading = heading;

      return QiblaState(
        deviceHeading: heading,
        qiblaBearing: bearing,
        relativeAngle: QiblaCalculator.relativeAngle(
          deviceHeading: heading,
          qiblaBearing: bearing,
        ),
        accuracy: reading.accuracy,
        needsCalibration: reading.needsCalibration,
      );
    });
  }

  /// Reset state penghalusan (mis. saat layar kiblat dibuka ulang).
  void reset() => _smoothedHeading = null;
}
