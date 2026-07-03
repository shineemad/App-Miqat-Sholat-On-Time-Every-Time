import 'dart:math' as math;

import 'models/qibla_result.dart';

/// Engine kalkulasi arah dan jarak ke Ka'bah (murni matematis, tanpa I/O).
///
/// Menggunakan formula great circle (Haversine) untuk jarak dan
/// forward azimuth untuk bearing.
///
/// Konstanta Ka'bah: 21.4225°N, 39.8262°E (WGS-84).
class QiblaCalculator {
  QiblaCalculator._();

  /// Koordinat Ka'bah (WGS-84).
  static const _kaabaLat = 21.4225;
  static const _kaabaLon = 39.8262;

  /// Jari-jari bumi rata-rata dalam kilometer.
  static const _earthRadiusKm = 6371.0;

  /// Hitung bearing dan jarak dari [latitude]/[longitude] ke Ka'bah.
  ///
  /// - [latitude]  : lintang pengguna (derajat, positif = Utara)
  /// - [longitude] : bujur pengguna (derajat, positif = Timur)
  static QiblaResult calculate({
    required double latitude,
    required double longitude,
  }) {
    return QiblaResult(
      bearingDegrees: _bearing(latitude, longitude),
      distanceKm: _distanceKm(latitude, longitude),
    );
  }

  // ── Implementasi ──────────────────────────────────────────────────────────

  /// Bearing dari titik pengguna ke Ka'bah (derajat dari Utara, 0–360°).
  ///
  /// Formula forward azimuth (great circle):
  ///   θ = atan2( sin(Δλ)·cos(φ₂),
  ///              cos(φ₁)·sin(φ₂) − sin(φ₁)·cos(φ₂)·cos(Δλ) )
  static double _bearing(double lat1, double lon1) {
    final φ1 = _rad(lat1);
    final φ2 = _rad(_kaabaLat);
    final Δλ = _rad(_kaabaLon - lon1);

    final y = math.sin(Δλ) * math.cos(φ2);
    final x = math.cos(φ1) * math.sin(φ2) -
        math.sin(φ1) * math.cos(φ2) * math.cos(Δλ);

    // Normalisasi ke [0, 360)
    return (_deg(math.atan2(y, x)) + 360.0) % 360.0;
  }

  /// Jarak great circle menggunakan formula Haversine (kilometer).
  static double _distanceKm(double lat1, double lon1) {
    final φ1 = _rad(lat1);
    final φ2 = _rad(_kaabaLat);
    final Δφ = _rad(_kaabaLat - lat1);
    final Δλ = _rad(_kaabaLon - lon1);

    final a = math.sin(Δφ / 2) * math.sin(Δφ / 2) +
        math.cos(φ1) * math.cos(φ2) * math.sin(Δλ / 2) * math.sin(Δλ / 2);

    return 2.0 * _earthRadiusKm * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;
}
