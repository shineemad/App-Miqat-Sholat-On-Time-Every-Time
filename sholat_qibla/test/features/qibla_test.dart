import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_qibla/core/utils/compass_utils.dart';
import 'package:sholat_qibla/engine/models/lat_lng.dart';
import 'package:sholat_qibla/features/qibla/qibla_calculator.dart';
import 'package:sholat_qibla/features/qibla/qibla_compass_service.dart';

void main() {
  group('QiblaCalculator - sudut kiblat (true north)', () {
    test('Jakarta sekitar 295°', () {
      const jakarta = LatLng(-6.2088, 106.8456);
      expect(QiblaCalculator.qiblaBearing(jakarta), closeTo(295.15, 1.0));
    });

    test('Kairo sekitar 136°', () {
      const cairo = LatLng(30.0444, 31.2357);
      expect(QiblaCalculator.qiblaBearing(cairo), closeTo(136.14, 1.0));
    });

    test('New York sekitar 58°', () {
      const newYork = LatLng(40.7128, -74.0060);
      expect(QiblaCalculator.qiblaBearing(newYork), closeTo(58.48, 1.0));
    });

    test('di Makkah sendiri jarak mendekati nol', () {
      expect(QiblaCalculator.distanceToKaabaKm(QiblaCalculator.kaaba),
          lessThan(0.001));
    });

    test('jarak Jakarta-Makkah sekitar 7900 km', () {
      const jakarta = LatLng(-6.2088, 106.8456);
      expect(QiblaCalculator.distanceToKaabaKm(jakarta),
          inInclusiveRange(7800, 8050));
    });
  });

  group('QiblaCalculator - sudut relatif & deteksi menghadap', () {
    test('relativeAngle nol saat heading = bearing', () {
      expect(
        QiblaCalculator.relativeAngle(deviceHeading: 295, qiblaBearing: 295),
        0,
      );
    });

    test('relativeAngle positif = kiblat di kanan', () {
      expect(
        QiblaCalculator.relativeAngle(deviceHeading: 280, qiblaBearing: 295),
        15,
      );
    });

    test('relativeAngle melintasi utara (350° -> 10°) = +20', () {
      expect(
        QiblaCalculator.relativeAngle(deviceHeading: 350, qiblaBearing: 10),
        20,
      );
    });

    test('isFacingQibla dalam toleransi', () {
      expect(
        QiblaCalculator.isFacingQibla(deviceHeading: 293, qiblaBearing: 295),
        isTrue,
      );
      expect(
        QiblaCalculator.isFacingQibla(deviceHeading: 280, qiblaBearing: 295),
        isFalse,
      );
    });
  });

  group('CompassUtils', () {
    test('normalize', () {
      expect(CompassUtils.normalize(370), 10);
      expect(CompassUtils.normalize(-30), 330);
      expect(CompassUtils.normalize(0), 0);
      expect(CompassUtils.normalize(360), 0);
    });

    test('signedDelta terpendek', () {
      expect(CompassUtils.signedDelta(10, 350), -20);
      expect(CompassUtils.signedDelta(350, 10), 20);
      expect(CompassUtils.signedDelta(0, 180), -180);
    });

    test('lowPass menghaluskan dan menangani lintasan utara', () {
      // Dari 350° menuju 10°: hasil harus bergerak maju melewati 0°,
      // bukan berputar balik lewat 180°.
      final smoothed = CompassUtils.lowPass(350, 10, alpha: 0.5);
      expect(smoothed, 0);
    });

    test('cardinalLabel', () {
      expect(CompassUtils.cardinalLabel(0), 'Utara');
      expect(CompassUtils.cardinalLabel(45), 'Timur Laut');
      expect(CompassUtils.cardinalLabel(90), 'Timur');
      expect(CompassUtils.cardinalLabel(295), 'Barat Laut');
      expect(CompassUtils.cardinalLabel(359), 'Utara');
    });
  });

  group('CompassReading - akurasi & kalibrasi', () {
    test('klasifikasi akurasi', () {
      expect(const CompassReading(heading: 0, accuracyDegrees: 5).accuracy,
          CompassAccuracy.high);
      expect(const CompassReading(heading: 0, accuracyDegrees: 20).accuracy,
          CompassAccuracy.medium);
      expect(const CompassReading(heading: 0, accuracyDegrees: 45).accuracy,
          CompassAccuracy.low);
      expect(const CompassReading(heading: 0).accuracy,
          CompassAccuracy.unknown);
    });

    test('needsCalibration saat akurasi rendah/unknown', () {
      expect(const CompassReading(heading: 0, accuracyDegrees: 45)
          .needsCalibration, isTrue);
      expect(const CompassReading(heading: 0).needsCalibration, isTrue);
      expect(const CompassReading(heading: 0, accuracyDegrees: 10)
          .needsCalibration, isFalse);
    });
  });

  group('QiblaCompassService', () {
    const jakarta = LatLng(-6.2088, 106.8456);

    test('menggabungkan heading + lokasi menjadi QiblaState', () async {
      final source = _FakeCompassSource([
        const CompassReading(heading: 295.15, accuracyDegrees: 5),
      ]);
      final service = QiblaCompassService(source: source);

      final state = (await service.watch(jakarta).toList()).single;
      expect(state, isNotNull);
      expect(state!.qiblaBearing, closeTo(295.15, 1.0));
      expect(state.relativeAngle.abs(), lessThan(1.5));
      expect(state.isFacingQibla, isTrue);
      expect(state.accuracy, CompassAccuracy.high);
      expect(state.needsCalibration, isFalse);
    });

    test('heading dihaluskan antar pembacaan', () async {
      final source = _FakeCompassSource([
        const CompassReading(heading: 0, accuracyDegrees: 5),
        const CompassReading(heading: 40, accuracyDegrees: 5),
      ]);
      final service = QiblaCompassService(source: source, smoothingAlpha: 0.5);

      final states = await service.watch(jakarta).toList();
      expect(states[0]!.deviceHeading, 0);
      // Low-pass: 0 + 0.5 * 40 = 20, bukan langsung 40.
      expect(states[1]!.deviceHeading, 20);
    });

    test('memancarkan null bila tidak ada sensor', () async {
      final source = _FakeCompassSource([null]);
      final service = QiblaCompassService(source: source);
      final states = await service.watch(jakarta).toList();
      expect(states.single, isNull);
    });
  });
}

class _FakeCompassSource implements CompassSource {
  _FakeCompassSource(this._readings);

  final List<CompassReading?> _readings;

  @override
  Stream<CompassReading?> get readings => Stream.fromIterable(_readings);

  @override
  Future<bool> hasCompass() async => true;
}
